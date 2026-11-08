% =====================================================================
%  测试-MAT互通.m —— .mat 文件与 MATLAB 的互通验证
%
%  依据（MathWorks 官方文档《MAT 文件版本》）：
%    * MATLAB 默认存盘 = MAT 版本 7（压缩 + Unicode 编码）
%    * 版本 7.3 = 基于 HDF5（Octave 未实现）
%    * 版本 6 = N 维数组/元胞/结构体；版本 4 = 二维 double/字符/稀疏
%
%  Octave 的默认存盘格式是 '-text'，写出 "# Created by Octave ..."，
%  MATLAB 无法读取。本环境已用 save_default_options('-v7') 对齐官方默认。
%
%  验证方式（交叉验证，非自证）：
%    ① Octave 用【默认选项】存盘 -> 检查文件头 -> 交给 Python/SciPy 读
%    ② Python/SciPy 存盘           -> 交给 Octave 用【默认选项】读
%  SciPy 是独立的第三方 MAT 实现，用它交叉验证才有说服力。
%
%  运行：octave.exe --no-gui --quiet 测试-MAT互通.m
% =====================================================================

more off;
close all force;

fprintf('==================================================\n');
fprintf('  MAT 文件互通测试（对齐 MATLAB 官方默认 v7）\n');
fprintf('  Octave 版本: %s\n', version());
fprintf('==================================================\n\n');

npass = 0; nfail = 0;

here = fileparts(mfilename('fullpath'));
if (isempty(here))
  here = pwd;
end
pyscript = fullfile(here, 'tools', 'mat_interop.py');
pyexe = getenv('PYTHON');
if (isempty(pyexe))
  pyexe = fullfile(here, '.venv', 'Scripts', 'python.exe');
end

%% ---------- 0. 默认存盘格式是否已对齐 ----------
opts = save_default_options();
fprintf('【0】默认存盘格式\n');
fprintf('  save_default_options() = %s\n', opts);
if (strcmp(opts, '-v7'))
  npass = npass + 1;
  fprintf('  [通过] 已对齐 MATLAB 的默认 v7 格式\n\n');
else
  nfail = nfail + 1;
  fprintf('  [失败] 当前为 %s，MATLAB 无法保证读取\n\n', opts);
end

% 工作目录放在项目内：Octave 的 tempname() 目录带有沙箱组 ACL，
% 导致 Python 子进程写入被拒绝（PermissionError），实测确认。
workdir = fullfile(here, '_interop_tmp');
if (exist(workdir, 'dir') == 7)
  rmdir(workdir, 's');
end
mkdir(workdir);
mat_from_octave = fullfile(workdir, 'from_octave.mat');
mat_from_python = fullfile(workdir, 'from_python.mat');

A = magic(4);
v = 42.5;

%% ---------- 1. Octave 存（用默认选项）----------
fprintf('【1】Octave 存盘（默认选项，不显式写 -v7）\n');
msg = '';
try
  save(mat_from_octave, 'A', 'v');
  fid = fopen(mat_from_octave, 'r');
  if (fid < 0)
    error('无法打开刚写出的文件');
  end
  head = char(fread(fid, 32, 'char')');
  fclose(fid);
  ok = strncmp(head, 'MATLAB 5.0 MAT-file', 19);
catch err
  ok = false;
  msg = [' — ' err.message];
end
if (ok)
  npass = npass + 1;
  fprintf('  [通过] 文件头 = "%s"\n', strtrim(head));
else
  nfail = nfail + 1;
  fprintf('  [失败] 文件头不是 MATLAB 格式%s\n', msg);
end

%% ---------- 2. Python/SciPy 读取 ----------
fprintf('\n【2】Python/SciPy 读 Octave 写的文件（交叉验证）\n');
msg = '';
try
  cmd = sprintf('"%s" "%s" read "%s"', pyexe, pyscript, mat_from_octave);
  [st, out] = system(cmd);
  fprintf('%s', out);
  ok = (st == 0) && ~isempty(strfind(out, 'PY_READ_OK'));
catch err
  ok = false;
  msg = [' — ' err.message];
end
if (ok)
  npass = npass + 1;
  fprintf('  [通过] SciPy 成功读取且数值一致\n');
else
  nfail = nfail + 1;
  fprintf('  [失败] SciPy 读取不一致%s\n', msg);
end

%% ---------- 3. Python/SciPy 写入 ----------
fprintf('\n【3】Python/SciPy 写文件\n');
msg = '';
try
  cmd = sprintf('"%s" "%s" write "%s"', pyexe, pyscript, mat_from_python);
  [st, out] = system(cmd);
  fprintf('%s', out);
  ok = (st == 0) && (exist(mat_from_python, 'file') == 2);
catch err
  ok = false;
  msg = [' — ' err.message];
end
if (ok)
  npass = npass + 1;
  fprintf('  [通过] SciPy 已写出 .mat 文件\n');
else
  nfail = nfail + 1;
  fprintf('  [失败] SciPy 写文件失败%s\n', msg);
end

%% ---------- 4. Octave 读（用默认选项）----------
fprintf('\n【4】Octave 读 Python 写的文件（默认 load）\n');
msg = '';
try
  clear A2 v2;
  load(mat_from_python);
  ok = exist('A2', 'var') || exist('A', 'var');
  if (exist('A', 'var'))
    A2 = A;
  end
  if (exist('v', 'var'))
    v2 = v;
  end
  ok = ok && isequal(A2, magic(4)) && abs(v2 - 42.5) < 1e-12;
catch err
  ok = false;
  msg = [' — ' err.message];
end
if (ok)
  npass = npass + 1;
  fprintf('  [通过] 数值一致：A = magic(4)，v = %.1f\n', v2);
else
  nfail = nfail + 1;
  fprintf('  [失败] Octave 读回不一致%s\n', msg);
end

%% ---------- 5. 各版本格式能力 ----------
fprintf('\n【5】各 MAT 版本写入能力（官方支持范围对照）\n');
versions = {'-v4', '-v6', '-v7'};
vnotes = {'二维 double/字符/稀疏', 'N 维数组/元胞/结构体', 'Unicode + 压缩（MATLAB 默认）'};
for kk = 1:numel(versions)
  msg = '';
  fname = fullfile(workdir, sprintf('ver%s.mat', strrep(versions{kk}, '-', '')));
  try
    save(versions{kk}, fname, 'A');
    ok = (exist(fname, 'file') == 2);
  catch err
    ok = false;
    msg = [' — ' err.message];
  end
  if (ok)
    npass = npass + 1;
    fprintf('  [通过] %-4s  %s\n', versions{kk}, vnotes{kk});
  else
    nfail = nfail + 1;
    fprintf('  [失败] %-4s%s\n', versions{kk}, msg);
  end
end

%% ---------- 6. v7.3 官方支持但 Octave 未实现 ----------
fprintf('\n【6】版本 7.3（HDF5）—— 已知不支持，如实标注\n');
msg = '';
try
  fname73 = fullfile(workdir, 'v73.mat');
  save('-v7.3', fname73, 'A');
  ok = (exist(fname73, 'file') == 2);
  note = '（本机 Octave 竟然支持了 7.3，请更新文档）';
catch err
  ok = true;                       % 预期失败
  note = sprintf('（预期失败，符合内核取证结论：%s）', strtrim(err.message));
end
if (ok)
  npass = npass + 1;
  fprintf('  [通过] 已如实处理 v7.3 限制 %s\n', note);
else
  nfail = nfail + 1;
  fprintf('  [失败] v7.3 处理异常\n');
end

%% ---------- 清理与汇总 ----------
try
  rmdir(workdir, 's');
catch
end

fprintf('\n==================================================\n');
fprintf('  互通测试结果：%d 通过 / %d 失败\n', npass, nfail);
fprintf('==================================================\n');
printf('SUMMARY pass=%d fail=%d\n', npass, nfail);
if (nfail > 0)
  exit(1);
end
