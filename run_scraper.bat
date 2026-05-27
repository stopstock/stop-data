@echo off
cd /d "C:\Users\testuser\Documents\stop-data"

set LOGFILE=scraper_log.txt
set PYTHON=C:\Users\testuser\AppData\Local\Python\bin\python.exe
set GIT=C:\Program Files\Git\cmd\git.exe
set PATH=C:\Program Files\Git\cmd;%PATH%

echo === %DATE% %TIME% === >> %LOGFILE%

"%PYTHON%" scraper.py >> %LOGFILE% 2>&1
if %ERRORLEVEL% neq 0 (
    echo SKIP: scraper failed exit %ERRORLEVEL% >> %LOGFILE%
    echo. >> %LOGFILE%
    exit /b 0
)

"%GIT%" add data/stock_data.json
"%GIT%" diff --staged --quiet
if %ERRORLEVEL% neq 0 (
    for /f %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set DATESTR=%%d
    "%GIT%" commit -m "Update stock data: %DATESTR%"
    "%GIT%" pull --rebase origin main
    "%GIT%" push
    echo PUSHED: %DATESTR% >> %LOGFILE%
) else (
    echo NO CHANGE >> %LOGFILE%
)

echo. >> %LOGFILE%
