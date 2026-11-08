# 开源科研计算环境 · MATLAB 替代版

> 不用 MATLAB 也能做科研计算：**GNU Octave 11.3 + Python 3.13 + JupyterLab**，
> 中文界面、离线可装、双击即用，并带一层自研的 **MATLAB 兼容层**。

针对"MATLAB 用不了但科研还要继续"的场景做的整套环境：
数值计算、符号推导、信号处理、绘图、机器学习、数据读写，全部开源免费。

---

## 亮点

| | 说明 |
|---|---|
| **MATLAB 语法兼容** | Octave 内核自带 MATLAB 兼容子系统（MAT-file v5、MEX、classdef）；本项目再补 12 个缺失函数 |
| **`.mat` 真互通** | 默认存盘已对齐 MATLAB 官方 v7 格式，并与 SciPy 交叉验证 9/9（Octave 存→SciPy 读、SciPy 存→Octave 读） |
| **中文无障碍** | 界面、绘图标题/坐标轴、帮助全部中文；绘图默认 `Microsoft YaHei` |
| **离线可装** | `wheels/` 内置全部 Python 依赖，无网环境也能 `pip install --no-index` |
| **双击即用** | 桌面快捷方式 + 图形启动面板 + 批处理启动器 |
| **可自证** | 一条命令跑完 6 大类测试，含 13 项兼容层断言 |
| **有取证** | 用 [craft-anything](https://github.com/storytold/craft-anything) 对内核做过二进制取证，见 [架构分析](架构分析-MATLAB替代内核.md) |

---

## 快速开始

```powershell
# 1. Python 侧（离线安装，依赖都在 wheels/）
.\.venv\Scripts\python.exe -m pip install --no-index --find-links wheels -r requirements.txt

# 2. 自检：Python / Jupyter / Octave / 扩展包 / 兼容层
.\检查环境.bat

# 3. 跑综合测试（会在本目录生成 测试结果.png）
.\运行测试.bat

# 4. 跑 .mat 互通测试（Octave <-> Python/SciPy 交叉验证）
.\测试-MAT互通.bat

# 5. 启动 MATLAB 兼容模式
.\启动-Octave.bat      →  选 [3] GUI + --traditional
```

桌面入口在 `%USERPROFILE%\Desktop\科研计算\`：**启动面板 / Jupyter Lab /
Octave GUI / Octave CLI / 研究文档**。

---

## 目录结构

```
research/
├─ compat/                  ★ MATLAB 兼容层（纯 .m，12 个函数）
│   ├─ maxk.m  mink.m  parula.m  contains.m  count.m  matches.m  split.m
│   ├─ readmatrix.m  writematrix.m  sgtitle.m  tiledlayout.m  nexttile.m
│   └─ README.md
├─ tools/
│   ├─ bat_to_gbk.py        批处理 GBK 编码修正工具
│   └─ mat_interop.py      .mat 互通交叉验证（Python/SciPy 侧）
├─ analysis/
│   └─ octave-arch.cany     craft-anything 取证项目（证据/日志）
├─ 测试代码.m / test_demo.m  综合测试（6 节，13 项兼容断言）
├─ 测试-MAT互通.m            .mat 与 MATLAB/SciPy 互通测试（9 项）
├─ verify_env.m            环境自检（扩展包 + 符号计算 + 绘图）
├─ demo_octave.m           MATLAB 语法演示
├─ 启动-Octave.bat          Octave 启动器（含 --traditional 兼容模式）
├─ 启动-科学计算.bat         JupyterLab 启动器（暗色主题、自动端口）
├─ 启动面板.py / .bat        tkinter 图形启动面板
├─ 检查环境.bat / 运行测试.bat / 测试-MAT互通.bat
├─ build_icons.py          图标生成（Pillow 渐变圆角）
├─ download_wheels.py      离线 wheel 下载器
├─ write_jupyter_cfg.py    Jupyter 暗色主题与默认配置
├─ 科研快速上手.ipynb       入门 Notebook
├─ MATLAB对照手册.md        MATLAB ↔ Octave 函数对照
├─ 研究环境说明.md          环境详细说明
├─ 架构分析-MATLAB官方架构.md ★ 照官方文档做的架构对照与缺陷修复
└─ 架构分析-MATLAB替代内核.md ★ craft-anything 二进制取证报告
```

---

## MATLAB 兼容层

Octave 11.3 里**完全不存在**、由本项目补齐的函数：

| 函数 | 用途 | 函数 | 用途 |
|---|---|---|---|
| `maxk` / `mink` | 取最大/最小 k 个元素（含索引） | `readmatrix` | 读 CSV/文本/Excel |
| `parula` | MATLAB 默认配色（近似） | `writematrix` | 写 CSV/文本/Excel |
| `contains` | 子串包含（支持忽略大小写） | `sgtitle` | 子图总标题 |
| `count` / `matches` | 计数 / 精确匹配 | `tiledlayout` | 平铺布局 |
| `split` | 字符串切分 | `nexttile` | 选择平铺块 |

已由 `.octaverc` 自动加载，无需 `addpath`。详见 [compat/README.md](compat/README.md)。

**已知硬边界**（内核级限制，非配置可解）：

* `.mat` **v7.3（HDF5）不支持**，只能 v4/v6/v7
* classdef 的**属性校验**（size/class/validators）不支持
* classdef **对象无法存盘**，会退化成 struct
* MATLAB 的 `&` / `|` 不短路，Octave 默认短路；用 `--traditional` 缓解

---

## 验证结果（实测）

```
【1】矩阵运算       x = [1  -1.25  4.5]，行列式 24，条件数 5.42
【2】符号计算       f(t)=t³sin t，f'(t)=t³cos t+3t²sin t，∫₀^π = π³-6π
【3】信号处理       最强频率 50 Hz 与 120 Hz
【4】统计           均值 ≈12，标准差 ≈0.5
【5】绘图           Chinese 标题正常，输出 测试结果.png
【6】MATLAB 兼容层   13 通过 / 0 失败
MAT 文件互通        9 通过 / 0 失败（Octave 存→SciPy 读、SciPy 存→Octave 读）
环境自检            SUMMARY pass=8 fail=0
```

---

## 环境依赖

* **GNU Octave 11.3.0**（MinGW 构建）+ 47 个 Forge 扩展包
* **Python 3.13** 虚拟环境，15 个核心库：
  NumPy / SciPy / Matplotlib / Pandas / SymPy / scikit-learn / seaborn / plotly /
  statsmodels / control / numba / h5py / openpyxl / ipywidgets / JupyterLab
* Windows 10/11（批处理与快捷方式针对 Windows；`.m` 与 Notebook 跨平台）

---

## 文档

* [架构分析-MATLAB官方架构.md](架构分析-MATLAB官方架构.md) —— 官方文档架构对照 + 默认存盘格式缺陷修复
* [架构分析-MATLAB替代内核.md](架构分析-MATLAB替代内核.md) —— craft-anything 二进制取证报告
* [MATLAB对照手册.md](MATLAB对照手册.md) —— 函数对照与迁移建议
* [研究环境说明.md](研究环境说明.md) —— 安装与使用详解
* [compat/README.md](compat/README.md) —— 兼容层清单与限制

---

## 许可

MIT，见 [LICENSE](LICENSE)。

Octave 为 GPLv3+，Python 各库为各自许可证，本项目只做环境编排与兼容层补丁。
