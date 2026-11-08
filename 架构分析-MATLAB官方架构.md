# MATLAB 官方架构 & 我们的复刻对照

> 本文只写**能查证的东西**，并且区分三档可信度：
> **【官方】**= MathWorks 官方文档原文；**【取证】**= 对二进制做工具取证得到；
> **【不可知】**= 闭源且无安装，无法验证。
>
> 资料获取方式（2026-11-08）：`www.mathworks.com` 直连返回 **HTTP 403**（Akamai 拦截），
> 改用 MathWorks 官方中文镜像 `ww2.mathworks.cn` 可正常访问，本文所有官方结论均取自该镜像。

---

## 0. 必须先说清楚：什么我做不到

你要求"看 MATLAB 的架构设计和底层代码"。我把能做到的做到了，做不到的也讲明白：

| 要求 | 能否做到 | 原因 |
|------|---------|------|
| 看 MATLAB 架构设计 | ✅ 能 | MathWorks 官方文档公开描述 |
| 看 MATLAB 底层代码 | ❌ 不能 | 闭源，不提供源码 |
| 反编译 MATLAB 二进制 | ❌ 不能 | 本机**没有安装 MATLAB**：无安装目录、无注册表记录、无可执行文件、无工程文件（已全盘+注册表核查） |
| 看我们替代版的内核代码 | ✅ 能 | Octave 是 GPL 开源，且已用 craft-anything 取证（见 [架构分析-MATLAB替代内核.md](架构分析-MATLAB替代内核.md)） |

**谁要是声称读了 MATLAB 源码，那是在编。** 但"照着官方文档把行为对齐"是完全可行的，
而且这次就抓到了一个真实缺陷（见 §4）。

---

## 1. 【官方】MATLAB 的语言定位

MathWorks 原文：

> *MATLAB 是"matrix laboratory"的缩写形式。其他编程语言通常一次只能处理一个数字，
> 而 MATLAB® 则针对整个矩阵和数组进行运算处理。*

这句话决定了一切：**矩阵是唯一的一等公民**，标量是 1×1 矩阵，几乎所有运算符都默认是
数组运算，要逐元素运算得加 `.`（`.*` `./` `.^`）。

官方把语言基础知识划成 5 块：

| 官方分类 | 内容 | 我们对应的实现 |
|---------|------|--------------|
| 输入命令 | 编译和运行 MATLAB 语句 | Octave 命令行 / GUI 终端 |
| 矩阵和数组 | 创建、合并、重构、重排、索引 | Octave 原生（含 `end`、逻辑索引、线性索引） |
| 数据类型 | 数值数组、字符和字符串、表格、结构体、元胞数组、类型转换 | Octave 原生 + 本项目 `compat/` 补字符串函数 |
| 运算符和基本运算 | 算术/关系/逻辑运算符、特殊字符、舍入、集合函数 | Octave 原生；短路语义差异见下 |
| 循环及条件语句 | `if` `for` `while` 等 | Octave 原生（支持 `end` 关键字与 `endfor` 别名） |

> **已知语义差异（内核取证证实）**：MATLAB 的 `&` / `|` **不做短路**，Octave 默认做短路。
> Octave 内核为此专门有一个语法树节点 `tree_braindead_shortcircuit_binary_expression`
> 和警告 ID `Octave:possible-matlab-short-circuit-operator` 来模拟 MATLAB 行为。
> 用 `--traditional` 启动可缓解（启动器选项 3/4）。

---

## 2. 【官方】MATLAB 的编程模型

官方把编程能力划成 8 块：

| 官方分类 | 我们对应的实现 |
|---------|--------------|
| 脚本 | Octave 脚本 `.m`（本项目 `测试代码.m`） |
| 函数 | Octave 函数文件、匿名函数、`nargin`/`nargout` |
| **实时脚本和函数（Live Script）** | ❌ **无对应**。这是 MATLAB 独有格式 `.mlx`；我们用 **Jupyter Notebook** 替代（`科研快速上手.ipynb`） |
| 类（面向对象） | Octave `classdef` 解析器（取证确认存在），但**属性校验不支持** |
| 文件和文件夹 / 搜索路径 | Octave `path`/`addpath`；本项目用 `.octaverc` 自动加载 |
| 后台和并行处理 | Octave 有 `parcellfun`（需 `parallel` 包）；MATLAB 的 `parfor` 需 Parallel Computing Toolbox |
| 代码安全性 | 无对应（MATLAB 的 `matlab.lang.OnOffSwitchState`、P 代码等属商业特性） |
| 高级计算和异常处理 | Octave `eval`/`feval`/`try-catch`/`onCleanup` |

---

## 3. 【官方】数据格式：MAT 文件版本（复刻的关键依据）

MathWorks 官方《MAT 文件版本》给出的规格表：

| MAT 版本 | 支持的 MATLAB 发行版 | 支持功能 | 压缩 | 单变量上限 | `save` 参数 |
|---|---|---|---|---|---|
| **7.3** | R2006b (7.3) 及以上 | 部分变量存取 + v7 全部功能 | 是（默认） | ≥ 2 GB（64 位） | `-v7.3` |
| **7** | R14 (7.0) 及以上 | **Unicode 字符编码** + v6 全部功能 | 是（默认） | 2^31 字节 | `-v7` |
| **6** | R8 (5.0) 及以上 | N 维数组、元胞数组、结构体数组、变量名 > 19 字符 + v4 全部 | 否 | 2^31 字节 | `-v6` |
| **4** | 全部 | 二维 `double`、字符、稀疏数组 | 否 | 1 亿元素/数组 | `-v4` |

官方原文关键句：

> *默认情况下，所有保存操作都会创建 **7 版本**的 MAT 文件。唯一的例外是使用 `matfile`
> 函数创建新的 MAT 文件时，此时默认是 **7.3 版本**。*

> *7.3 版本的 MAT 文件使用基于 HDF5 的格式。*

---

## 4. ★ 复刻成果：照官方文档抓出的默认行为缺陷

把官方规格和本机 Octave 实测一对比，问题立刻暴露：

| | 官方 MATLAB | 本机 Octave（**修改前**） |
|---|---|---|
| 默认存盘版本 | **7**（压缩 + Unicode） | **`-text`** |
| 写出的文件头 | `MATLAB 5.0 MAT-file` | `# Created by Octave 11.3.0 ...` |
| MATLAB 能否读取 | —— | **不能** |

实测命令与输出：

```
save_default_options()  =  -text
save('_default.mat','a')  ->  文件头: # Created by Octave 11.3.0, ...
save('-v7','_v7.mat','a') ->  文件头: MATLAB 5.0 MAT-file, written by Octave ...
```

**后果**：用户只要用默认的 `save` 存盘，产出的 `.mat` 就与 MATLAB 不互通——
而科研场景里"把数据交给用 MATLAB 的同事/导师"恰恰是最常见的需求。

**修复**：`.octaverc` 增加一行，让默认行为与官方一致。

```matlab
save_default_options('-v7');   % 对齐 MATLAB 官方默认（MAT 版本 7）
```

修复后用**独立第三方实现交叉验证**（SciPy 的 MAT 读写器，不依赖 Octave 自证）：

```
【0】save_default_options() = -v7                                  [通过]
【1】默认 save 文件头 = "MATLAB 5.0 MAT-file, written by"           [通过]
【2】Python/SciPy 读 Octave 写的文件：shape=4x4 sum=136 v=42.5     [通过]
【3】Python/SciPy 写文件                                            [通过]
【4】Octave 默认 load 读回：A = magic(4)，v = 42.5                  [通过]
【5】-v4 / -v6 / -v7 三种版本写入                                    [通过]
【6】v7.3 如实标注为不支持（内核字符串 "-v7.3 is not yet implemented"）[通过]
                                        SUMMARY pass=9 fail=0
```

复现：双击 `测试-MAT互通.bat`，或

```powershell
octave.exe --no-gui --quiet 测试-MAT互通.m
```

---

## 5. 【官方】部署架构：MATLAB Runtime (MCR)

MathWorks 原文：

> *MATLAB Runtime 是**共享库、MATLAB 代码和其他文件的集合**，使您能够在未安装
> MATLAB 的系统上执行编译和打包的 MATLAB 应用程序。*

这印证了 MATLAB 的整体架构是**"解释器 + 一大堆积木"**，而不是单一可执行文件：

```
MATLAB 源码 (.m)
   ↓ MATLAB Compiler 打包
已部署应用(.exe) + 用户算法
   ↓ 运行时依赖
MATLAB Runtime (MCR) = 共享库 + MATLAB 代码 + 其他文件
```

**我们的对应关系**：

| MATLAB | 我们的替代 |
|--------|-----------|
| MATLAB 本体（解释器 + Toolbox） | Octave 11.3（`liboctinterp` + `liboctave` + 47 个 Forge 包） |
| MATLAB Runtime (MCR) | Octave 运行时（同样"共享库 + .m 代码"结构，取证已证实） |
| MATLAB Compiler 打包 exe | ❌ 无对应（可用 Jupyter/Python 打包替代） |
| 无 MATLAB 的机器上跑已部署应用 | ✅ 直接把整个环境打包分发（`wheels/` 离线安装） |

注意架构上的**同构性**：MCR 是"共享库 + MATLAB 代码"，Octave 也是
"`liboctinterp-15.dll` + 数千个 `.m` 文件（Forge 包）"。这不是巧合——
两者都是"小内核 + 大脚本库"的设计。

---

## 6. 【官方】外部语言接口

MathWorks 列出的接口：Python、Java、C、C++、.NET、Web 服务。
我们这一侧的对应：

| MATLAB 接口 | 我们的对应 | 状态 |
|------------|-----------|------|
| 调用 Python (`py.` 前缀) | `symbolic` 包通过 SymPy 后端；Python 侧可反向调用 Octave | ✅ 部分 |
| MEX（C/C++ 扩展） | Octave MEX API（取证见 `mexSet_impl`/`mexPutVariable_impl`）+ `mkoctfile` | ✅ 可用 |
| Java 互操作 | Octave 内置 JVM 互操作（取证见 `Java_org_octave_Octave_*` 导出） | ✅ 存在 |
| .NET / Web 服务 | ❌ 无对应 | —— |

---

## 7. 【官方】功能域对照（工具箱 → Forge 包）

MathWorks 把产品按应用域划分，我们的覆盖情况：

| 官方应用域 | 我们已装 Forge 包 | 覆盖度 |
|-----------|------------------|--------|
| 数学与优化 | `optim`、`statistics`、`symbolic`、`splines` | 较好 |
| 信号处理 | `signal`、`communications` | 较好 |
| 图像处理与计算机视觉 | `image`（含 OpenCV 绑定，取证见 `libopencv_world4120.dll`） | 中等 |
| 控制系统 | `control` | 中等 |
| AI 与统计 | Python 侧 scikit-learn / statsmodels / seaborn 替代 | 中等（走 Python） |
| 数据导入导出 | `io`、`struct`、`datatypes` | 较好 |
| **Simulink（图形化建模仿真）** | ❌ **无对应** | 无 |
| 代码生成 / 硬件部署 | ❌ 无对应 | 无 |
| Test & Measurement / RF / Radar | ❌ 无对应 | 无 |

---

## 8. 无法复刻的部分（诚实清单）

| 项目 | 原因 |
|------|------|
| Simulink / Stateflow | 商业图形化建模环境，无开源等价物 |
| 绝大多数付费 Toolbox | 算法本身闭源；只能找社区替代实现 |
| Live Script (.mlx) | 专有格式，用 Jupyter Notebook 替代 |
| MAT v7.3 (HDF5) 写入 | Octave 内核明确未实现（字符串证据） |
| classdef 属性校验 (size/class/validators) | 内核字符串自承 "INCORRECT RESULTS ARE POSSIBLE" |
| classdef 对象存盘 | 内核会降级为 struct 并告警 |
| MATLAB Runtime / Compiler 生态 | 商业部署链路 |
| MATLAB 的 JIT 性能 | 闭源优化，Octave 是解释器，性能有差距 |

---

## 9. 结论

1. **MATLAB 的架构是公开可知的**：矩阵优先的语言内核 + 分类清晰的编程模型 +
   "共享库 + MATLAB 代码"的运行时 + 按应用域切分的工具箱。
2. **MATLAB 的源码是不可知的**，且本机没有安装，任何"读过源码"的说法都是编造。
3. **但"照官方规格对齐行为"极有价值**——本文第 §4 就是证据：一个默认存盘格式的
   差异，直接决定产出的 `.mat` 能不能交给用 MATLAB 的人。这个问题靠"看架构图"
   看不出来，只能靠"读官方规格 + 实测比对"抓出来。
4. 我们已落地：MAT 默认 v7 对齐（交叉验证 9/9）、`--traditional` 兼容模式、
   12 个缺失函数补齐、`startup.m` 行为复刻，以及一套可回归的测试。

---

## 引用

1. [语言基础知识 — MATLAB 文档（官方镜像）](https://ww2.mathworks.cn/help/matlab/language-fundamentals.html)
2. [编程（脚本/函数/类） — MATLAB 文档](https://ww2.mathworks.cn/help/matlab/programming-and-data-types.html)
3. [MAT 文件版本 — MATLAB 文档](https://ww2.mathworks.cn/help/matlab/import_export/mat-file-versions.html)
4. [MATLAB Runtime — MATLAB Compiler 文档](https://ww2.mathworks.cn/help/compiler/matlab-runtime.html)
5. [MathWorks 文档主页](https://ww2.mathworks.cn/help/index.html)

> 说明：`www.mathworks.com` 对本次请求返回 HTTP 403，以上链接均使用官方中文镜像
> `ww2.mathworks.cn`，内容为 MathWorks 官方文档。
