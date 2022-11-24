Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags,UIntPtr dwExtraInfo);' -name t -namespace w32
Add-Type -AssemblyName PresentationFramework
$DebugPreference = 'Continue'

function AWCCManager {
    AWCCProcessManager
    $StartPlan = GetPowerPlan
    ToggleGMode
    if ($StartPlan) {
        Do {
            Start-Sleep -Milliseconds 100
            $EndPlan = GetPowerPlan
        } while ($StartPlan -eq $EndPlan)
        
        Write-Debug "`"$StartPlan`" -> `"$EndPlan`""
    }
}

function AWCCProcessManager {
    $AWCCActive = Get-Process -name "AWCC" -ErrorAction SilentlyContinue
    if (-Not  $AWCCActive) {
        $AWCC = Get-AppxPackage -AllUsers -Name "DellInc.AlienwareCommandCenter" | Select-Object -Property InstallLocation
        if ($AWCC) {
            Write-Debug "Starting Alienware Command Center (AWCC)..."
            $AWCCPath = [System.String]::Concat($AWCC[0].InstallLocation, "\AWCC.exe")
            Start-Process -FilePath $AWCCPath
            AWCCWaitLoadedDLL("WININET.dll")
        }
        else {
            Write-Debug "Alienware Command Center (AWCC) missing!"
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
    $Result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
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
    Write-Debug "Waiting for `"$DLLName`"..."
    Do {
        Start-Sleep -Milliseconds 100
        $found = ExistLoadedDLL($DLLName)
    } while (-Not $found)
    Write-Debug "Found `"$DLLName`"!"
}

function ExistLoadedDLL {
    param($flag)
    $DLLs = AWCCModules
    return [bool]($DLLs -match $flag)
}

function GetPowerPlan {
    $plan = Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -Filter "isActive='true'" -ErrorAction SilentlyContinue | Select-Object -Property ElementName
    if ($plan) { return $plan[0].ElementName}
    else { return $plan}
}

function ToggleGMode {
    [w32.t]::keybd_event(0x80, 0, 0, [UIntPtr]::Zero)
    [w32.t]::keybd_event(0x80, 0, 0x2, [UIntPtr]::Zero)
}

function TrackModuleChanges {
    $start = AWCCModules
    AWCCProcessManager
    while ($true) {
        $new = AWCCModules
        if ($start -and $new) {
            $c = Compare-Object -ReferenceObject $start -DifferenceObject $new -PassThru
            if ($c) { Write-Debug "$c" }
            $start = $new
        }
        Start-Sleep -Milliseconds 100
    }
}

# AWCCModules # Track All Loaded Modules
# TrackModuleChanges # Track Changes of Loaded Modules
AWCCManager