# MATLAB → Python / Octave 语法对照手册

给科研人员用的速查表。左边是你熟悉的 MATLAB 写法，中间是 Python（NumPy/SciPy）写法，右边是 Octave 写法。

> 结论先说：**Octave 那列几乎和 MATLAB 一模一样**——你已有的 `.m` 脚本直接就能跑。
> Python 那列是长期主力方案，生态更新更快、库更多。

---

## 一、基本操作

| 功能 | MATLAB | Python (NumPy) | Octave |
|---|---|---|---|
| 注释 | `% 注释` | `# 注释` | `% 注释` |
| 定义变量 | `a = 5;` | `a = 5` | `a = 5;` |
| 行向量 | `v = [1 2 3];` | `v = np.array([1,2,3])` | `v = [1 2 3];` |
| 列向量 | `v = [1; 2; 3];` | `v = np.array([[1],[2],[3]])` | `v = [1; 2; 3];` |
| 序列 | `0:0.1:1` | `np.arange(0, 1.1, 0.1)` | `0:0.1:1` |
| 等距点 | `linspace(0,1,50)` | `np.linspace(0,1,50)` | `linspace(0,1,50)` |
| 全零矩阵 | `zeros(3,4)` | `np.zeros((3,4))` | `zeros(3,4)` |
| 全一矩阵 | `ones(3,4)` | `np.ones((3,4))` | `ones(3,4)` |
| 单位阵 | `eye(3)` | `np.eye(3)` | `eye(3)` |
| 随机数 | `rand(3,3)` | `np.random.rand(3,3)` | `rand(3,3)` |
| 矩阵转置 | `A'` | `A.T` | `A'` |

> ⚠️ **索引差别**：MATLAB/Octave 从 **1** 开始，Python 从 **0** 开始。
> `A(1,1)`（MATLAB）= `A[0,0]`（Python）

---

## 二、矩阵与线性代数

| 功能 | MATLAB | Python | Octave |
|---|---|---|---|
| 矩阵乘法 | `A*B` | `A @ B` 或 `A.dot(B)` | `A*B` |
| 逐元素乘 | `A.*B` | `A * B` | `A.*B` |
| 解方程 Ax=b | `x = A\b` | `x = np.linalg.solve(A, b)` | `x = A\b` |
| 最小二乘 | `A\b`（超定） | `np.linalg.lstsq(A,b)` | `A\b` |
| 逆矩阵 | `inv(A)` | `np.linalg.inv(A)` | `inv(A)` |
| 特征值 | `eig(A)` | `np.linalg.eig(A)` | `eig(A)` |
| 奇异值分解 | `svd(A)` | `np.linalg.svd(A)` | `svd(A)` |
| 行列式 | `det(A)` | `np.linalg.det(A)` | `det(A)` |
| 秩 | `rank(A)` | `np.linalg.matrix_rank(A)` | `rank(A)` |
| 迹 | `trace(A)` | `np.trace(A)` | `trace(A)` |
| 范数 | `norm(x)` | `np.linalg.norm(x)` | `norm(x)` |
| LU 分解 | `[L,U]=lu(A)` | `scipy.linalg.lu(A)` | `[L,U]=lu(A)` |
| 矩阵尺寸 | `size(A)` | `A.shape` | `size(A)` |
| 元素个数 | `numel(A)` | `A.size` | `numel(A)` |

---

## 三、数学函数与数值分析

| 功能 | MATLAB | Python | Octave |
|---|---|---|---|
| 求根 | `roots(p)` | `np.roots(p)` | `roots(p)` |
| 多项式求值 | `polyval(p,x)` | `np.polyval(p,x)` | `polyval(p,x)` |
| 数值积分 | `quad(f,a,b)` | `scipy.integrate.quad(f,a,b)` | `quad(f,a,b)` |
| 求解 ODE | `ode45(f,[t0 tf],y0)` | `scipy.integrate.solve_ivp(...)` | `ode45(f,[t0 tf],y0)` |
| 无约束最小化 | `fminsearch(f,x0)` | `scipy.optimize.minimize(...)` | `fminsearch(f,x0)` |
| 约束优化 | `fmincon(...)` | `scipy.optimize.minimize(method='SLSQP')` | `sqp(...)` |
| 插值 | `interp1(x,y,xq)` | `np.interp(xq,x,y)` | `interp1(x,y,xq)` |
| 曲线拟合 | `polyfit(x,y,n)` | `np.polyfit(x,y,n)` | `polyfit(x,y,n)` |
| 三次样条 | `spline(x,y,xq)` | `scipy.interpolate.CubicSpline` | `spline(x,y,xq)` |
| 快速傅里叶 | `fft(x)` | `np.fft.fft(x)` | `fft(x)` |

---

## 四、信号处理（需 `signal` 包）

| 功能 | MATLAB | Python (`scipy.signal`) | Octave (`signal`) |
|---|---|---|---|
| 滤波器设计 | `butter(...)` | `signal.butter(...)` | `butter(...)` |
| 滤波 | `filter(b,a,x)` | `signal.lfilter(b,a,x)` | `filter(b,a,x)` |
| 零相位滤波 | `filtfilt(b,a,x)` | `signal.filtfilt(b,a,x)` | `filtfilt(b,a,x)` |
| 卷积 | `conv(x,h)` | `np.convolve(x,h)` | `conv(x,h)` |
| 互相关 | `xcorr(x,y)` | `signal.correlate(x,y)` | `xcorr(x,y)` |
| 频谱估计 | `pwelch(x)` | `signal.welch(x)` | `pwelch(x)` |
| 希尔伯特变换 | `hilbert(x)` | `signal.hilbert(x)` | `hilbert(x)` |

---

## 五、控制系统（需 `control` 包）

| 功能 | MATLAB | Python (`control`) | Octave (`control`) |
|---|---|---|---|
| 传递函数 | `tf(num,den)` | `control.tf(num,den)` | `tf(num,den)` |
| 状态空间 | `ss(A,B,C,D)` | `control.ss(A,B,C,D)` | `ss(A,B,C,D)` |
| 阶跃响应 | `step(sys)` | `control.step_response(sys)` | `step(sys)` |
| 波特图 | `bode(sys)` | `control.bode_plot(sys)` | `bode(sys)` |
| 根轨迹 | `rlocus(sys)` | `control.root_locus(sys)` | `rlocus(sys)` |
| 极点配置 | `place(A,B,p)` | `control.place(A,B,p)` | `place(A,B,p)` |
| PID 设计 | `pidtune(...)` | `control.pidtune` 需自实现 | — |

---

## 六、统计（`statistics` 包）

| 功能 | MATLAB | Python (`scipy.stats`) | Octave (`statistics`) |
|---|---|---|---|
| t 检验 | `ttest2(x,y)` | `scipy.stats.ttest_ind(x,y)` | `ttest2(x,y)` |
| 卡方检验 | `chi2gof(...)` | `scipy.stats.chisquare(...)` | `chi2gof(...)` |
| 正态分布 PDF | `normpdf(x,mu,s)` | `scipy.stats.norm.pdf(x,mu,s)` | `normpdf(x,mu,s)` |
| 相关系数 | `corr(x,y)` | `np.corrcoef(x,y)` | `corr(x,y)` |
| 线性回归 | `fitlm(...)` | `statsmodels.OLS(...)` | `regress(y,X)` |
| 均值/标准差 | `mean/std` | `np.mean/np.std` | `mean/std` |
| 中位数 | `median(x)` | `np.median(x)` | `median(x)` |

---

## 七、绘图

| 功能 | MATLAB | Python (`matplotlib`) | Octave |
|---|---|---|---|
| 折线图 | `plot(x,y)` | `plt.plot(x,y)` | `plot(x,y)` |
| 散点图 | `scatter(x,y)` | `plt.scatter(x,y)` | `scatter(x,y)` |
| 双对数 | `loglog(x,y)` | `plt.loglog(x,y)` | `loglog(x,y)` |
| 图像/热图 | `imagesc(A)` | `plt.imshow(A)` | `imagesc(A)` |
| 等高线 | `contour(Z)` | `plt.contour(Z)` | `contour(Z)` |
| 三维曲面 | `surf(Z)` | `ax.plot_surface(...)` | `surf(Z)` |
| 子图 | `subplot(2,2,1)` | `plt.subplot(2,2,1)` | `subplot(2,2,1)` |
| 标题 | `title('t')` | `plt.title('t')` | `title('t')` |
| 坐标轴标签 | `xlabel('x')` | `plt.xlabel('x')` | `xlabel('x')` |
| 图例 | `legend('a')` | `plt.legend(['a'])` | `legend('a')` |
| 网格 | `grid on` | `plt.grid(True)` | `grid on` |
| 保存图片 | `print -dpng f.png` | `plt.savefig('f.png')` | `print -dpng f.png` |
| 显示 | 自动 | `plt.show()` | 自动 |

**中文显示**（Python 必加）：
```python
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False
```

---

## 八、数据读写

| 功能 | MATLAB | Python | Octave |
|---|---|---|---|
| 读 CSV | `readmatrix('f.csv')` | `np.loadtxt('f.csv',delimiter=',')` | `csvread('f.csv')` |
| 读表格 | `readtable('f.csv')` | `pd.read_csv('f.csv')` | `xlsread`/`csv2cell` |
| 读 Excel | `readmatrix('f.xlsx')` | `pd.read_excel('f.xlsx')` | `xlsread('f.xlsx')` |
| 写 CSV | `writematrix(M,'f.csv')` | `np.savetxt(...)` / `df.to_csv(...)` | `csvwrite('f.csv',M)` |
| 写 Excel | `writecell(C,'f.xlsx')` | `df.to_excel('f.xlsx')` | `xlswrite('f.xlsx',M)` |
| 存 .mat | `save('f.mat')` | `scipy.io.savemat('f.mat',{...})` | `save('f.mat')` |
| 读 .mat | `load('f.mat')` | `scipy.io.loadmat('f.mat')` | `load('f.mat')` |
| 读 HDF5 | `h5read(...)` | `h5py.File(...)` | — |

**好消息**：`scipy.io.loadmat/savemat` 能直接读写 MATLAB 的 `.mat` 文件，可以两边互通数据。

---

## 九、字符串与流程控制

| 功能 | MATLAB | Python | Octave |
|---|---|---|---|
| 格式化输出 | `fprintf('%.2f\n',x)` | `print(f'{x:.2f}')` | `fprintf('%.2f\n',x)` |
| 字符连接 | `['a' 'b']` | `'a' + 'b'` | `['a' 'b']` |
| if 语句 | `if x>0 ... end` | `if x>0:` (缩进) | `if x>0 ... end` |
| for 循环 | `for i=1:10 ... end` | `for i in range(10):` | `for i=1:10 ... end` |
| while | `while x<1 ... end` | `while x<1:` | `while x<1 ... end` |
| 定义函数 | `function y=f(x) y=x^2; end` | `def f(x): return x**2` | `function y=f(x) y=x^2; end` |
| 匿名函数 | `f = @(x) x^2` | `f = lambda x: x**2` | `f = @(x) x^2` |

---

## 十、迁移建议

1. **已有 MATLAB 脚本** → 用 **Octave** 直接跑，改动最小。
2. **新项目/长期使用** → 用 **Python**，生态和更新速度都更好。
3. **混合用** → 用 `.mat` 文件或 CSV 在两边交换数据。
4. **专有工具箱** → 在 Python 找对应库（信号→scipy.signal，控制→control，统计→statsmodels，ML→scikit-learn，图像→scikit-image）。

---

*本手册随环境一起放在 `research\` 目录下，随时查阅。*
