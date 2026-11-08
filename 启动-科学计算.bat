@echo off
REM =====================================================================
REM  开源科研计算环境 - Jupyter Lab 启动器  (彩色终端版)
REM =====================================================================
setlocal EnableDelayedExpansion
set "ROOT=%~dp0"
set "PY=%ROOT%.venv\Scripts\python.exe"

if not exist "%PY%" (
    echo [!] 未找到 Python 环境, 请先看 研究环境说明.md
    pause & exit /b 1
)

REM 彩色输出
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "M=!ESC![35m" & set "B=!ESC![36m" & set "G=!ESC![32m" & set "Y=!ESC![33m" & set "C=!ESC![38;5;45m" & set "W=!ESC![0m"

REM 端口自适应
set "PORT=8888"
netstat -ano 2>nul | findstr ":8888 " | findstr LISTENING >nul && set "PORT=8889"

cls
echo !C!╔══════════════════════════════════════════════════════════╗!W!
echo !C!║!W!   开源科研计算环境        替代 MATLAB                  !C!║!W!
echo !C!╠══════════════════════════════════════════════════════════╣!W!
echo !C!║!W!   !B!数值/矩阵!W!  NumPy / SciPy  *  !M!符号计算!W!  SymPy          !C!║!W!
echo !C!║!W!   !B!绘图!W!      Matplotlib / Seaborn / Plotly      !C!║!W!
echo !C!║!W!   !B!数据!W!      Pandas / Openpyxl / h5py           !C!║!W!
echo !C!║!W!   !B!专业!W!      scikit-learn / control / statsmodels !C!║!W!
echo !C!╚══════════════════════════════════════════════════════════╝!W!
echo.

REM 状态检查
set "OK=!G![OK]!W!" & set "BAD=!Y!…!W!"
<nul set /p "= [!OK!] Python "
"%PY%" -c "print('OK')" 2>nul
<nul set /p "= [!OK!] Jupyter "
"%PY%" -m jupyter lab --version 2>nul

echo.
echo !B!>!W!  Jupyter Lab 正在启动 (端口 !PORT!) ...
echo !B!>!W!  浏览器即将打开:  !C!http://localhost:!PORT!/lab!W!
echo !B!>!W!  关闭本窗口 = 停止服务
echo.

start "" http://localhost:%PORT%/lab

"%PY%" -m jupyter lab --no-browser --port %PORT% --ServerApp.token=""

endlocal