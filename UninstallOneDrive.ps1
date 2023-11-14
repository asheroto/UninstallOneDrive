<#PSScriptInfo

.VERSION 1.0.2

.GUID a4aa6d94-fe9e-41c0-8d8e-112b0c195fcb

.AUTHOR asherto

.COMPANYNAME asheroto

.TAGS PowerShell Microsoft OneDrive remove uninstall delete erase

.PROJECTURI https://github.com/asheroto/UninstallOneDrive

.RELEASENOTES
[Version 0.0.1] - Initial release.
[Version 0.0.2] - Updated description.
[Version 0.0.3] - Added to GitHub.
[Version 0.0.4] - Fixed signature.
[Version 0.0.5] - Fixed various bugs.
[Version 1.0.0] - Major refactor. Added removal of OneDrive scheduled tasks. Added Help, Version, CheckForUpdate, and UpdateSelf.
[Version 1.0.1] - Add Uninstall Complete verbiage.
[Version 1.0.2] - Fix position on Uninstall Complete verbiage.

#>

<#
.SYNOPSIS
    Uninstalls Microsoft OneDrive. Usage: UninstallOneDrive
.DESCRIPTION
    Uninstalls Microsoft OneDrive. Usage: UninstallOneDrive
.EXAMPLE
    UninstallOneDrive.ps1
.NOTES
    Version      : 1.0.2
    Created by   : asheroto
.LINK
    https://github.com/asheroto/UninstallOneDrive
#>
[CmdletBinding()]
param (
    [switch]$CheckForUpdate,
    [switch]$UpdateSelf,
    [switch]$Version,
    [switch]$Help
)

#Requires -RunAsAdministrator

# Version
$CurrentVersion = '1.0.2'
$RepoOwner = 'asheroto'
$RepoName = 'UninstallOneDrive'
$PowerShellGalleryName = 'UninstallOneDrive'

# Display version if -Version is specified
if ($Version.IsPresent) {
    $CurrentVersion
    exit 0
}

# Display full help if -Help is specified
if ($Help) {
    Get-Help -Name $MyInvocation.MyCommand.Source -Full
    exit 0
}

# Display $PSVersionTable and Get-Host if -Verbose is specified
if ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose']) {
    $PSVersionTable
    Get-Host
}

function Get-GitHubRelease {
    <#
        .SYNOPSIS
        Fetches the latest release information of a GitHub repository.

        .DESCRIPTION
        This function uses the GitHub API to get information about the latest release of a specified repository, including its version and the date it was published.

        .PARAMETER Owner
        The GitHub username of the repository owner.

        .PARAMETER Repo
        The name of the repository.

        .EXAMPLE
        Get-GitHubRelease -Owner "asheroto" -Repo "winget-install"
        This command retrieves the latest release version and published datetime of the winget-install repository owned by asheroto.
    #>
    [CmdletBinding()]
    param (
        [string]$Owner,
        [string]$Repo
    )
    try {
        $url = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
        $response = Invoke-RestMethod -Uri $url -ErrorAction Stop

        $latestVersion = $response.tag_name
        $publishedAt = $response.published_at

        # Convert UTC time string to local time
        $UtcDateTime = [DateTime]::Parse($publishedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
        $PublishedLocalDateTime = $UtcDateTime.ToLocalTime()

        [PSCustomObject]@{
            LatestVersion     = $latestVersion
            PublishedDateTime = $PublishedLocalDateTime
        }
    } catch {
        Write-Error "Unable to check for updates.`nError: $_"
        exit 1
    }
}

function CheckForUpdate {
    param (
        [string]$RepoOwner,
        [string]$RepoName,
        [version]$CurrentVersion,
        [string]$PowerShellGalleryName
    )

    $Data = Get-GitHubRelease -Owner $RepoOwner -Repo $RepoName

    Write-Output ""
    Write-Output ("Repository:       {0,-40}" -f "https://github.com/$RepoOwner/$RepoName")
    Write-Output ("Current Version:  {0,-40}" -f $CurrentVersion)
    Write-Output ("Latest Version:   {0,-40}" -f $Data.LatestVersion)
    Write-Output ("Published at:     {0,-40}" -f $Data.PublishedDateTime)

    if ($Data.LatestVersion -gt $CurrentVersion) {
        Write-Output ("Status:           {0,-40}" -f "A new version is available.")
        Write-Output "`nOptions to update:"
        Write-Output "- Download latest release: https://github.com/$RepoOwner/$RepoName/releases"
        if ($PowerShellGalleryName) {
            Write-Output "- Run: $RepoName -UpdateSelf"
            Write-Output "- Run: Install-Script $PowerShellGalleryName -Force"
        }
    } else {
        Write-Output ("Status:           {0,-40}" -f "Up to date.")
    }
    exit 0
}

function UpdateSelf {
    try {
        # Get PSGallery version of script
        $psGalleryScriptVersion = (Find-Script -Name $PowerShellGalleryName).Version

        # If the current version is less than the PSGallery version, update the script
        if ($CurrentVersion -lt $psGalleryScriptVersion) {
            Write-Output "Updating script to version $psGalleryScriptVersion..."

            # Install NuGet PackageProvider if not already installed
            if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
                Install-PackageProvider -Name "NuGet" -Force
            }

            # Trust the PSGallery if not already trusted
            $repo = Get-PSRepository -Name 'PSGallery'
            if ($repo.InstallationPolicy -ne 'Trusted') {
                Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
            }

            # Update the script
            Install-Script $PowerShellGalleryName -Force

            Write-Output "Script updated to version $psGalleryScriptVersion."
            exit 0
        } else {
            Write-Output "Script is already up to date."
            exit 0
        }
    } catch {
        Write-Output "An error occurred: $_"
        exit 1
    }
}

function Uninstall-OneDrive {
    param (
        [string]$Path
    )
    if (Test-Path $Path) {
        Write-Output "Uninstalling OneDrive found in $Path"
        $proc = Start-Process $Path "/uninstall" -PassThru
        $proc.WaitForExit()
    } else {
        Write-Output "Path `"$Path`" not found, skipping..."
    }
}

function Get-UninstallString {
    param (
        [string]$Match
    )
    $uninstallPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    )

    foreach ($path in $uninstallPaths) {
        if (Test-Path $path) {
            $uninstallString = Get-ChildItem -Path $path | 
            Get-ItemProperty | 
            Where-Object { $_.DisplayName -like "*$Match*" } |
            Select-Object -ExpandProperty UninstallString -First 1
            if ($uninstallString) {
                return $uninstallString
            }
        }
    }
    return $null
}

try {
    # First heading
    Write-Output "UninstallOneDrive $CurrentVersion"

    # Check for updates if -CheckForUpdate is specified
    if ($CheckForUpdate) { CheckForUpdate -RepoOwner $RepoOwner -RepoName $RepoName -CurrentVersion $CurrentVersion -PowerShellGalleryName $PowerShellGalleryName }

    # Update the script if -UpdateSelf is specified
    if ($UpdateSelf) { UpdateSelf }

    # Heading
    Write-Output "To check for updates, run winget-install -CheckForUpdate"

    $oneDrivePaths = @(
        "$ENV:SystemRoot\System32\OneDriveSetup.exe",
        "$ENV:SystemRoot\SysWOW64\OneDriveSetup.exe",
        "$ENV:ProgramFiles\Microsoft Office\root\Integration\Addons\OneDriveSetup.exe",
        "${ENV:ProgramFiles(x86)}\Microsoft Office\root\Integration\Addons\OneDriveSetup.exe"
    )

    Write-Output "Stopping OneDrive processes..."
    Stop-Process -Name OneDrive* -Force -ErrorAction SilentlyContinue

    # Uninstall from common locations
    foreach ($path in $oneDrivePaths) {
        Uninstall-OneDrive -Path $path
    }

    # Uninstall from Uninstall registry key UninstallString
    $uninstallString = Get-UninstallString -Match "OneDrive"
    if ($uninstallString) {
        Write-Output "Uninstalling OneDrive found in Uninstall registry key..."
        try {
            # Remove quotation marks from the uninstall string
            $uninstallString = $uninstallString.Replace('"', '')

            $exePath = $uninstallString.Substring(0, $uninstallString.IndexOf(".exe") + 4).Trim()
            $argz = $uninstallString.Substring($uninstallString.IndexOf(".exe") + 5).Trim().replace("  ", " ")

            # Write the path of the executable and the arguments to the console
            Write-Output "`t`"$exePath`""

            $proc = Start-Process -FilePath $exePath -Args $argz -PassThru
            $proc.WaitForExit()
        } catch {
            Write-Output "Uninstall failed with exception: $($_.Exception.Message)"
        }
    } else {
        Write-Output "No OneDrive uninstall string found in registry, skipping..."
    }

    # Remove OneDrive scheduled tasks
    Write-Output "Removing OneDrive scheduled tasks..."
    Get-ScheduledTask -TaskName "OneDrive*" | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

    # Output uninstall complete
    Write-Output "Uninstall complete!"
} catch {
    Write-Warning "Uninstall failed with exception: $($_.Exception.Message)"
    exit 1
}