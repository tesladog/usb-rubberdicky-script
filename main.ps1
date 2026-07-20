# Set window parameters
$Host.UI.RawUI.WindowTitle = "Brogun's Specialized Tech Toolkit"

do {
    Clear-Host
    
    # Check if the current session has administrative privileges
    $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "             SPECIALIZED TECH TOOLKIT             " -ForegroundColor White -BackgroundColor Blue
    Write-Host "==================================================" -ForegroundColor Cyan
    
    # Display the current Administrator privileges bar
    if ($IsAdmin) {
        Write-Host " STATUS: RUNNING AS ADMINISTRATOR (FULL PRIVILEGES)" -ForegroundColor Green -BackgroundColor Black
    } else {
        Write-Host " STATUS: RUNNING AS STANDARD USER (LIMITED)" -ForegroundColor Red -BackgroundColor Black
    }
    
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host " Enter single numbers or comma-separated lists (e.g., 2,4)" -ForegroundColor Gray
    Write-Host ""
    Write-Host " [1] Elevate: Reopen This Toolkit as Administrator"
    Write-Host " [2] WinGet: Update All Apps ----------- (Requires Admin)"
    Write-Host " [3] Accounts: Configure Built-in Admin - (Requires Admin)"
    Write-Host " [4] OS Repair: Run DISM & SFC Recovery - (Requires Admin)"
    Write-Host " [5] Activation: Windows Suite (MAS) ---- (Requires Admin)"
    Write-Host " [6] Hardware: Restart Directly into BIOS (Requires Admin)"
    Write-Host " [7] Exit Toolkit"
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $RawInput = Read-Host "Select options to run"
    
    # Split the choices by commas and remove extra spaces
    $Choices = $RawInput.Split(',').ForEach({ $_.Trim() })

    # CRITICAL FIX: If '1' is anywhere in the list, completely ignore other options and just elevate
    if ($Choices -contains '1') {
        Clear-Host
        Write-Host "--- [1] Requesting Administrative Elevation ---" -ForegroundColor Yellow
        if ($IsAdmin) {
            Write-Host "The script is already running with full administrator privileges." -ForegroundColor Green
            Start-Sleep -Seconds 2
        } else {
            if ($Choices.Count -gt 1) {
                Write-Host "Notice: Other options dropped. Please re-enter choices in the elevated window." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }

            Write-Host "Creating local elevation stager..." -ForegroundColor Gray
            
            # Define paths for the temporary stager file
            $TempDir = "$env:USERPROFILE\AppData\Local\Temp"
            $TempFile = "$TempDir\elevate_stager.ps1"
            
            # Write a mini script text that downloads and runs your main toolkit file, then deletes itself
            $StagerContent = @"
            Start-Sleep -Seconds 1
            iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/tesladog/usb-rubberdicky-script/main/main.ps1')
            Remove-Item -Path '$TempFile' -Force -ErrorAction SilentlyContinue
"@
            
            # Output the file safely to the drive
            Out-File -FilePath $TempFile -InputObject $StagerContent -Encoding utf8 -Force
            
            Write-Host "Launching elevated console session..." -ForegroundColor Green
            # Tell Windows to execute our local temporary stager script file as Admin
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$TempFile`"" -Verb RunAs
            exit
        }
    } else {
        # Process non-elevation choices normally
        foreach ($Choice in $Choices) {
            if ($Choice -eq '7') {
                Clear-Host
                Write-Host "Closing toolkit session..." -ForegroundColor Red
                Start-Sleep -Seconds 1
                exit
            }

            switch ($Choice) {
                2 {
                    Clear-Host
                    Write-Host "--- [2] Running WinGet Package Upgrades ---" -ForegroundColor Green
                    if (-not $IsAdmin) { Write-Host "WARNING: Running without Admin. Some app updates may fail." -ForegroundColor Yellow }
                    Write-Host "Fetching repository upgrades (including unrecognized versions)..." -ForegroundColor Gray
                    winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
                    Write-Host "`nWinGet execution cycle finished." -ForegroundColor Green
                    Write-Host "Press any key to proceed..."
                    [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                }
                3 {
                    Clear-Host
                    Write-Host "--- [3] Configure Built-In Administrator Account ---" -ForegroundColor Green
                    if (-not $IsAdmin) {
                        Write-Host "ERROR: This operation requires Administrator privileges." -ForegroundColor Red
                        Write-Host "Press any key to skip..."
                        [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                        break
                    }
                    
                    $PasswordInput = Read-Host "Enter new password for Administrator (Leave blank for no password)"
                    
                    Write-Host "Enabling account and applying credentials..." -ForegroundColor Gray
                    & net user Administrator /active:yes
                    
                    if ([string]::IsNullOrEmpty($PasswordInput)) {
                        & net user Administrator ""
                        Write-Host "Built-in Administrator account enabled with NO PASSWORD." -ForegroundColor Yellow
                    } else {
                        & net user Administrator $PasswordInput
                        Write-Host "Built-in Administrator account enabled with custom password." -ForegroundColor Green
                    }
                    
                    Write-Host "Press any key to proceed..."
                    [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                }
                4 {
                    Clear-Host
                    Write-Host "--- [4] Windows Deployment Image & System File Repair ---" -ForegroundColor Green
                    if (-not $IsAdmin) {
                        Write-Host "ERROR: This operation requires Administrator privileges." -ForegroundColor Red
                        Write-Host "Press any key to skip..."
                        [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                        break
                    }
                    
                    Write-Host "Step 1/2: Checking operating system image health via DISM..." -ForegroundColor Yellow
                    DISM /Online /Cleanup-Image /RestoreHealth
                    
                    Write-Host "`nStep 2/2: Verifying protected system files via SFC..." -ForegroundColor Yellow
                    sfc /scannow
                    
                    Write-Host "`nOS integrity scanning cycle completed." -ForegroundColor Green
                    Write-Host "Press any key to proceed..."
                    [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                }
                5 {
                    Clear-Host
                    Write-Host "==================================================" -ForegroundColor Yellow
                    Write-Host "            LEGAL & COMPLIANCE DISCLAIMER          " -ForegroundColor Black -BackgroundColor Yellow
                    Write-Host "==================================================" -ForegroundColor Yellow
                    Write-Host " Unauthorized software activation or bypass of licensing mechanisms"
                    Write-Host " may violate local copyright laws, organizational compliance structures,"
                    Write-Host " and End User License Agreements (EULA)."
                    Write-Host ""
                    Write-Host " This utility launches an external script hosted by the open-source"
                    Write-Host " Massgrave community. Use exclusively in authorized or evaluation environments."
                    Write-Host "==================================================" -ForegroundColor Yellow
                    Write-Host ""
                    
                    if (-not $IsAdmin) {
                        Write-Host "ERROR: MAS requires administrative permissions to modify licensing headers." -ForegroundColor Red
                        Write-Host "Press any key to skip..."
                        [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                        break
                    }
                    
                    $Confirm = Read-Host "Type 'AGREE' to proceed with the activation utility"
                    if ($Confirm -eq "AGREE") {
                        Clear-Host
                        Write-Host "Launching Microsoft Activation Scripts (MAS)..." -ForegroundColor Green
                        irm https://get.activated.win | iex
                    }
                }
                6 {
                    Clear-Host
                    Write-Host "--- [6] Restarting Device into UEFI/BIOS Firmware ---" -ForegroundColor Green
                    if (-not $IsAdmin) {
                        Write-Host "ERROR: Changing hardware power states requires Administrator privileges." -ForegroundColor Red
                        Write-Host "Press any key to skip..."
                        [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                        break
                    }
                    
                    Write-Host "Preparing hardware environment for instant firmware loop..." -ForegroundColor Yellow
                    Write-Host "The workstation will forcefully close apps and restart in 3 seconds." -ForegroundColor Red
                    Start-Sleep -Seconds 3
                    
                    # Executes native Windows UEFI firmware boot directive
                    shutdown /r /fw /f /t 0
                }
                Default {
                    Write-Host "Selection '$Choice' is invalid or not recognized." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
        }
    }
} while ($true)
