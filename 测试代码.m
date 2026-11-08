% =====================================================================
%  测试代码.m  ——  科研 Octave 环境综合测试
%  作用：一次性验证 中文显示 / 矩阵运算 / 符号计算 / 信号处理 / 绘图
%
%  运行方式（任选其一）：
%    1) 在本图形界面的 Command Window 输入：  test_demo   然后回车
%    2) 点工具栏“打开文件”选中本文件后按 F5
%    3) 双击同目录下的  运行测试.bat
%    4) 命令行：octave.exe --no-gui --quiet 测试代码.m
% =====================================================================

more off;
close all force;
clc;

fprintf('==================================================\n');
fprintf('  科研 Octave 环境综合测试\n');
fprintf('  Octave 版本 : %s\n', version());
fprintf('  当前时间    : %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf('  当前目录    : %s\n', pwd);
fprintf('==================================================\n\n');

%% ---------- 1. 中文与矩阵运算 ----------
fprintf('【1】矩阵运算（线性代数）\n');
A = [4 -2 1; -2 4 -2; 1 -2 3];
b = [11; -16; 17];
x = A \ b;
fprintf('  求解 Ax=b，x = [%s]\n', num2str(x', 4));
fprintf('  特征值        = [%s]\n', num2str(eig(A)', 4));
fprintf('  行列式        = %.4f\n', det(A));
fprintf('  条件数        = %.4f\n', cond(A));
fprintf('  验证 A*x-b    = %.3e（应接近 0）\n\n', norm(A*x - b));

%% ---------- 2. 符号计算（SymPy 后端） ----------
fprintf('【2】符号计算（symbolic 包 + SymPy）\n');
try
  pkg load symbolic;
  syms t;
  f  = t^3 * sin(t);
  df = diff(f, t);                 % 一阶导
  I  = int(f, t, 0, pi);           % 定积分
  fprintf('  f(t)   = %s\n', char(f));
  fprintf("  f'(t)  = %s\n", char(df));
  fprintf('  ∫₀^π f dt = %s\n', char(I));
  fprintf('  [通过] 符号计算正常\n\n');
catch e
  fprintf('  [跳过] 符号计算不可用：%s\n\n', e.message);
end

%% ---------- 3. 信号处理 ----------
fprintf('【3】信号处理（FFT 频谱分析）\n');
fs = 1000;                       % 采样率 1 kHz
tt = 0 : 1/fs : 1 - 1/fs;
sig = 2*sin(2*pi*50*tt) + 0.5*sin(2*pi*120*tt) + 0.2*randn(size(tt));
Y = abs(fft(sig)) / numel(sig) * 2;
freq = (0:numel(sig)-1) * (fs/numel(sig));
half = 1 : floor(numel(Y)/2);     % 只看正频率半谱，避免镜像峰值
[~, idx] = sort(Y(half), 'descend');
fprintf('  采样点数        = %d\n', numel(sig));
fprintf('  能量最强频率    = %.1f Hz 与 %.1f Hz（应为 50 与 120）\n', ...
        freq(idx(1)), freq(idx(2)));
fprintf('  信号 RMS        = %.4f\n\n', sqrt(mean(sig.^2)));

%% ---------- 4. 统计 ----------
fprintf('【4】统计与随机数\n');
rand('seed', 42);                % 固定随机种子，结果可复现
data = 12 + 0.5*randn(1, 200);
fprintf('  样本数   = %d\n', numel(data));
fprintf('  均值     = %.4f\n', mean(data));
fprintf('  标准差   = %.4f\n', std(data));
fprintf('  中位数   = %.4f\n', median(data));
fprintf('  95%% 区间 = [%.4f, %.4f]\n\n', ...
        mean(data)-1.96*std(data), mean(data)+1.96*std(data));

%% ---------- 5. 绘图（中文标题，自动保存图片） ----------
fprintf('【5】绘图测试（中文标题 + 自动保存）\n');
try
  graphics_toolkit('qt');        % GUI 环境优先 Qt
catch
  % CLI 无 Qt 时回退 gnuplot，仍可出图
end

h = figure('name', '科研环境测试图', 'numbertitle', 'off', ...
           'position', [200 150 900 650]);

% 子图 1：阻尼振荡
subplot(2, 2, 1);
t2 = linspace(0, 6, 600);
y1 = exp(-0.4*t2) .* sin(2*pi*1.2*t2);
plot(t2, y1, 'b-', 'LineWidth', 1.8);
hold on;
plot(t2, exp(-0.4*t2), 'r--', t2, -exp(-0.4*t2), 'r--');
hold off; grid on;
title('阻尼振荡', 'FontName', 'Microsoft YaHei', 'FontSize', 12);
xlabel('时间 t (s)'); ylabel('幅值');
legend('y(t)', '包络线', 'location', 'northeast');

% 子图 2：二维曲面
subplot(2, 2, 2);
[X, Yg] = meshgrid(-2:0.1:2, -2:0.1:2);
Z = X .* exp(-X.^2 - Yg.^2);
surf(X, Yg, Z);
shading interp; colormap(hot);
title('二维曲面 z = x·e^{-x^2-y^2}', 'FontName', 'Microsoft YaHei', 'FontSize', 12);
xlabel('x'); ylabel('y'); zlabel('z');

% 子图 3：直方图
subplot(2, 2, 3);
hist(data, 20);
grid on;
title('数据分布直方图', 'FontName', 'Microsoft YaHei', 'FontSize', 12);
xlabel('数值'); ylabel('频数');

% 子图 4：频谱
subplot(2, 2, 4);
plot(freq(1:200), Y(1:200), 'm-', 'LineWidth', 1.5);
grid on;
title('频谱（前 200 个频点）', 'FontName', 'Microsoft YaHei', 'FontSize', 12);
xlabel('频率 (Hz)'); ylabel('幅值');

% 保存图片
outfile = fullfile(pwd, '测试结果.png');
print(h, '-dpng', '-r120', outfile);
if exist(outfile, 'file')
  fprintf('  [通过] 图片已保存：%s\n', outfile);
else
  fprintf('  [失败] 图片未生成\n');
end

%% ---------- 6. MATLAB 兼容层测试（compat 目录） ----------
fprintf('【6】MATLAB 兼容层（compat 目录）\n');
npass = 0; nfail = 0;

names = {'maxk 取最大 3 个', 'mink 取最小 3 个', ...
         'parula 尺寸正确', 'parula 值域合法', ...
         'contains 命中', 'contains 未命中', 'contains 忽略大小写', ...
         'matches 精确匹配', 'count 计数', 'split 切分'};
preds = { @() isequal(maxk([3 1 4 1 5 9], 3), [9 5 4]), ...
          @() isequal(mink([3 1 4 1 5 9], 3), [1 1 3]), ...
          @() isequal(size(parula(16)), [16 3]), ...
          @() all(parula(32)(:) >= 0 & parula(32)(:) <= 1), ...
          @() contains('hello world', 'world'), ...
          @() ~contains('hello', 'xyz'), ...
          @() contains('Hello', 'HEL', 'IgnoreCase', true), ...
          @() isequal(matches({'a', 'b', 'c'}, 'b'), [false true false]), ...
          @() count('banana', 'an') == 2, ...
          @() isequal(split('a,b,c', ','), {'a', 'b', 'c'}) };

for k = 1:numel(names)
  msg = '';
  try
    ok = preds{k}();
  catch e
    ok = false;
    msg = [' — ' e.message];
  end
  if (ok)
    npass = npass + 1;
    fprintf('  [通过] %s\n', names{k});
  else
    nfail = nfail + 1;
    fprintf('  [失败] %s%s\n', names{k}, msg);
  end
end

% maxk 索引是否正确
msg = '';
try
  [b, idx] = maxk([3 1 4 1 5 9], 2);
  ok = isequal(b, [9 5]) && isequal(idx, [6 5]);
catch e
  ok = false; msg = [' — ' e.message];
end
if (ok)
  npass = npass + 1; fprintf('  [通过] maxk 同时返回索引\n');
else
  nfail = nfail + 1; fprintf('  [失败] maxk 索引%s\n', msg);
end

% readmatrix / writematrix 往返
msg = '';
try
  csvfile = [tempname() '.csv'];
  writematrix(magic(4), csvfile);
  Mround = readmatrix(csvfile);
  ok = isequal(Mround, magic(4));
  delete(csvfile);
catch e
  ok = false; msg = [' — ' e.message];
end
if (ok)
  npass = npass + 1; fprintf('  [通过] writematrix/readmatrix 往返一致\n');
else
  nfail = nfail + 1; fprintf('  [失败] 矩阵文件往返%s\n', msg);
end

% tiledlayout / nexttile / sgtitle
msg = '';
try
  hlay = figure('visible', 'off');
  tiledlayout(1, 2);
  ax1 = nexttile();
  ax2 = nexttile();
  sgtitle('兼容层布局测试');
  ok = (numel(ax1) > 0) && (numel(ax2) > 0);
  close(hlay);
catch e
  ok = false; msg = [' — ' e.message];
end
if (ok)
  npass = npass + 1; fprintf('  [通过] tiledlayout/nexttile/sgtitle\n');
else
  nfail = nfail + 1; fprintf('  [失败] 平铺布局%s\n', msg);
end

fprintf('  兼容层结果：%d 通过 / %d 失败\n\n', npass, nfail);

%% ---------- 7. 完成 ----------
fprintf('\n==================================================\n');
fprintf('  测试全部完成！\n');
fprintf('  若图上中文正常、数值合理，说明环境完全可用。\n');
fprintf('==================================================\n');
