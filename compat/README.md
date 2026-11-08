# compat —— MATLAB 兼容层

Octave 11.3 已经内置了相当强的 MATLAB 兼容子系统（用 craft-anything 对内核取证可见：
`--traditional` 选项、`matlab_style_short_circuit_warning`、MAT-file v5 读写、
`mexSet_impl` / `mexPutVariable_impl` 等 MEX API、`classdef` 解析树）。
但仍有若干 MATLAB 函数没有实现。本目录用纯 `.m` 补齐这些缺口。

## 已补齐的函数

| 文件 | 对应 MATLAB 函数 | 说明 |
|------|------------------|------|
| `maxk.m` | `maxk` | 取最大的 k 个元素（含索引） |
| `mink.m` | `mink` | 取最小的 k 个元素（含索引） |
| `parula.m` | `parula` | MATLAB 默认配色（锚点插值近似） |
| `contains.m` | `contains` | 子串包含判断，支持 `IgnoreCase` |
| `count.m` | `count` | 统计子串出现次数 |
| `matches.m` | `matches` | 完整匹配判断 |
| `split.m` | `split` | 按分隔符切分字符串 |
| `readmatrix.m` | `readmatrix` | 读取 CSV/文本/Excel 为矩阵 |
| `writematrix.m` | `writematrix` | 写出矩阵到 CSV/文本/Excel |
| `sgtitle.m` | `sgtitle` | 子图总标题（中文可用） |
| `tiledlayout.m` | `tiledlayout` | 平铺布局（轻量实现） |
| `nexttile.m` | `nexttile` | 选择下一个平铺块 |

## 已知限制

* `parula` 是**视觉近似**，不是 MathWorks 原表的逐字节复制。
* `tiledlayout` 只支持 `tiledlayout(m,n)`；`'flow'` / `'vertical'` / `'horizontal'`
  以及 `TileSpacing` 等属性未实现。
* `readmatrix` / `writematrix` 不支持 `Range`、`Sheet`、`OutputType` 等高级参数。
  Excel 读写依赖 `io` 扩展包。
* `split` 对多字符分隔符的行为与 MATLAB 略有差异（内部用 Octave 的 `strsplit`）。

## 加载方式

`.octaverc` 已在启动时把本目录加入搜索路径，因此**无需手动 addpath**。
如需在某个会话中手动加载：

```matlab
addpath('D:\GitHub_Project\craft-anything\research\compat');
```
