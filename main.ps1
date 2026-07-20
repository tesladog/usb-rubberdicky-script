# Set window parameters
$Host.UI.RawUI.WindowTitle = "Brogun's Admin Toolkit"

# Establish the persistent loop
do {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "               SCHOOL TECH TOOLKIT                " -ForegroundColor White -BackgroundColor Blue
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host " [1] Asset Prep: View PC Identity & Serial Number"
    Write-Host " [2] Network Diagnostics: Check Gateway & DNS"
    Write-Host " [3] Speed Optimization: Clear System Temp Caches"
    Write-Host " [4] Maintenance: Open Device & Disk Manager"
    Write-Host " [5] Exit Toolkit"
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $Choice = Read-Host "Select an option (1-5)"

    switch ($Choice) {
        1 {
            Clear-Host
            Write-Host "--- Device Identity Info ---" -ForegroundColor Green
            Write-Host "Computer Name:  $env:COMPUTERNAME" -ForegroundColor Yellow
            Write-Host "Current User:   $env:USERNAME" -ForegroundColor Yellow
            
            # Grabs the actual hardware serial number from the BIOS (great for matching inventory tags)
            $Serial = (Get-CimInstance Win32_Bios).SerialNumber
            Write-Host "Hardware Serial: $Serial" -ForegroundColor Yellow
            
            Write-Host "`nPress any key to return to main menu..."
            [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        2 {
            Clear-Host
            Write-Host "--- Local Network Configuration ---" -ForegroundColor Green
            Get-NetIPAddress -AddressFamily IPv4 | Where-Object InterfaceMetric -ne 256 | Select-Object InterfaceAlias, IPAddress
            Write-Host ""
            Write-Host "Testing connectivity to core gateway..." -ForegroundColor Gray
            Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet
            
            Write-Host "`nPress any key to return to main menu..."
            [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        3 {
            Clear-Host
            Write-Host "--- Clearing System Cache Storage ---" -ForegroundColor Yellow
            # Clean local workstation temporary files quickly
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Cache space optimization complete!" -ForegroundColor Green
            Start-Sleep -Seconds 2
        }
        4 {
            Clear-Host
            Write-Host "--- Launching Management Interfaces ---" -ForegroundColor Green
            Write-Host "Opening Device Manager..." -ForegroundColor Gray
            Start-Process devmgmt.msc
            Write-Host "Opening Disk Management..." -ForegroundColor Gray
            Start-Process diskmgmt.msc
            Start-Sleep -Seconds 1
        }
        5 {
            Clear-Host
            Write-Host "Closing toolkit session..." -ForegroundColor Red
            Start-Sleep -Seconds 1
            $Running = $false
        }
        Default {
            Write-Host "Invalid option choice. Try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($Choice -ne 5)
