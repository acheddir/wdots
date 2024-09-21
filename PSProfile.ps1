#PS Profile

# Set Aliases
Set-Alias -Name cat -Value bat
Set-Alias -Name up -Value Update-Dotfiles

function Find-DotfilesLocation {
    <#
        .SYNOPSYS
            - Find the wdots location
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$PSProfilePath
    )

    Write-Verbose "Fetching the dotfiles location from the symbolic link"
    $psProfileSymbolicLink = Get-ChildItem $PSProfilePath | Where-Object FullName -EQ $PROFILE.CurrentUserAllHosts
    return Split-Path $psProfileSymbolicLink.Target
}

function Update-Dotfiles {
    <#
        .SYNOPSYS
            - Gets the latest changes from the dotfiles repository
            - Reruns the Install.ps1 script
            - Reloads the $PROFILE
    #>
    # Store cwd to cd back to it
    $cwd = $PWD

    # Cd to dotfiles location, stash current changes, update the repo, and pop out the stash
    Set-Location $ENV:WDOTS_LOCATION
    git stash | Out-Null
    git pull | Out-Null
    git stash pop | Out-Null

    # Rerun the Install.ps1 script with or without gsudo installed"
    if (Get-Command -Name gsudo -ErrorAction SilentlyContinue) {
        sudo ./Install.ps1
    }
    else {
        Start-Process wezterm -Verb runAs -WindowStyle Hidden -ArgumentList "start --cwd $PWD pwsh -NonInteractive -Command ./Install.ps1"
    }

    # Cd to cwd
    Set-Location $cwd

    # Source $PROFILE
    .$PROFILE.CurrentUserAllHosts
}

# Create a hook that will run scoop-search.exe whenever native 'scoop search' is used
Invoke-Expression (&scoop-search --hook)

# Environment Variables
# ------------------------------------------------------------------
$ENV:WDOTS_LOCATION = Find-DotfilesLocation -PSProfilePath $PSScriptRoot
