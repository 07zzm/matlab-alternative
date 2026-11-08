% =====================================================================
%  verify_env.m —— 科研 Octave 环境全链路自测
%  运行: octave-cli.exe --no-gui --quiet verify_env.m
% =====================================================================
more off;
fprintf('==================================================\n');
fprintf('  Octave 科研环境自测  (Octave %s)\n', version());
fprintf('==================================================\n\n');

pass = 0; fail = 0;

% ---- 核心数值 ----
fprintf('--- 核心数值能力 ---\n');
A = [4 -2 1; -2 4 -2; 1 -2 3];
x = A \ [11; -16; 17];
printf('  A\\b 解 = %s\n', mat2str(x', 4));
printf('  eig    = %s\n', mat2str(eig(A)', 5));

% ---- 扩展包 ----
fprintf('\n--- 扩展包功能 ---\n');
try
  pkg load control;
  sys = tf([1], [1 2 1]);
  [y, t] = step(sys, 5);
  printf('  control: 二阶系统阶跃响应末端 = %.4f\n', y(end));
  printf('  [OK]   control 包\n'); pass = pass + 1;
catch e
  printf('  [FAIL] control: %s\n', e.message); fail = fail + 1;
end

try
  pkg load signal;
  fs = 1000; t2 = 0:1/fs:0.5;
  s = sin(2*pi*50*t2) + 0.5*sin(2*pi*120*t2);
  [b, a] = butter(4, 80/(fs/2));
  sf = filtfilt(b, a, s);
  printf('  signal: 滤波前 RMS=%.4f, 滤波后 RMS=%.4f\n', ...
         sqrt(mean(s.^2)), sqrt(mean(sf.^2)));
  printf('  [OK]   signal 包\n'); pass = pass + 1;
catch e
  printf('  [FAIL] signal: %s\n', e.message); fail = fail + 1;
end

try
  pkg load statistics;
  p = normpdf(0, 0, 1);
  [h, pv] = ttest2(randn(1,50), randn(1,50)+0.5);
  printf('  statistics: normpdf(0)=%.5f, ttest p=%.4f\n', p, pv);
  printf('  [OK]   statistics 包\n'); pass = pass + 1;
catch e
  printf('  [FAIL] statistics: %s\n', e.message); fail = fail + 1;
end

try
  pkg load optim;
  fobj = @(v) (v(1)-3)^2 + (v(2)+1)^2;
  [xo, fo] = fminunc(fobj, [0 0]);
  printf('  optim: 最优点 = %s, 值 = %.5f\n', mat2str(xo, 4), fo);
  printf('  [OK]   optim 包\n'); pass = pass + 1;
catch e
  printf('  [FAIL] optim: %s\n', e.message); fail = fail + 1;
end

try
  pkg load symbolic;
  syms xs;
  df = diff(sin(xs)*exp(-xs), xs);
  printf('  symbolic: d/dx 结果 = %s\n', char(df));
  printf('  [OK]   symbolic 包\n'); pass = pass + 1;
catch e
  printf('  [FAIL] symbolic: %s\n', e.message); fail = fail + 1;
end

try
  pkg load image;
  img = uint8(rand(64, 64) * 255);
  e2 = edge(img, 'Canny');
  printf('  image: Canny 边缘像素数 = %d\n', sum(e2(:)));
  printf('  [OK]   image 包\n'); pass = pass + 1;
catch e
  printf('  [FAIL] image: %s\n', e.message); fail = fail + 1;
end

try
  pkg load io;
  tmpdir = tempname();
  mkdir(tmpdir);
  fcsv = fullfile(tmpdir, 'test.csv');
  dlmwrite(fcsv, magic(5), ',');
  M = dlmread(fcsv, ',');
  printf('  io: CSV 往返读写 magic(5) 校验 = %d\n', isequal(M, magic(5)));
  printf('  [OK]   io 包\n'); pass = pass + 1;
  rmdir(tmpdir, 's');
catch e
  printf('  [FAIL] io: %s\n', e.message); fail = fail + 1;
end

% ---- 绘图（qt 渲染，无需可见窗口）----
fprintf('\n--- 绘图 ---\n');
try
  graphics_toolkit('qt');
  f = figure('visible', 'off');
  subplot(1,2,1); plot(t, y, 'b-', 'LineWidth', 1.5); grid on; title('Step Response');
  subplot(1,2,2); plot(t2, s, 'r-', t2, sf, 'k-', 'LineWidth', 1.2); grid on; title('Filter');
  print(f, '-dpng', '-r110', 'octave_verify.png');
  close(f);
  if exist('octave_verify.png', 'file')
    printf('  [OK]   绘图已保存 octave_verify.png\n'); pass = pass + 1;
  else
    printf('  [FAIL] 图未生成\n'); fail = fail + 1;
  end
catch e
  printf('  [FAIL] 绘图: %s\n', e.message); fail = fail + 1;
end

fprintf('\n==================================================\n');
printf('  结果: %d 通过 / %d 失败\n', pass, fail);
fprintf('==================================================\n');
% ASCII 摘要行：供 .bat 用 findstr 匹配。
% 原因：批处理文件是 GBK，而 Octave 输出 UTF-8，用中文做 findstr 永远匹配不到。
printf('SUMMARY pass=%d fail=%d\n', pass, fail);
if fail > 0
  exit(1);
end
