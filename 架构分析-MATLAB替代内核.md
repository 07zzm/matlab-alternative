# 架构分析：这套「MATLAB 替代版」的内核是怎么设计的

> 分析工具：**craft-anything**（本机 `craft-anything-cli` 0.4.0，Deep 模式）
> 分析模式：clean-room 关闭（Deep），即允许读取目标内部
> 分析日期：2026-11-08
> 分析项目：`analysis/octave-arch.cany`

---

## 0. 先说清楚一件事

**MATLAB 本体是商业闭源软件，本机没有安装，也没有可供分析的二进制。**
craft-anything 的分析必须有本地目标，所以这次取证的对象是**这套替代方案真正的内核：
GNU Octave 11.3.0 的原生库**。

这不是退而求其次——恰恰相反，这是唯一诚实的做法：

| | MATLAB | 我们的替代版 |
|---|---|---|
| 语言解释器 | 闭源，无法取证 | `liboctinterp-15.dll`（可取证） |
| 数值内核 | MKL / 闭源 | `liboctave-13.dll` + OpenBLAS/LAPACK/FFTW/SuiteSparse |
| 桌面 GUI | Java/Swing，闭源 | `liboctgui-14.dll` + Qt6 + QScintilla |
| 工具箱 | 付费 Toolbox | Octave Forge 扩展包（已装 47 个） |
| `.mat` 读写 | 原生 | Octave `load_save_system`（MAT v5 完整，v7.3 未实现） |
| MEX 扩展 | 原生 | Octave MEX API（`mexSet_impl` 等） |
| 兼容层 | —— | Octave 自带兼容子系统 + 本项目 `compat/` |

因此本文档回答的是：**这套替代版的内部分层长什么样、MATLAB 兼容性由哪些代码承担、
我们的缺口在哪里、已经补了什么。**

---

## 1. 取证结果：三库一器的分层

用 craft-anything 的 `core_overview_show` / `native_sections_list` /
`native_offered_symbols_list` 对四个目标取证，得到如下硬数据：

| 目标 | SHA-256（前 8 位） | 函数数 | 导出符号 | 导入符号 | 依赖库数 | .text 体积 |
|------|-------------------|-------|---------|---------|---------|-----------|
| `liboctinterp-15.dll` | `d48ead95` | 29,005 | 9,425 | 7,573 | 39 | 14.3 MB |
| `liboctave-13.dll` | `e2c43b0c` | 27,548 | 14,972 | 899 | 38 | 15.9 MB |
| `liboctgui-14.dll` | `3b04a624` | 6,602 | 14 | 2,847 | 27 | 2.35 MB |
| `octave.exe` | `c25e33e8` | —— | —— | —— | 17 | 小型启动器 |

三者都是 PE / x86_64 / MinGW(GCC) 构建、**符号表已 strip**、开启
NX + PIE + High-Entropy VA。

依赖关系（由导入表推出，不是猜的）：

```
octave.exe (0.14 MB 启动器)
   └── liboctgui-14.dll ──┬── liboctinterp-15.dll ──┬── liboctave-13.dll
                          │                        ├── libhdf5 / GraphicsMagick
                          │                        ├── CHOLMOD/AMD/COLAMD/CXSparse
                          │                        └── libgl2ps / fontconfig / freetype
                          ├── Qt6Core / Qt6Gui / Qt6Widgets / Qt6Help / Qt6Network
                          └── qscintilla2_qt6.dll   ← 代码编辑器控件

liboctave-13.dll ──┬── libblas / liblapack（= libopenblas）
                   ├── libfftw3-3 / libfftw3f-3
                   ├── libarpack-2 / libqrupdate-1
                   ├── libumfpack / libspqr / libcholmod / libcxsparse
                   ├── libsuitesparseconfig
                   └── libcurl-4 / libpcre2-8-0 / libreadline8
```

### 对应到 MATLAB 的架构

| MATLAB 组件 | 本替代版的对应实现 | 证据 |
|-------------|-------------------|------|
| MATLAB Desktop | `liboctgui-14.dll` + Qt6 + QScintilla | 导入 `Qt6Widgets.dll`、`qscintilla2_qt6.dll`；字符串 `QSCI_QSCILEXERMATLAB_H`（编辑器直接使用 **MATLAB 词法高亮器**） |
| 语言解析 / 执行引擎 | `liboctinterp-15.dll` | 导出 `tree_evaluator`、`tree_*` 系列语法树类、`octave_value` 类型系统、`type_info` |
| 数学内核 | `liboctave-13.dll` | 导入 BLAS/LAPACK/FFTW/SuiteSparse；导出 14,972 个数值类符号 |
| Toolbox | Forge 扩展包（`.m` 层，47 个已安装） | 由 `pkg load` 加载，不在原生二进制内 |
| 工作区变量模型 | `octave_value` / `octave_map` / `Cell` / `cdef_object` | 导出符号 `octave_map::assign`、`octave_classdef` 等 |
| `.mat` 文件兼容 | `load_save_system` | 导出 `read_mat5_binary_element`、`save_mat5_binary_element`、`read_mat_ascii_data` |
| MEX 扩展接口 | MEX API | 导出 `mexSet_impl`、`mexErrMsgTxt_impl`、`mexPutVariable_impl`、`mx_to_ov_args` |
| classdef 面向对象 | `tree_classdef` 解析树 + `cdef_class` | 导出 `tree_classdef_properties_block`、`cdef_class::run_constructor` 等 |

---

## 2. 关键发现：MATLAB 兼容性是一个**一等子系统**

这不是"顺便兼容"，Octave 内核里有专门为 MATLAB 写的代码路径。
craft-anything 的 `native_strings_find` 在 `liboctinterp-15.dll` 里命中 18 条
含 "matlab" 的字符串、188 条含 "classdef" 的字符串，其中最有价值的几条：

### 2.1 命令行级兼容开关

```
--traditional           Set variables for closer MATLAB compatibility.
--no-startup-tests      Don't run compatibility tests on startup.
```

→ **`--traditional` 就是我们该用的开关**。已加入启动器（见 §4）。

### 2.2 语法级兼容：短路运算符

```
"Matlab-style short-circuit operation performed for operator %s"
"Octave:possible-matlab-short-circuit-operator"
tree_binary_expression::matlab_style_short_circuit_warning
tree_braindead_shortcircuit_binary_expression::evaluate
```

→ MATLAB 的 `&` / `|` 不做短路，Octave 默认做；内核用一个专门的语法树节点
（类名直译为"脑残短路表达式"）来实现"模仿 MATLAB 的错误行为"，并给出警告 ID。
这解释了为什么旧 MATLAB 代码里 `if (x ~= 0 & 1/x > 2)` 在 Octave 下行为不同。

### 2.3 数据兼容：MAT-file

```
"MATLAB 5.0 MAT-file, written by Octave 11.3.0, %Y-%m-%d %T UTC"
"save: Matlab file format -v7.3 is not yet implemented"
"save: MATLAB compatible formats '-v4' and '-v6' are uncompressed"
"load: object of class '%s' was deleted in MATLAB and cannot be loaded."
"load: MATLAB enumeration class object cannot be loaded. Returning as %s"
read_mat5_binary_element / save_mat5_binary_element / looks_like_mat_ascii_file
mopt_digit_to_float_format / float_format_to_mopt_digit   ← MOPT = MATLAB optimal digits
```

→ `.mat` v4/v6/v7 能读写，**v7.3（HDF5 格式）不支持**；MATLAB 的
`enumeration`、被删除的类对象会降级成 struct 并给警告。

### 2.4 API 兼容：MEX 与 classdef

```
mexSet_impl / mexErrMsgTxt_impl / mexPutVariable_impl / mx_to_ov_args
"Saving classdef objects is not supported. Attempting to save '%s' as struct."
"size, class, and validation function specifications are not yet supported
 for classdef properties; INCORRECT RESULTS ARE POSSIBLE!"
```

→ MEX 有完整入口；classdef 有完整解析器，但**属性校验（size/class/validators）
不支持**，且 classdef 对象**不能存盘**（会退化成 struct）。

---

## 3. 我们测出来的真实缺口

用 `exist('名字')` 在 Octave 11.3 里逐个验证，以下 MATLAB 函数**完全不存在**（返回 0）：

| 缺失 | 类别 | 影响 |
|------|------|------|
| `maxk` / `mink` | 排序取值 | MATLAB 常用写法直接报错（本项目测试脚本第一次跑就撞上） |
| `parula` | 默认配色 | `colormap(parula)` 报错（本项目测试脚本也撞上） |
| `contains` / `count` / `matches` / `split` | 字符串 | 新式字符串处理代码全部失效 |
| `readmatrix` / `writematrix` | 数据读写 | R2019a+ 新 I/O 写法失效 |
| `sgtitle` / `tiledlayout` / `nexttile` | 绘图布局 | 现代排版代码失效 |
| `groupsummary` / `readtable` / `writetable` | 表格 | 未实现（`table` 类型本身存在） |

已存在、无需处理的：`startsWith`、`endsWith`、`xline`、`yline`、`movmean`、
`movmedian`、`string`、`isstring`、`validateattributes`、`table`、`array2table`、`strjoin`。

---

## 4. 基于取证结论做的改造

| # | 改造 | 依据 |
|---|------|------|
| 1 | 新增 `compat/` 目录，用纯 `.m` 补齐 12 个缺失函数 | §3 的缺口清单 |
| 2 | `.octaverc` 启动时自动 `addpath` 兼容层 | 让用户零配置 |
| 3 | 启动器新增 `[3] [4]` 选项，走 `--traditional` | §2.1 内核自带开关 |
| 4 | `.octaverc` 复刻 MATLAB 的 `startup.m` 自动执行行为 | MATLAB 与 Octave 的启动差异 |
| 5 | 测试脚本增加第 6 节，13 项兼容层断言 | 可回归验证 |
| 6 | 批处理改 GBK + `chcp` 分段策略 | 见 §5，独立发现的编码缺陷 |
| 7 | `verify_env.m` 增加 ASCII `SUMMARY pass=.. fail=..` 行 | 供 `.bat` 的 `findstr` 匹配 |

`--traditional` 的实际作用（内核字符串原文）：
*"Set variables for closer MATLAB compatibility"* —— 它会调整一批内建变量的默认值，
让脚本行为更接近 MATLAB。因此它被做成**可选项**而不是默认值：日常使用保持
Octave 原生（选项 1/2），跑旧 MATLAB 代码时选 3/4。

---

## 5. 附带发现：批处理中文乱码的真正原因

这不是 craft-anything 查出来的，是把测试脚本跑起来后暴露的：

* `research/*.bat` 原本以 **UTF-8** 保存，而 `cmd.exe` 按**控制台代码页**
  （简中系统 = GBK/936）逐行解析批处理。UTF-8 的中文被误读，导致
  `echo [错误] ...` 被拆坏，报 `'错误]' is not recognized ...`。
* 实测还发现：**Octave 无论控制台代码页是什么，始终输出 UTF-8**
  （在 cp936 与 cp65001 下分别抓字节验证：cp936 输出按 UTF-8 解码才正确）。
* 于是两个方向冲突：批处理自己的中文要 GBK，Octave 的中文要 UTF-8。

**解决办法**（已实现，见 `tools/bat_to_gbk.py`）：

```
@echo off
chcp 936 >nul          ← 锁定代码页，保证 GBK 中文被正确解析
... 所有中文提示写在这里 ...
chcp 65001 >nul        ← 只为 Octave 切换
"%OCTAVE_BIN%\octave.exe" ...
... 之后一律 ASCII ...
```

同时把 `.bat` 统一转为 GBK 保存；`tools/bat_to_gbk.py` 可检查/转换，
不在 GBK 字符集里的装饰字符（`✓` `▶`）会替换成 ASCII 等价写法。

---

## 6. 分析方法与可复现步骤

```powershell
# 0. 确认工具就绪
craft-anything-cli doctor

# 1. 建立分析项目并对解释器核心做初步取证（Deep 模式）
craft-anything-cli core-target-triage <OCTAVE_BIN>\liboctinterp-15.dll `
    --project analysis\octave-arch.cany --deep

# 2. 一页式总览：段、导入、计数
craft-anything-cli core-overview-show <OCTAVE_BIN>\liboctinterp-15.dll

# 3. 段表
craft-anything-cli native-sections-list <OCTAVE_BIN>\liboctinterp-15.dll

# 4. 导出符号（9,425 条，可翻页）
craft-anything-cli native-offered-symbols-list <OCTAVE_BIN>\liboctinterp-15.dll

# 5. 字符串取证：MATLAB 兼容性证据
craft-anything-cli native-strings-find <OCTAVE_BIN>\liboctinterp-15.dll --pattern matlab
craft-anything-cli native-strings-find <OCTAVE_BIN>\liboctinterp-15.dll --pattern classdef

# 6. 另外两个核心库
craft-anything-cli core-overview-show <OCTAVE_BIN>\liboctave-13.dll
craft-anything-cli core-overview-show <OCTAVE_BIN>\liboctgui-14.dll
```

### 证据的局限（必须如实说明）

* 三个 DLL 的符号表已被 strip，**19,387 / 29,005 个函数是自动命名**（`sub_…`），
  函数名级结论只对**导出符号**可靠。
* 总览报告提示：`liboctinterp` 有 **545 个间接跳转未能解析**，`liboctave` 157 个，
  `liboctgui` 471 个 —— 只通过运行时函数指针到达的代码可能不在函数表里，
  **"没找到"不等于"不存在"**。
* 工具链推断是启发式的：`liboctinterp-15.dll` 被标为 "Java native library (JNI)"，
  这是**误报**——真实原因是它导出了 `Java_org_octave_Octave_*` 这些供 Octave 的
  Java 互操作层调用的 JNI 入口。编译器的 "MinGW (GCC)" 标记也标注为 weak。
* `native_strings_find` 只能搜到**文件内存储的字符串**，运行时拼接的字符串搜不到。

---

## 7. 结论

1. 这套替代版的架构与 MATLAB **同构**：解释器 / 数值内核 / 桌面 GUI 三层，
   外加插件化的"工具箱"（Forge 包）。
2. MATLAB 兼容性由 Octave 内核**专门代码路径**承担（`--traditional`、MAT 文件、
   MEX、classdef、MATLAB 词法高亮器），我们在其之上补了 `.m` 层的 12 个缺口。
3. 已知的硬边界：`.mat` **v7.3 不支持**、**classdef 属性校验不支持**、
   classdef **对象无法存盘**、MATLAB 的 `&`/`|` 短路语义差异。这些是内核级限制，
   不是配置能解决的，遇到时只能改代码。
