current_directory = CreateObject("Scripting.FileSystemObject").GetAbsolutePathName(".")
ps1_script_path = current_directory & "\g_mode.ps1"
cmd = "powershell.exe -Executionpolicy Bypass -file" & ps1_script_path
WScript.CreateObject("WScript.Shell").Run cmd, 0, True