#PS Profile

# Set Aliases
Set-Alias -Name c -Value clear
Set-Alias -Name cat -Value bat
Set-Alias -Name d -Value docker
Set-Alias -Name df -Value Get-Volume
Set-Alias -Name ff -Value Find-File
Set-Alias -Name g -Value git
Set-Alias -Name grep -Value Find-String
Set-Alias -Name k -Value kubectl
Set-Alias -Name l -Value List-PrettyList
Set-Alias -Name la -Value List-PrettyListAll
Set-Alias -Name ll -Value List-PrettyList
Set-Alias -Name ls -Value List-PrettyNormal
Set-Alias -Name rm -Value RemoveItem-Extended
Set-Alias -Name touch -Value TouchFile-Extended
Set-Alias -Name uu -Value Update-Dotfiles
Set-Alias -Name uus -Value Update-Dependencies
Set-Alias -Name vi -Value nvim
Set-Alias -Name vim -Value nvim
Set-Alias -Name which -Value Show-Command

function List-PrettyNormal {
    <#
        .SYNOPSIS
            Runs lsd in normal mode.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Path = $PWD
    )

    Write-Host ""
    lsd
    Write-Host ""
}

function List-PrettyList {
    <#
        .SYNOPSIS
            Runs lsd in list mode
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Path = $PWD
    )

    Write-Host ""
    lsd -l --header -git --icon always
    Write-Host ""
}

function List-PrettyListAll {
    <#
        .SYNOPSIS
            Runs lsd in list mode with special files
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Path = $PWD
    )

    Write-Host ""
    lsd -l -a --header -git --icon always
    Write-Host ""
}

function Find-String {
    <#
        .SYNOPSIS
            Grep: Search for a string.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SearchTerm,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
        [string]$Directory,
        [Parameter(Mandatory = $false)]
        [switch]$Recurse
    )

    Write-Verbose "Searching for '$SearchTerm' in '$Directory'"
    if ($Directory) {
        if ($Recurse) {
            Write-Verbose "Searching for '$SearchTerm' in '$Directory' and subdirectories"
            Get-ChildItem -Recurse $Directory | Select-String $SearchTerm
            return
        }

        Write-Verbose "Searching for '$SearchTerm' in '$Directory'"
        Get-ChildItem $Directory | Select-String $SearchTerm
        return
    }

    if ($Recurse) {
        Write-Verbose "Searching for '$SearchTerm' in current directory and subdirectories"
        Get-ChildItem -Recurse | Select-String $SearchTerm
        return
    }

    Write-Verbose "Searching for '$SearchTerm' in current directory"
    Get-ChildItem | Select-String $SearchTerm
}

function Find-File {
  <#
    .SYNOPSIS
        Finds a file in cwd
    #>
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
    [string]$SearchTerm
  )

  Write-Verbose "Searching for '$SearchTerm' in current directory and subdirectories"
  $result = Get-ChildItem -Recurse -Filter "*$SearchTerm*" -ErrorAction SilentlyContinue

  Write-Verbose "Outputting results to table"
  $result | Format-Table -AutoSize
}

function TouchFile-Extended {
    <#
        .SYNOPSIS
            Create a new file with the specified name, if it exists, update its timestamp
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$FileName
    )

	# Check if the file exists
	if (-not(Test-Path $FileName)) {
        # Create the file
		New-Item -ItemType File -Name $FileName -Path $PWD | Out-Null
	} else {
		# The file exists. Update the timestamp
		(Get-ChildItem $FileName).LastWriteTime = Get-Date
	}
}

function RemoveItem-Extended {
    <#
       .SYNOPSIS
            Removes an item and all its children.
        #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$rf,
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )

    Write-Verbose "Removing item '$Path' $($rf ? 'and all its children' : '')"
    Remove-Item $Path -Recurse:$rf -Force:$rf
}

function Show-Command {
  <#
    .SYNOPSIS
        Displays the definition of a command. Alias: which
    #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name
  )
  Write-Verbose "Showing definition of '$Name'"
  Get-Command $Name | Select-Object -ExpandProperty Definition
}

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

function Update-Dependencies {
    <#
        .SYNOPSIS
            Updates all dependencies installed with Winget and scoop
    #>

    # Update Winget and scoop dependencies
    sudo cache on
    sudo winget update --all --include-unknown --silent --verbose
    sudo scoop update --all --quiet
    sudo -k
    $ENV:SOFTWARE_UPDATE_AVAILABLE = ""
}

# Create a hook that will run scoop-search.exe whenever native 'scoop search' is used
Invoke-Expression (&scoop-search --hook)

# Environment Variables
# ------------------------------------------------------------------
$ENV:WDOTS_LOCATION = Find-DotfilesLocation -PSProfilePath $PSScriptRoot
