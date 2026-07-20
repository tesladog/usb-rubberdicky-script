# Clear the screen for a clean look
Clear-Host

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "       BROGUN'S TECH TOOLKIT MENU         " -ForegroundColor White -BackgroundColor Blue
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1. View System & Network Information"
Write-Host "2. Run Quick System Cache Cleanup"
Write-Host "3. Open Device Manager & Event Viewer"
Write-Host "4. Exit"
Write-Host "==========================================" -ForegroundColor Cyan

$choice = Read-Host "Select an option (1-4)"

switch ($choice) {
    1 {
        Clear-Host
        Write-Host "--- Network & System Info ---" -ForegroundColor Green
        Get-NetIPAddress -AddressFamily IPv4 | Select-Object IPAddress, InterfaceAlias
        Write-Host "`nPress any key to exit..."
        [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    2 {
        Clear-Host
        Write-Host "--- Cleaning Temporary Files ---" -ForegroundColor Yellow
        # Insert cleanup commands here (e.g., clearing temp folders)
        Write-Host "Cleanup complete!" -ForegroundColor Green
        Start-Sleep -Seconds 3
    }
    3 {
        Clear-Host
        Write-Host "--- Opening Administrative Consoles ---" -ForegroundColor Green
        Start-Process devmgmt.msc
        Start-Process eventvwr.msc
    }
    4 {
        Write-Host "Exiting..." -ForegroundColor Red
        Exit
    }
    Default {
        Write-Host "Invalid selection. Exiting." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}
