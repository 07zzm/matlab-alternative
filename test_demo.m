% =====================================================================
%  test_demo.m —— 综合测试的英文入口（推荐在 Command Window 里输入）
%
%  用法：在 Command Window 输入
%        test_demo
%  然后回车即可。它会调用同目录下的 测试代码.m。
% =====================================================================
thisdir = fileparts(mfilename('fullpath'));
run(fullfile(thisdir, '测试代码.m'));
clear thisdir;
