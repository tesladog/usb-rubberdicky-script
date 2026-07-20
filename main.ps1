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
    Write-Host " [3] Accounts: User Profile Management - (Requires Admin)"
    Write-Host " [4] OS Repair: Run DISM & SFC Recovery - (Requires Admin)"
    Write-Host " [5] Activation: Windows Suite (MAS) ---- (Requires Admin)"
    Write-Host " [6] Power: Shut Down & Firmware Actions - (User/Admin Friendly)"
    Write-Host " [7] Exit Toolkit"
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $RawInput = Read-Host "Select options to run"
    
    # Split the choices by commas and remove extra spaces
    $Choices = $RawInput.Split(',').ForEach({ $_.Trim() })

    # Track if we actually executed any tasks that need a pause at the end
    $RanTasks = $false

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
                    $RanTasks = $true
                    Write-Host "--- [2] Running WinGet Package Upgrades ---" -ForegroundColor Green
                    if (-not $IsAdmin) { Write-Host "WARNING: Running without Admin. Some app updates may fail." -ForegroundColor Yellow }
                    Write-Host "Fetching repository upgrades (including unrecognized versions)..." -ForegroundColor Gray
                    winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements
                    Write-Host "`nWinGet execution cycle finished." -ForegroundColor Green
                }
                3 {
                    if (-not $IsAdmin) {
                        Clear-Host
                        Write-Host "ERROR: User management operations require Administrator privileges." -ForegroundColor Red
                        Start-Sleep -Seconds 2
                        break
                    }
                    
                    $UserMenuLoop = $true
                    while ($UserMenuLoop) {
                        Clear-Host
                        Write-Host "==================================================" -ForegroundColor Cyan
                        Write-Host "         [3] USER ACCOUNT MANAGEMENT MENU         " -ForegroundColor White -BackgroundColor Blue
                        Write-Host "==================================================" -ForegroundColor Cyan
                        Write-Host " [A] List All Local User Accounts"
                        Write-Host " [B] Activate Built-in Administrator Account"
                        Write-Host " [C] Deactivate Built-in Administrator Account"
                        Write-Host " [D] Back to Main Toolkit Menu"
                        Write-Host "==================================================" -ForegroundColor Cyan
                        Write-Host ""
                        
                        $SubChoice = (Read-Host "Select a user management task").ToUpper().Trim()
                        
                        switch ($SubChoice) {
                            "A" {
                                Clear-Host
                                Write-Host "--- Local System User Accounts ---`n" -ForegroundColor Green
                                Get-LocalUser | Select-Object Name, Enabled, Description | Format-Table -AutoSize
                                $RanTasks = $true
                                Write-Host "`nPress any key to return to user sub-menu..." -ForegroundColor Gray
                                [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                            }
                            "B" {
                                Clear-Host
                                Write-Host "--- Activating Built-in Administrator ---`n" -ForegroundColor Green
                                $PasswordInput = Read-Host "Enter password for Administrator (Leave blank for no password)"
                                
                                Write-Host "`nApplying configuration changes..." -ForegroundColor Gray
                                & net user Administrator /active:yes
                                
                                if ([string]::IsNullOrEmpty($PasswordInput)) {
                                    & net user Administrator ""
                                    Write-Host "SUCCESS: Built-in Administrator active with NO PASSWORD." -ForegroundColor Yellow
                                } else {
                                    & net user Administrator $PasswordInput
                                    Write-Host "SUCCESS: Built-in Administrator active with custom password." -ForegroundColor Green
                                }
                                $RanTasks = $true
                                Write-Host "`nPress any key to return to user sub-menu..." -ForegroundColor Gray
                                [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                            }
                            "C" {
                                Clear-Host
                                Write-Host "--- Deactivating Built-in Administrator ---`n" -ForegroundColor Yellow
                                Write-Host "Disabling profile target structures..." -ForegroundColor Gray
                                & net user Administrator /active:no
                                Write-Host "SUCCESS: Built-in Administrator account has been deactivated." -ForegroundColor Green
                                $RanTasks = $true
                                Write-Host "`nPress any key to return to user sub-menu..." -ForegroundColor Gray
                                [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                            }
                            "D" {
                                $UserMenuLoop = $false
                            }
                            Default {
                                Write-Host "Selection '$SubChoice' is invalid." -ForegroundColor Red
                                Start-Sleep -Seconds 1
                            }
                        }
                    }
                }
                4 {
                    Clear-Host
                    if (-not $IsAdmin) {
                        Write-Host "ERROR: This operation requires Administrator privileges." -ForegroundColor Red
                        Start-Sleep -Seconds 2
                        break
                    }
                    
                    $RanTasks = $true
                    Write-Host "--- [4] Windows Deployment Image & System File Repair ---" -ForegroundColor Green
                    
                    Write-Host "Step 1/2: Checking operating system image health via DISM..." -ForegroundColor Yellow
                    DISM /Online /Cleanup-Image /RestoreHealth
                    
                    Write-Host "`nStep 2/2: Verifying protected system files via SFC..." -ForegroundColor Yellow
                    sfc /scannow
                    
                    Write-Host "`nOS integrity scanning cycle completed." -ForegroundColor Green
                }
                5 {
                    Clear-Host
                    if (-not $IsAdmin) {
                        Write-Host "ERROR: MAS requires administrative permissions to modify licensing headers." -ForegroundColor Red
                        Start-Sleep -Seconds 2
                        break
                    }
                    
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
                    
                    $Confirm = Read-Host "Type 'AGREE' to proceed with the activation utility"
                    if ($Confirm -eq "AGREE") {
                        Clear-Host
                        $RanTasks = $true
                        Write-Host "Launching Microsoft Activation Scripts (MAS)..." -ForegroundColor Green
                        irm https://get.activated.win | iex
                    }
                }
                6 {
                    $PowerMenuLoop = $true
                    while ($PowerMenuLoop) {
                        Clear-Host
                        Write-Host "==================================================" -ForegroundColor Cyan
                        Write-Host "         [6] POWER & HARDWARE FIRMWARE MENU       " -ForegroundColor White -BackgroundColor Blue
                        Write-Host "==================================================" -ForegroundColor Cyan
                        Write-Host " [A] Force Reboot Machine ----------- (shutdown /r /f /t 0)"
                        Write-Host " [B] Full Shutdown (Fast Start Off) - (shutdown /s /f /t 0)"
                        Write-Host " [C] Standard System Shutdown ------- (shutdown /s /t 0)"
                        Write-Host " [D] Direct Boot into UEFI/BIOS ----- (shutdown /r /fw /f /t 0)"
                        Write-Host " [E] Back to Main Toolkit Menu"
                        Write-Host "==================================================" -ForegroundColor Cyan
                        Write-Host ""
                        
                        $PowerChoice = (Read-Host "Select a power management task").ToUpper().Trim()
                        
                        switch ($PowerChoice) {
                            "A" {
                                Clear-Host
                                Write-Host "Executing forced target workstation reboot..." -ForegroundColor Yellow
                                Start-Sleep -Seconds 1
                                shutdown /r /f /t 0
                                exit
                            }
                            "B" {
                                Clear-Host
                                Write-Host "Executing full cold-shutdown (Fast Startup completely bypassed)..." -ForegroundColor Yellow
                                Start-Sleep -Seconds 1
                                shutdown /s /f /t 0
                                exit
                            }
                            "C" {
                                Clear-Host
                                Write-Host "Initiating standard operating system shutdown routine..." -ForegroundColor Yellow
                                Start-Sleep -Seconds 1
                                shutdown /s /t 0
                                exit
                            }
                            "D" {
                                Clear-Host
                                if (-not $IsAdmin) {
                                    Write-Host "ERROR: Changing hardware firmware targets requires Administrator privileges." -ForegroundColor Red
                                    Write-Host "Please use option [1] from the main menu to elevate the toolkit first." -ForegroundColor Yellow
                                    Start-Sleep -Seconds 3
                                    break
                                }
                                Write-Host "Preparing system firmware environment..." -ForegroundColor Yellow
                                Write-Host "The workstation will boot straight into the BIOS setup loop..." -ForegroundColor Red
                                Start-Sleep -Seconds 2
                                shutdown /r /fw /f /t 0
                                exit
                            }
                            "E" {
                                $PowerMenuLoop = $false
                            }
                            Default {
                                Write-Host "Selection '$PowerChoice' is invalid." -ForegroundColor Red
                                Start-Sleep -Seconds 1
                            }
                        }
                    }
                }
                Default {
                    Write-Host "Selection '$Choice' is invalid or not recognized." -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
        }
        
        # Only pause a single time at the very end of all completed selections
        if ($RanTasks) {
            Write-Host ""
            Write-Host "==================================================" -ForegroundColor Cyan
            Write-Host " All selected tasks completed." -ForegroundColor Green
            Write-Host " Press any key to return to the main menu..." -ForegroundColor Gray
            Write-Host "==================================================" -ForegroundColor Cyan
            [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($true)
