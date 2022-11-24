# <a align="center"><img src="GMode.svg"/></a>

<table>
    <tr>
        <td>Author:</td>
        <td>Philipp Reuter</td>
    </tr>
    <tr>
        <td>Version:</td>
        <td>1.0.0</td>
    </tr>
    <tr>
        <td>Generated:</td>
        <td>Nov 18, 2022</td>
    </tr>
    <tr>
        <td>Last Update:</td>
        <td>Nov 24, 2022</td>
    </tr>
    <tr>
        <td>Idea based on:</td>
        <td><a href="https://www.youtube.com/watch?v=_uyORohSWvU">YouTube</a></td>
    </tr>
    <tr>
        <td>Tested OS:</td>
        <td>Windows 11</td>
    </tr>
    <tr>
        <td>G Mode:</td>
        <td><a href="https://www.dell.com/support/kbdoc/de-de/000132265/introduction-to-the-new-features-of-the-x500-g-series-of-gaming-notebooks?lang=en#Game_Shift">DELL Game Shift</a></td>
    </tr>
</table>

## Prerequisites

- Alienware Command Center (AWCC)
- Administrator rights

## Introduction

I had found the GMode.exe from the video and liked the program, but I don't like to use EXE files from untrusted sources, so I wrote a Powershell script that can be run with the run.vbs (Visual Basic Script) with one click.

With both Powershell and Visual Basic Script you can easily read the source code with a text editor, but I still explain each line of code here.

## Installation [(Video)](https://www.youtube.com/watch?v=SmMtJ7l6naM)

1. Download ZIP from the green Code Button in the top right.
2. Extract the ZIP to any location.

## Usage

You have two Options, run.vbs to just simulate the key presses and run_manager.vbs to also automaticly manage AWCC, if its not running or crashed.

1. Run the "run.vbs" File.
   > **Presses the Keys to Toggles the G Mode.**
2. Run the "run_manager.vbs" File.
   > &nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** ***Checks if AWCC is running.***</br >
   > &nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** ***Checks if AWCC is installed, if not open a Massage Box to go to the installation webpage.***</br >
   > &nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** ***If AWCC is installed, starts it if its not running.***</br >
   > &nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** ***If AWCC is running, but the process is inactive, terminates the process to trigger a restart of it.***</br >
   > &nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** ***When AWCC is started or restarted, the script waits for special DLLs to be loaded by AWCC.***</br >
   > &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ***Before that the key combination is not processed by AWCC and nothing happens!***

   > **Presses the Keys to Toggles the G Mode.**

## Code

<details><summary><b>run.vbs & run_manager.vbs</b> (Visual Basic Script)</summary>
<p>

```vb
current_directory = CreateObject("Scripting.FileSystemObject").GetAbsolutePathName(".")
```

&nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** **_Get the current directory._**

```vb
ps1_script_path = current_directory & "\g_mode.ps1"
```

&nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** **_Concatenate current directory with file name to get the path to the script._**

```vb
cmd = "powershell.exe " & ps1_script_path
```

&nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** **_Define the command to run the script._**

```vb
CreateObject("Wscript.Shell").Run cmd, 0, True
```

&nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** **_Run the Script and hide the console._**

</p>
</details>

---

<details><summary><b>g_mode.ps1</b> (Powershell)</summary>
<p>

```powershell
Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags,UIntPtr dwExtraInfo);' -name t -namespace w32
```

&nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** **_Import the "user32.dll" so we can use the keybd_event function._**

```powershell
[w32.t]::keybd_event(0x80,0,0,[UIntPtr]::Zero)
```

&nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** **_Use the keybd_event function to press Key Code 0x80 (128)._**

```powershell
[w32.t]::keybd_event(0x80,0,0x2,[UIntPtr]::Zero)
```

&nbsp;&nbsp;&nbsp;&nbsp;**&#x27A5;** **_Use the keybd_event function to release Key Code 0x80 (128)._**

</p>
</details>
