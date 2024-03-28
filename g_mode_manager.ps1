# Load required assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);' -name t -namespace w32

<#
.SYNOPSIS
    A class for logging messages to a file.

.DESCRIPTION
    The Logger class provides static methods to write logs to a specified file.
    It includes functionality to get or set the log file path and append log messages to this file.
#>
class Logger {
    static [string] $logFile = [Logger]::GetLogFilePath()

    static [string] GetLogFilePath() {
        if (-not [Logger]::logFile) {
            $scriptPath = [System.IO.Path]::GetDirectoryName($PSCommandPath)
            [Logger]::logFile = Join-Path $scriptPath "log.txt"
        }
        return [Logger]::logFile
    }

    <#
    .SYNOPSIS
        Writes a log message to the log file.
    
    .DESCRIPTION
        Appends a given message to the log file, prefixed with a timestamp.
    
    .PARAMETER Message
        The message to be logged.
    #>
    static [void] WriteLog([string] $Message) {
        $logFilePath = [Logger]::logFile
        "[$(Get-Date)] $Message" | Out-File -FilePath $logFilePath -Append
    }
}

<#
.SYNOPSIS
    Retrieves the ID of the currently active Windows power plan.

.DESCRIPTION
    Queries the system for the active power plan and extracts its name and ID.

.OUTPUTS
    Returns a tuple containing the name and ID of the active power plan.
#>
function Get-CurrentPowerPlanId {
    $powerPlan = Get-WmiObject -Class Win32_PowerPlan -Namespace root\cimv2\power -Filter "isActive='true'"
    $powerPlanName = $powerPlan.ElementName
    $powerPlanId = [regex]::Match($powerPlan.InstanceID, '[^{]+(?=})').Value
    return $powerPlanName, $powerPlanId
}

<#
.SYNOPSIS
    Displays a message box with specified content.

.DESCRIPTION
    Shows a message box with customizable text, title, buttons, and icon.

.PARAMETERS
    - msgBody: Text body of the message box.
    - msgTitle: Title of the message box.
    - msgButton: Type of buttons to show.
    - msgImage: Icon to display.

.OUTPUTS
    Returns the result of the user interaction with the message box.
#>
function Show-MessageBox {
    param($msgBody, $msgTitle, $msgButton, $msgImage)
    return [System.Windows.MessageBox]::Show($msgBody, $msgTitle, $msgButton, $msgImage)
}

<#
.SYNOPSIS
    Simulates a keyboard event to toggle a specific key.

.DESCRIPTION
    Uses the Windows API to simulate pressing and releasing a specific key. 
    In this case, it's used to toggle the G Mode.
#>
function Switch-KeybdEvent {
    [w32.t]::keybd_event(0x80, 0, 0, [UIntPtr]::Zero)
    [w32.t]::keybd_event(0x80, 0, 0x2, [UIntPtr]::Zero)
}

# Is not updateing live and the ids wont match with the Windows internal ones!
# Just kept if i need the data for something else later!
class GModeManager {
    hidden [string] $filePath
    [hashtable] $profilesMap
    [string] $usttPerformanceProfileId

    GModeManager() {
        $this.filePath = $this.LocateThermalProfile()
        $this.profilesMap = $this.ParseProfilesToIdNameMap()
        $this.usttPerformanceProfileId = $this.FindProfileIdByName('UsttPerformance')
    }

    hidden [string] LocateThermalProfile() {
        $programFilesPath = [System.Environment]::GetFolderPath("ProgramFiles")
        $subfolderPath = "Alienware\Alienware Command Center\OCControlService\OCControl.Service.Thermal.Data\Profile.json"
        return Join-Path -Path $programFilesPath -ChildPath $subfolderPath
    }

    hidden [hashtable] ParseProfilesToIdNameMap() {
        if (Test-Path -Path $this.filePath) {
            $jsonData = Get-Content -Path $this.filePath | ConvertFrom-Json
            $this.profilesMap = @{}
            foreach ($profile in $jsonData.profiles) {
                $this.profilesMap[$profile.id] = $profile.name
            }
            return $this.profilesMap
        }
        else {
            Write-Warning "The file does not exist at: $($this.filePath)"
            return $null
        }
    }

    [string] GetCurrentProfileId() {
        $jsonData = Get-Content -Path $this.filePath | ConvertFrom-Json
        return $jsonData.active_profile.id
    }

    hidden [string] FindProfileIdByName([string] $profileName) {
        foreach ($id in $this.profilesMap.Keys) {
            if ($this.profilesMap[$id] -eq $profileName) {
                return $id
            }
        }
        return $null
    }
}

<#
.SYNOPSIS
    Manages the Alienware Command Center process.

.DESCRIPTION
    The AWCCManager class provides methods to ensure that the Alienware Command Center is running and responding. 
    It can start the AWCC application and check for its active modules.
#>
class AWCCManager {
    [void] ProcessManager() {
        $AWCCActive = Get-Process -name "AWCC" -ErrorAction SilentlyContinue
        if (-Not $AWCCActive) {
            $this.StartAWCC()
        }
        else {
            $this.EnsureAWCCResponding()
        }
    }

    hidden [void] StartAWCC() {
        $AWCC = Get-AppxPackage -AllUsers -Name "DellInc.AlienwareCommandCenter" | Select-Object -Property InstallLocation
        if ($AWCC) {
            Write-Log "Starting Alienware Command Center (AWCC)..."
            Start-Process -FilePath "$($AWCC[0].InstallLocation)\AWCC.exe"
            $this.WaitLoadedDLL("WININET.dll")
        }
        else {
            Write-Log "Alienware Command Center (AWCC) missing!"
            [Main]::MsgBoxInstall()
            Exit
        }
    }

    hidden [void] EnsureAWCCResponding() {
        $AWCCActive = Get-Process -name "AWCC" -ErrorAction SilentlyContinue
        if (-Not $AWCCActive.Responding) {
            Stop-Process -Name "AWCC"
            $this.WaitLoadedDLL("Gaming.API.WinRT.HeadsetControl.dll")
        }
    }

    hidden [void] WaitLoadedDLL([string] $DLLName) {
        Write-Log "Waiting for `"$DLLName`"..."
        Do {
            Start-Sleep -Milliseconds 100
        } while (-Not $this.ExistLoadedDLL($DLLName))
        Write-Log "Found `"$DLLName`"!"
    }

    hidden [bool] ExistLoadedDLL([string] $flag) {
        return [bool](Get-Process -name "AWCC" -Module -ErrorAction SilentlyContinue | Where-Object { $_.ModuleName -match $flag })
    }
}

<#
.SYNOPSIS
    Main execution class for the script.

.DESCRIPTION
    This class contains the primary logic for managing power plans based on the AWCC status. 
    It uses other classes and functions to toggle power modes, ensure AWCC is running, and log actions.
#>
class Main {
    static [void] MsgBoxInstall() {
        $msgBody = "Alienware Command Center (AWCC) missing!$([System.Environment]::NewLine)Open AWCC installation guide?"
        $msgTitle = "Install AWCC"
        $msgButton = 'OkCancel'
        $msgImage = 'Error'
        $Result = Show-MessageBox -msgBody $msgBody -msgTitle $msgTitle -msgButton $msgButton -msgImage $msgImage
        if ($Result -eq "Ok") {
            Start-Process "https://www.dell.com/support/kbdoc/en-us/000178439/how-to-remove-and-reinstall-the-alienware-command-center?lwp=rt"
        }
    }

    static [void] ToggleGMode() {
        Switch-KeybdEvent
    }

    static [void] Run() {
        [Logger]::WriteLog("Checking AWCC Status...")
        $awccManager = [AWCCManager]::new()
        $awccManager.ProcessManager()
        [Logger]::WriteLog("AWCC running!")

        # $gModeManager = [GModeManager]::new()
        $initialPowerPlanName, $initialPowerPlanId = Get-CurrentPowerPlanId
        [Logger]::WriteLog("Initial Power Plan: '$initialPowerPlanName'")

        [Main]::ToggleGMode()
        [Logger]::WriteLog("Toggled G Mode, waiting for power plan change...")

        $maxAttempts = 10 # Should attempt it 10 times
        $maxRetrys = 3 # Should retry to toggle the 3 times if it still is not the new, just terminate with a error log
        $attempts = 0
        $retrys = 0
        
        $currentPowerPlanName = $null
        $currentPowerPlanId = $null

        while ($null -eq $currentPowerPlanName -and $null -eq $currentPowerPlanId -or $currentPowerPlanId -eq $initialPowerPlanId) {
            if ($retrys -ge $maxRetrys) {
                [Logger]::WriteLog("Power plan could not be changed!`n")
                return
            }

            while ($attempts -lt $maxAttempts) {
                Start-Sleep -Seconds .1
                $currentPowerPlanName, $currentPowerPlanId = Get-CurrentPowerPlanId
                [Logger]::WriteLog("    #${attempts} '$initialPowerPlanName' to '$currentPowerPlanName'")

                if ($currentPowerPlanId -ne $initialPowerPlanId) {
                    break
                }
                $attempts++
            }

            if ($currentPowerPlanId -eq $initialPowerPlanId -and $attempts -ge $maxAttempts) {
                [Logger]::WriteLog("Power plan did not change after $maxAttempts attempts, retoggling G Mode")
                [Main]::ToggleGMode()
                $retrys++
            }
        }
        
        [Logger]::WriteLog("Power plan changed from '$initialPowerPlanName' to '$currentPowerPlanName'`n")
    }
}

[Main]::Run()
