# 第三方组件声明

本项目（`matlab-alternative`）自身以 **MIT** 许可发布，见 [LICENSE](LICENSE)。

但本项目只是**环境编排 + 兼容层**，它依赖和调用的第三方组件各自保留原有许可证，
**不受 MIT 覆盖**：

| 组件 | 许可证 | 说明 |
|------|--------|------|
| [GNU Octave](https://www.gnu.org/software/octave/) | GPLv3-or-later | 本项目的计算内核；`.m` 脚本由它执行 |
| Octave Forge 扩展包（47 个） | 各自许可证（多为 GPL） | `pkg load` 加载的科研功能 |
| Python 及标准库 | PSF License | —— |
| NumPy / SciPy / Matplotlib / Pandas / SymPy / scikit-learn / seaborn / plotly / statsmodels / numba / h5py / openpyxl / ipywidgets | 各自许可证（多为 BSD/MIT） | 见各项目仓库 |
| JupyterLab | BSD-3-Clause | 交互式笔记本环境 |
| Qt6 / QScintilla | LGPL / GPL | Octave GUI 依赖 |
| OpenBLAS / LAPACK / FFTW / SuiteSparse | BSD 类 / GPL 类 | 数值内核依赖 |

## 关于 `wheels/` 目录

本仓库**不包含** `wheels/`（离线 wheel 包，约 253 MB）。
按 [README](README.md) 的说明用 `download_wheels.py` 获取后，
其中的每个 wheel 仍适用其**上游原始许可证**，本项目不对其做任何再许可。

## 关于 `compat/` 目录

`compat/` 下的 MATLAB 兼容层是本项目的**原创代码**，以 MIT 发布。

需要说明的是：这些函数是为了让 MATLAB 语法的代码能在 Octave 上运行而编写的
**独立实现**，其中的 `parula.m` 配色为**视觉近似的独立实现**，不是 MathWorks
原始色表的复制。本项目与 MathWorks 无任何关联，也未使用其源代码。

MATLAB® 与 Simulink® 是 The MathWorks, Inc. 的注册商标。
本项目是独立的开源替代方案，与 MathWorks 无隶属或背书关系。
