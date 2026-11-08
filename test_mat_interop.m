% =====================================================================
%  test_mat_interop.m —— MAT 互通测试的 ASCII 入口
%
%  为什么要这个文件：
%    启动批处理在调用 Octave 前会 chcp 65001（Octave 只输出 UTF-8），
%    而 cmd.exe 会按新代码页重新读取批处理后续内容，导致写在 chcp
%    之后的中文文件名被解析坏掉，报
%        error: no such file, '...\����-MAT��ͨ.m'
%    所以：批处理里传给 Octave 的文件名必须是 ASCII。
%    中文名脚本照旧保留，改由 Octave 内部用 run() 调用（Octave 自己
%    解析目录，不经过 cmd 的代码页）。
%
%  用法：在 Command Window 输入   test_mat_interop
% =====================================================================
thisdir = fileparts(mfilename('fullpath'));
run(fullfile(thisdir, '测试-MAT互通.m'));
clear thisdir;
