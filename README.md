![UninstallOneDrive](https://github.com/asheroto/UninstallOneDrive/assets/49938263/783d328b-5bf9-4cad-ba63-3a007bd8d0c3)

[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/UninstallOneDrive)](https://github.com/asheroto/UninstallOneDrive/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/UninstallOneDrive/total)](https://github.com/asheroto/UninstallOneDrive/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto?frequency=one-time&sponsor=asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>
<a href="https://www.buymeacoffee.com/asheroto"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=seb6596&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=asheroto&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff)" height="40px"></a>

# UninstallOneDrive

Uninstall OneDrive in less than a minute.

## Features
- OneDrive process killed
- Multiple locations checked, including the most common locations as well as the EXE specified in the Uninstall registry key
- Registry keys cleaned up
- Scheduled tasks removed
- User folders are **NOT** removed

## Setup

**Note:** For a stable experience, use one of the methods listed below (#1, #2, or #3) to fetch the latest version. **Using the version directly from the GitHub repository is not advised**, as it could be under active development and not fully stable.

### Method 1 - PowerShell Gallery

**This is the recommended method, because it always gets the public release that has been tested, it's easy to remember, and supports all parameters.**

Open PowerShell as Administrator and type

```powershell
Install-Script UninstallOneDrive -Force
```

Follow the prompts to complete the installation (you can tap `A` to accept all prompts or `Y` to select them individually.

**Note:** `-Force` is optional but recommended, as it will force the script to update if it is outdated. If you do not use `-Force`, it will _not_ overwrite the script if outdated.

#### Usage

```powershell
UninstallOneDrive
```

If `UninstallOneDrive` is already installed, you can use the `-Force` parameter to force the script to run anyway.

The script is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/UninstallOneDrive) under `UninstallOneDrive`.

#### Tip - How to trust PSGallery

If you want to trust PSGallery so you aren't prompted each time you run this command, or if you're scripting this and want to ensure the script isn't interrupted the first time it runs...

```powershell
Install-PackageProvider -Name "NuGet" -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
```

### Method 2 - One Line Command (Runs Immediately)

The URL [asheroto.com/uninstallonedrive](https://asheroto.com/uninstallonedrive) always redirects to the [latest code-signed release](https://github.com/asheroto/UninstallOneDrive/releases/latest/download/UninstallOneDrive.ps1) of the script.

If you just need to run the basic script without any parameters, you can use the following one-line command:

```powershell
irm asheroto.com/uninstallonedrive | iex
```

### Method 3 - Download Locally and Run

As a more conventional approach, download the latest [UninstallOneDrive.ps1](https://github.com/asheroto/UninstallOneDrive/releases/latest/download/UninstallOneDrive.ps1) from [Releases](https://github.com/asheroto/UninstallOneDrive/releases), then run the script as follows:

```powershell
.\UninstallOneDrive.ps1
```

## Parameters

**No parameters are required** to run the script, but there are some optional parameters to use if needed.

| Parameter         | Description                                            |
| ----------------- | ------------------------------------------------------ |
| `-CheckForUpdate` | Checks if there is an update available for the script. |
| `-UpdateSelf`     | Updates the script to the latest version.              |
| `-Version`        | Displays the version of the script.                    |
| `-Help`           | Displays the full help information for the script.     |

### Example Parameters Usage

```powershell
UninstallOneDrive -UpdateSelf
```