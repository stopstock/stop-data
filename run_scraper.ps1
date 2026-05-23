# stop-data 自動スクレイプ & プッシュ スクリプト
# Windows タスクスケジューラから呼び出される

$repoDir  = "C:\Users\testuser\Documents\stop-data"
$logFile  = "$repoDir\scraper_log.txt"
$python   = "C:\Users\testuser\AppData\Local\Python\bin\python.exe"
$gitExe   = "C:\Program Files\Git\cmd\git.exe"

$env:PATH = "C:\Program Files\Git\cmd;C:\Program Files\Git\bin;" + $env:PATH

Set-Location $repoDir

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"=== $timestamp ===" | Add-Content $logFile

# scraper 実行
$output = & $python scraper.py 2>&1 | Out-String
$exitCode = $LASTEXITCODE
$output | Add-Content $logFile

if ($exitCode -ne 0) {
    "SKIP: スクレイパー失敗 (exit $exitCode)" | Add-Content $logFile
    "" | Add-Content $logFile
    exit 0
}

# git commit & push
& $gitExe add data/stock_data.json
& $gitExe diff --staged --quiet
if ($LASTEXITCODE -ne 0) {
    $dateStr = Get-Date -Format "yyyy-MM-dd"
    & $gitExe commit -m "Update stock data: $dateStr"
    & $gitExe pull --rebase origin main
    & $gitExe push
    "PUSHED: $dateStr" | Add-Content $logFile
} else {
    "NO CHANGE: データ変更なし" | Add-Content $logFile
}

"" | Add-Content $logFile
