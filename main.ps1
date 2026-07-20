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
