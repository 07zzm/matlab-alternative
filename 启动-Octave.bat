@echo off
chcp 936 >nul
REM =====================================================================
REM  GNU Octave 11.3.0 launcher  --  MATLAB-compatible free alternative
REM
REM  craft-anything evidence (kernel forensics) shows Octave ships its own
REM  MATLAB compatibility subsystem:
REM     * --traditional      closer MATLAB variable / syntax behaviour
REM     * MAT-file v5 read+write, MEX API, classdef parser
REM  The local compat\ folder fills the remaining gaps (maxk, parula, ...).
REM
REM  编码策略：本文件 GBK 保存，开头 chcp 936 锁定；仅 CLI 启动前切
REM  65001（Octave 输出 UTF-8），菜单中文全部在此之前打印。
REM =====================================================================
setlocal
set "OCTAVE_BIN=C:\Users\Administrator\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\bin"

if not exist "%OCTAVE_BIN%\octave.exe" (
    echo [错误] 未找到 Octave: %OCTAVE_BIN%\octave.exe
    pause
    exit /b 1
)

echo.
echo  ==========================================================
echo   GNU Octave 11.3.0 - 开源 MATLAB 替代
echo   ----------------------------------------------------------
echo    [1] 图形界面 GUI             （推荐，有编辑器/变量面板）
echo    [2] 命令行 CLI               （轻量快速）
echo    [3] GUI + MATLAB 兼容模式    （--traditional）
echo    [4] CLI + MATLAB 兼容模式    （--traditional）
echo   ----------------------------------------------------------
echo    MATLAB 兼容模式会调整变量与语法行为，让旧 .m 脚本更接近
echo    MATLAB 的运行结果；日常使用选 1 即可。
echo  ==========================================================
echo.
set /p CHOICE=请输入 1-4 (默认 1): 

if "%CHOICE%"=="2" goto CLI
if "%CHOICE%"=="3" goto GUI_TRAD
if "%CHOICE%"=="4" goto CLI_TRAD

:GUI
"%OCTAVE_BIN%\octave.exe" --gui
goto END

:GUI_TRAD
echo [提示] 正在以 MATLAB 兼容模式 (--traditional) 启动图形界面 ...
"%OCTAVE_BIN%\octave.exe" --gui --traditional
goto END

:CLI
chcp 65001 >nul
"%OCTAVE_BIN%\octave-cli.exe"
goto END

:CLI_TRAD
echo [提示] 正在以 MATLAB 兼容模式 (--traditional) 启动命令行 ...
chcp 65001 >nul
"%OCTAVE_BIN%\octave-cli.exe" --traditional
goto END

:END
endlocal
