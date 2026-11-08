@echo off
REM 启动面板 —— 双击这个打开 GUI 入口
setlocal
cd /d "%~dp0"
start "" ".venv\Scripts\pythonw.exe" "启动面板.py"
endlocal