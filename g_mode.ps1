Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags,UIntPtr dwExtraInfo);' -name t -namespace w32
[w32.t]::keybd_event(0x80,0,0,[UIntPtr]::Zero)
[w32.t]::keybd_event(0x80,0,0x2,[UIntPtr]::Zero)