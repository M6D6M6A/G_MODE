current_directory = CreateObject("Scripting.FileSystemObject").GetAbsolutePathName(".")
ps1_script_path = current_directory & "\g_mode_manager.ps1"
cmd = "-executionpolicy unrestricted -file " & ps1_script_path
CreateObject("Shell.Application").ShellExecute "powershell.exe", cmd, "", "runas", 0