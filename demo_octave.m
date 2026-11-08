% ===============================================
%  Octave 科研能力演示脚本
%  运行:  octave-cli.exe demo_octave.m
% ===============================================
printf('===== 1. 矩阵与线性代数 =====\n');
A = [4 -2 1; -2 4 -2; 1 -2 3];
b = [11; -16; 17];
x = A\b;                          % 解线性方程组 Ax=b
printf('方程组的解 x = %s\n', mat2str(x', 6));
printf('A 的特征值 = %s\n', mat2str(eig(A)', 6));
printf('A 的行列式 = %.4f，秩 = %d\n', det(A), rank(A));

printf('\n===== 2. 多项式与求根 =====\n');
p = [1 -6 11 -6];                 % x^3 - 6x^2 + 11x - 6
r = roots(p);
printf('多项式 x^3-6x^2+11x-6 的根 = %s\n', mat2str(sort(r)', 6));

printf('\n===== 3. 微积分与优化 =====\n');
f = @(t) exp(-t).*sin(3*t);
I = quad(f, 0, pi);               % 数值积分
printf('∫0..π e^{-t}sin(3t) dt = %.6f\n', I);
g = @(v) (v(1)-1)^2 + (v(2)-2)^2 + 3;   % 找最小值
[vmin, fmin] = fminsearch(g, [0 0]);
printf('函数最小值点 = (%s)，最小值 = %.4f\n', mat2str(vmin, 4), fmin);

printf('\n===== 4. 常微分方程 (ODE) =====\n');
% 阻尼振动:  y'' + 0.5y' + 4y = 0
dydt = @(t,y) [y(2); -0.5*y(2) - 4*y(1)];
[t, y] = ode45(dydt, [0 10], [1; 0]);
printf('ode45 求解阻尼振动，共 %d 个时间点\n', numel(t));
printf('t=10 时 y = %.5f, y'' = %.5f\n', y(end,1), y(end,2));

printf('\n===== 5. 信号处理 (FFT) =====\n');
fs = 1000;  tt = 0:1/fs:0.999;
sig = 2*sin(2*pi*50*tt) + 0.5*sin(2*pi*120*tt);
Y = abs(fft(sig));
freq = (0:numel(sig)-1)*(fs/numel(sig));
[~, idx] = sort(Y, 'descend');
printf('信号中能量最强的两个频率: %.0f Hz, %.0f Hz\n', freq(idx(1)), freq(idx(2)));

printf('\n===== 6. 统计 =====\n');
data = [12.1 11.8 12.5 11.9 12.3 12.0 12.2 11.7 12.4];
printf('均值 = %.4f，标准差 = %.4f，中位数 = %.4f\n', ...
       mean(data), std(data), median(data));

printf('\n===== 7. 绘图 =====\n');
try
  graphics_toolkit('qt');          % 无界面环境下用 qt 渲染
catch e
  warning('qt 不可用，保持默认: %s', e.message);
end
figure('visible','off');
subplot(2,2,1);
xx = linspace(0, 4*pi, 300);
plot(xx, sin(xx), 'b-', xx, cos(xx), 'r--');
title('三角函数'); legend('sin','cos'); grid on;

subplot(2,2,2);
imagesc(A); colorbar; title('矩阵热图');

subplot(2,2,3);
plot(t, y(:,1), 'k-', 'LineWidth', 1.5);
title('阻尼振动 y(t)'); xlabel('t'); grid on;

subplot(2,2,4);
plot(freq(1:100), Y(1:100), 'm-');
title('频谱'); xlabel('Hz'); grid on;

print('-dpng', '-r120', 'octave_demo.png');
printf('图像已保存: octave_demo.png\n');

printf('\n===== 演示完成 =====\n');
