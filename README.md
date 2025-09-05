> **Warning**  
> The PowerShell scripts in this repo are **not signed**. Windows may block unsigned scripts by default.  
> 
> To run them, you may need to **unblock** the files once:
>
> ```powershell
> dir 'C:\Path\To\G_MODE\*' -Include *.ps1,*.vbs | Unblock-File
> ```
>
> Replace `'C:\Path\To\G_MODE\'` with the actual folder path.  
> You typically **do not need administrator rights** to unblock files you own; however, if the folder is protected (e.g., under `Program Files`), use an **elevated PowerShell**.  
> Always be careful when unblocking and running scripts—verify sources and inspect code.

# G Mode

<table>
    <tr>
        <td>Author:</td>
        <td>Philipp Reuter</td>
    </tr>
    <tr>
        <td>Version:</td>
        <td>2.0.0</td>
    </tr>
    <tr>
        <td>Generated:</td>
        <td>Nov 18, 2022</td>
    </tr>
    <tr>
        <td>Last Update:</td>
        <td>Sep 5, 2025</td>
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

> **Shout-out**  
> Huge thanks to **@yomarhub** for PR **#2 – “Remove Unnecessary Admin Requirement and Improve Power Plan Detection”**.  
> Their contributions refined the core logic and helped tighten up this README. 🙌

## Prerequisites

- Alienware Command Center (AWCC)
- **No administrator rights required to run** the scripts. You may need elevation **only once** to unblock files if the folder is protected by Windows.

## Introduction

I discovered the `GMode.exe` approach in the linked video and liked the idea, but I prefer not to run unsigned binaries from untrusted sources.  
This repo provides a **PowerShell** implementation that you can launch via a small **VBScript** helper for a true **one-click** experience.

Because the logic is implemented in PowerShell and VBScript, you can review the source with any text editor.

## Installation [(Video)](https://www.youtube.com/watch?v=SmMtJ7l6naM)

1. Download the ZIP from the green **Code** button.
2. Extract the ZIP to any folder (e.g., `C:\Tools\G_MODE\`).
3. If Windows blocked the scripts, **unblock** them as shown above.

## Usage

You have two options:

1. **Double-click** `run.vbs` to simulate a **single keypress** that toggles the mode.
2. **Double-click** `run_manager.vbs` to **ensure AWCC is running** (start or revive it if needed) and **toggle the mode** reliably.

## Changelog

- **Sep 5, 2025** — PR #2 by @yomarhub
  - Removed unnecessary admin requirement for normal operation.
  - Improved **power plan detection** logic for more robust behavior.
  - Documentation cleanup and clarification around unblocking and permissions.

## Contributing

Issues and PRs are welcome. Please keep changes focused and include a brief rationale.  
For logic changes, add a short note for the changelog in your PR description.

---
