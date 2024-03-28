> **Warning** The PowerShell scripts that you're about to run are not currently signed. Signing scripts is a paid service that certifies the source and integrity of the scripts. Because these scripts are not signed, Windows blocks them by default for security reasons. 
> 
> To run these scripts, you'll need to unblock them. To do this, run the following command in an **Administrator PowerShell Terminal**:
>
> ```powershell
> dir 'C:\Path\To\G_MODE\*' -Include *.ps1,*.vbs | Unblock-File
> ```
> 
> **Important:** You must replace `'C:\Path\To\G_MODE\'` with the actual path where your scripts are located (the `G_MODE` directory or whatever you named it). This command will unlock all `.ps1` and `.vbs` script files in that folder, allowing them to be executed.
> 
> Always be careful when unblocking and running scripts, especially if they come from the Internet. Make sure they come from a trusted source and are not malicious.

# G Mode

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
        <td>Mar 28, 2024</td>
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
        <td>G Mode DOCs:</td>
        <td><a href="https://www.dell.com/support/kbdoc/de-de/000132265/introduction-to-the-new-features-of-the-x500-g-series-of-gaming-notebooks?lang=en#Game_Shift">DELL Game Shift</a></td>
    </tr>
</table>

## Prerequisites

- Alienware Command Center (AWCC)
- Administrator rights

## Introduction

I had found the GMode.exe from the video and I liked the program, but I don't like to use EXE files from untrusted sources, so I wrote a Powershell script that can be run with the `run.vbs` (Visual Basic Script) with **one click**.

With both Powershell and Visual Basic Script, you can easily read the source code with a text editor, but I will still explain each line of code here.

## Installation [(Video)](https://www.youtube.com/watch?v=SmMtJ7l6naM)

1. Download ZIP from the green Code Button in the top right.
2. Extract the ZIP to any location.

## Usage

### You have two options:

1. **Double-click** `run.vbs` to just simulate a **single keypress**.
2. **Double-click** `run_manager.vbs` to also **automatically manage AWCC** if it is not running or crashed and make sure it switches to the other mode.
