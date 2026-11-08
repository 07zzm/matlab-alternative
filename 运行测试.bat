@echo off
chcp 936 >nul
REM =====================================================================
REM  run the full environment test (测试代码.m)
REM  covers: Chinese output / matrix / symbolic / signal / statistics /
REM          plotting / MATLAB compatibility layer
REM
REM  编码策略：本文件 GBK 保存，开头 chcp 936 锁定；跑 Octave 前切
REM  65001（Octave 只输出 UTF-8）；其后提示行一律 ASCII。
REM =====================================================================
setlocal
set "OCTAVE_BIN=C:\Users\Administrator\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\bin"
cd /d "%~dp0"

if not exist "%OCTAVE_BIN%\octave.exe" (
    echo [错误] 未找到 Octave: %OCTAVE_BIN%\octave.exe
    pause
    exit /b 1
)

echo.
echo  ================== 正在运行综合测试 ==================
echo    中文显示 / 矩阵运算 / 符号计算 / 信号处理 / 统计
echo    绘图（中文标题）/ MATLAB 兼容层
echo    结果图将保存为本目录下的  测试结果.png
echo.
chcp 65001 >nul
"%OCTAVE_BIN%\octave.exe" --no-gui --quiet "%~dp0test_demo.m"
echo.
echo  ======================================================
echo   Test finished.  Expect "13 通过 / 0 失败" above and
echo   the result image saved in this folder.
echo  ======================================================
pause
endlocal
