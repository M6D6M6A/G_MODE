# Add these lines at the beginning of your script to create a log file
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$logFile = Join-Path $scriptPath "log.txt"
"Script started at $(Get-Date)" | Out-File -FilePath $logFile -Append

# Replace Write-Debug with a custom logging function
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $Message | Out-File -FilePath $logFile -Append
}

Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags,UIntPtr dwExtraInfo);' -name t -namespace w32
Add-Type -AssemblyName PresentationFramework

function AWCCManager {
    AWCCProcessManager
    $StartPlan = GetPowerPlan
    ToggleGMode
    if ($StartPlan) {
        Do {
            Start-Sleep -Milliseconds 100
            $EndPlan = GetPowerPlan
        } while ($StartPlan -eq $EndPlan)
        
        Write-Log "`"$StartPlan`" -> `"$EndPlan`""
    }
}

function AWCCProcessManager {
    $AWCCActive = Get-Process -name "AWCC" -ErrorAction SilentlyContinue
    if (-Not  $AWCCActive) {
        $AWCC = Get-AppxPackage -AllUsers -Name "DellInc.AlienwareCommandCenter" | Select-Object -Property InstallLocation
        if ($AWCC) {
            Write-Log "Starting Alienware Command Center (AWCC)..."
            $AWCCPath = [System.String]::Concat($AWCC[0].InstallLocation, "\AWCC.exe")
            Start-Process -FilePath $AWCCPath
            AWCCWaitLoadedDLL("WININET.dll")
        }
        else {
            Write-Log "Alienware Command Center (AWCC) missing!"
            MsgBoxInstall
            Exit
        }
    }
    else {
        $AppResponding = ($AWCCActive | Select-Object -Property Responding)[0].Responding
        if (-Not  $AppResponding) {
            Stop-Process -Name "AWCC"
            AWCCWaitLoadedDLL("Gaming.API.WinRT.HeadsetControl.dll")
        }
    }
}

function MsgBoxInstall {
    $msgBody = "Alienware Command Center (AWCC) missing!$([System.Environment]::NewLine)Open AWCC installation guide?"
    $msgTitle = "Install AWCC"
    $msgButton = 'OkCancel'
    $msgImage = 'Error'
    $Result = [System.Windows.MessageBox]::Show($msgBody, $msgTitle, $msgButton, $msgImage)
    switch ($Result) {
        "Ok" {
            Start-Process "https://www.dell.com/support/kbdoc/en-us/000178439/how-to-remove-and-reinstall-the-alienware-command-center?lwp=rt"
        }
    }
}

function AWCCModules {
    return Get-Process -name "AWCC" -Module -ErrorAction SilentlyContinue | Select-Object -Property ModuleName
}

function AWCCWaitLoadedDLL {
    param($DLLName)
    Write-Log "Waiting for `"$DLLName`"..."
    Do {
        Start-Sleep -Milliseconds 100
        $found = ExistLoadedDLL($DLLName)
    } while (-Not $found)
    Write-Log "Found `"$DLLName`"!"
}

function ExistLoadedDLL {
    param($flag)
    $DLLs = AWCCModules
    return [bool]($DLLs -match $flag)
}

function GetPowerPlan {
    $plan = Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -Filter "isActive='true'" -ErrorAction SilentlyContinue | Select-Object -Property ElementName
    if ($plan) { return $plan[0].ElementName }
    else { return $plan }
}

function ToggleGMode {
    [w32.t]::keybd_event(0x80, 0, 0, [UIntPtr]::Zero)
    [w32.t]::keybd_event(0x80, 0, 0x2, [UIntPtr]::Zero)
}

# Run the AWCCManager function
AWCCManager

# Add this line at the end of your script to log the script end time
"Script ended at $(Get-Date)" | Out-File -FilePath $logFile -Append

