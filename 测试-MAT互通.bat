@echo off
chcp 936 >nul
REM =====================================================================
REM  MAT 文件互通测试（Octave <-> Python/SciPy）
REM  依据 MathWorks 官方文档《MAT 文件版本》：MATLAB 默认存盘为 v7
REM
REM  编码策略：本文件 GBK 保存并锁定 936；跑 Octave 前切 65001。
REM  注意：chcp 之后传给 Octave 的文件名必须是 ASCII（cmd 会按新代码页
REM  重读后续内容，中文文件名会被解析坏），所以这里调用 test_mat_interop.m。
REM =====================================================================
setlocal
set "OCTAVE_BIN=C:\Users\Administrator\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\bin"
set "PYTHON=%~dp0.venv\Scripts\python.exe"
cd /d "%~dp0"

if not exist "%OCTAVE_BIN%\octave.exe" (
    echo [错误] 未找到 Octave: %OCTAVE_BIN%\octave.exe
    pause
    exit /b 1
)

echo.
echo  ============== MAT 文件互通测试 ==============
echo    Octave 存 -^> SciPy 读；SciPy 存 -^> Octave 读
echo    同时验证 v4 / v6 / v7 写入与 v7.3 限制
echo.
chcp 65001 >nul
"%OCTAVE_BIN%\octave.exe" --no-gui --quiet "%~dp0test_mat_interop.m"
echo.
echo  ==============================================
echo   Expect "SUMMARY pass=9 fail=0" above.
echo  ==============================================
pause
endlocal
