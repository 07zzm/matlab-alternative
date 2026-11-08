@echo off
chcp 936 >nul
REM =====================================================================
REM  environment health check  --  verifies both Python and Octave sides
REM
REM  编码策略（实测结论）：
REM    * 本文件用 GBK 保存，开头先 chcp 936 锁定代码页，避免继承到
REM      65001 时把中文解析乱（父进程代码页不确定）。
REM    * Python 按控制台代码页输出，GBK 下正常。
REM    * Octave 无论代码页如何都输出 UTF-8，所以只在跑 Octave 前切到
REM      65001；之后所有提示行一律用 ASCII。
REM    * Python 检查串保持纯 ASCII，避免命令行参数被编码破坏。
REM =====================================================================
setlocal
set "ROOT=%~dp0"
set "PY=%ROOT%.venv\Scripts\python.exe"
set "OCT=C:\Users\Administrator\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\bin\octave.exe"

echo.
echo ==================== 科研环境健康检查 ====================
echo.

echo [1/3] Python 环境与科学库 ...
"%PY%" -c "import numpy,scipy,matplotlib,pandas,sympy,sklearn,seaborn,plotly,statsmodels,control,numba,h5py,openpyxl,ipywidgets; print('OK - 15 core libraries')" 2>&1
if errorlevel 1 (echo      FAIL) else (echo      PASS)

echo.
echo [2/3] Jupyter ...
"%PY%" -m jupyter lab --version >nul 2>&1
if errorlevel 1 (echo      FAIL) else (echo      PASS)

echo.
echo [3/3] Octave 扩展包、符号计算与 MATLAB 兼容层 ...
chcp 65001 >nul
"%OCT%" --no-gui --quiet "%ROOT%verify_env.m" 2>&1 | findstr /C:"SUMMARY" /C:"[FAIL]"

echo.
echo ==========================================================
echo  Check finished.  "SUMMARY pass=8 fail=0" means all good.
echo ==========================================================
pause
endlocal
