#PS Profile

# Set Aliases
Set-Alias -Name c -Value clear
Set-Alias -Name cat -Value bat
Set-Alias -Name d -Value docker
Set-Alias -Name df -Value Get-Volume
Set-Alias -Name ff -Value Find-File
Set-Alias -Name g -Value git
Set-Alias -Name gct -Value Invoke-GitContrib
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

function Invoke-GitContrib {
    & "git-contrib" $args
}

# Windows Pomodoro Timer in PowerShell
function Start-PomodoroTimer {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Duration,
        [string]$ActivityName = "Pomodoro Timer"
    )
    
    # Parse the duration (e.g., "60m" to 60 minutes)
    $totalSeconds = 0
    if ($Duration -match '(\d+)m') {
        $totalSeconds = [int]$Matches[1] * 60
    }
    elseif ($Duration -match '(\d+)s') {
        $totalSeconds = [int]$Matches[1]
    }
    else {
        Write-Error "Invalid time format. Use format like '60m' or '30s'."
        return
    }
    
    $endTime = (Get-Date).AddSeconds($totalSeconds)
    
    # Display initial info
    Write-Host "`n$ActivityName for $Duration. Will complete at $($endTime.ToString('HH:mm:ss'))" -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to exit`n" -ForegroundColor Gray
    
    # Visual progress bar settings
    $barWidth = 50  # Width of the progress bar in characters
    $originalCursorTop = [Console]::CursorTop
    
    # Progress bar loop
    for ($elapsedSeconds = 0; $elapsedSeconds -lt $totalSeconds; $elapsedSeconds++) {
        $percentComplete = [math]::Min(100, [math]::Round(($elapsedSeconds / $totalSeconds) * 100))
        $timeRemaining = $totalSeconds - $elapsedSeconds
        
        $minutes = [math]::Floor($timeRemaining / 60)
        $seconds = $timeRemaining % 60
        
        # Calculate filled portion of the bar
        $completedWidth = [math]::Floor($barWidth * $elapsedSeconds / $totalSeconds)
        
        # Create the bar string
        $progressBar = "["
        $progressBar += "".PadRight($completedWidth, "█")
        $progressBar += "".PadRight($barWidth - $completedWidth, "░")
        $progressBar += "]"
        
        # Create status message with time remaining
        $status = " {0,3}% | {1:00}:{2:00} remaining | $ActivityName" -f $percentComplete, $minutes, $seconds
        
        # Position cursor and write the bar
        [Console]::SetCursorPosition(0, $originalCursorTop)
        Write-Host $progressBar -NoNewline
        
        # Write the status with color based on remaining time percentage
        if ($percentComplete -gt 80) {
            Write-Host $status -ForegroundColor Green
        }
        elseif ($percentComplete -gt 50) {
            Write-Host $status -ForegroundColor Yellow
        }
        else {
            Write-Host $status -ForegroundColor Cyan
        }
        
        # Sleep for a second
        Start-Sleep -Seconds 1
    }
    
    # Clear progress display and show completion message
    [Console]::SetCursorPosition(0, $originalCursorTop)
    Write-Host "".PadRight($barWidth + $status.Length + 5) -NoNewline  # Clear the line
    [Console]::SetCursorPosition(0, $originalCursorTop)
    Write-Host "`n$ActivityName completed!" -ForegroundColor Green
}

# Function to show notification
function Show-Notification {
    param (
        [string]$Title,
        [string]$Message,
        [string]$IconPath = $null
    )
    
    # Load Windows Forms for notifications
    Add-Type -AssemblyName System.Windows.Forms
    
    # Create and configure the notification
    $notification = New-Object System.Windows.Forms.NotifyIcon
    
    # If an icon path is provided and it exists, use it
    if ($IconPath -and (Test-Path $IconPath)) {
        $notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($IconPath)
    }
    else {
        # Otherwise use the PowerShell icon
        $notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)
    }
    
    $notification.BalloonTipTitle = $Title
    $notification.BalloonTipText = $Message
    $notification.Visible = $true
    
    # Show notification
    $notification.ShowBalloonTip(5000)
    
    # Play a sound
    [System.Media.SystemSounds]::Exclamation.Play()
    
    # Cleanup
    Start-Sleep -Seconds 6
    $notification.Dispose()
}
function Start-PomodoroCycle {
  param(
    [int]$Cycles = 4
  )
    
  for ($i = 1; $i -le $Cycles; $i++) {
    Write-Host "Starting Pomodoro Cycle $i of $Cycles" -ForegroundColor Cyan
        
    Start-WorkPeriod
        
    if ($i -lt $Cycles) {
      Start-RestPeriod
    }
    else {
      Show-Notification -Title "Pomodoro Cycles Complete!" -Message "You've completed $Cycles pomodoro cycles. Take a longer break!" -IconPath "$env:USERPROFILE\Pictures\pumpkin.png"
      Write-Host "All pomodoro cycles complete! Take a longer break." -ForegroundColor Magenta
      Start-LongRestPeriod
    }
  }
}

# Define the work and rest functions (similar to your Mac aliases)
function Start-WorkPeriod {
  Start-PomodoroTimer -Duration "25m"
  Show-Notification -Title "Work Timer is up! Take a Break 😊" -Message "Pomodoro" -IconPath "$env:USERPROFILE\Pictures\pomodoro.png"
}

function Start-RestPeriod {
  Start-PomodoroTimer -Duration "5m"
  Show-Notification -Title "Break is over! Get back to work 😬" -Message "Pomodoro" -IconPath "$env:USERPROFILE\Pictures\pomodoro.png"
}

function Start-LongRestPeriod {
  Start-PomodoroTimer -Duration "15m"
  Show-Notification -Title "Break is over! Get back to work 😬" -Message "Pomodoro" -IconPath "$env:USERPROFILE\Pictures\pomodoro.png"
}

# Create aliases that match your Mac setup
Set-Alias -Name work -Value Start-WorkPeriod
Set-Alias -Name rest -Value Start-RestPeriod
Set-Alias -Name longrest -Value Start-LongRestPeriod
Set-Alias -Name pomodoro -Value Start-PomodoroCycle

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
  }
  else {
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
  .SYNOPSIS
    Find the dotfiles location based on profile symbolic link
  .DESCRIPTION
    Determines the location of dotfiles by resolving the symbolic link for PowerShell profile
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$PSProfilePath = (Split-Path $PROFILE.CurrentUserAllHosts -Parent)
  )

  Write-Verbose "Looking for profile at: $($PROFILE.CurrentUserAllHosts)"

  if (Test-Path -Path $PROFILE.CurrentUserAllHosts) {
    $profileItem = Get-Item -Path $PROFILE.CurrentUserAllHosts -Force

    if ($profileItem.LinkType -eq "SymbolicLink") {
      Write-Verbose "Found symbolic link: $($profileItem.Target)"

      # For relative targets like .\PSProfile.ps1
      if ($profileItem.Target -like ".*") {
        # The symlink target is relative, so we need to find what directory it's relative to
        $targetPath = Join-Path -Path (Split-Path $PROFILE.CurrentUserAllHosts -Parent) -ChildPath ($profileItem.Target -replace '^\.\/?','')
        $targetPath = (Get-Item $targetPath).Directory.FullName
        Write-Verbose "Resolved relative path to: $targetPath"
        return $targetPath
      }
      else {
        # For absolute paths
        $targetDir = Split-Path -Path $profileItem.Target -Parent
        Write-Verbose "Target directory: $targetDir"
        return $targetDir
      }
    }
    else {
      Write-Error "PowerShell profile is not a symbolic link"
      return $null
    }
  }
  else {
    Write-Error "PowerShell profile not found at $($PROFILE.CurrentUserAllHosts)"
    return $null
  }
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

  # Cd to dotfiles location, stash current changes, update the repo, and pop the stash out
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

  # Cd back to cwd
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
  sudo winget upgrade --all --include-unknown --silent --verbose
  sudo scoop update --all --quiet
  sudo cache off
}

# Create a hook that will run scoop-search.exe whenever native 'scoop search' is used
Invoke-Expression (&scoop-search --hook)

# Environment Variables
# ------------------------------------------------------------------
$ENV:WDOTS_LOCATION = Find-DotfilesLocation -PSProfilePath $PSScriptRoot
$ENV:STARSHIP_CONFIG = "$ENV:WDOTS_LOCATION\starship\starship.toml"
$ENV:_ZO_DATA_DIR = $ENV:WDOTS_LOCATION
$ENV:OBSIDIAN_VAULT = "$HOME\OneDrive\Documents\Obsidian Vaults\KB"
$ENV:BAT_CONFIG_DIR = "$ENV:WDOTS_LOCATION\bat"
$ENV:FZF_DEFAULT_OPTS = '--color=fg:-1,fg+:#ffffff,bg:-1,bg+:#3c4048 --color=hl:#5ea1ff,hl+:#5ef1ff,info:#ffbd5e,marker:#5eff6c --color=prompt:#ff5ef1,spinner:#bd5eff,pointer:#ff5ea0,header:#5eff6c --color=gutter:-1,border:#3c4048,scrollbar:#7b8496,label:#7b8496 --color=query:#ffffff --border="rounded" --border-label="" --preview-window="border-rounded" --height 40% --preview="bat -n --color=always {}"'

function Starship-ModuleCharacter {
  &starship module character
}

# Invoke-Expression (&starship init powershell)
# Enable-TransientPrompt

oh-my-posh init pwsh --config ~\.config\wdots\omp\jblab_2021.json | Invoke-Expression

# Zoxide initialization:
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) {
      'prompt' 
    }
    else {
      'pwd' 
    }
  (zoxide init powershell --hook $hook) -join "`n"
  })

$colors = @{
  "Operator"         = "`e[35m" # Purple
  "Parameter"        = "`e[36m" # Cyan
  "String"           = "`e[32m" # Green
  "Command"          = "`e[34m" # Blue
  "Variable"         = "`e[37m" # White
  "Comment"          = "`e[38;5;244m" # Gray
  "InlinePrediction" = "`e[38;5;244m" # Gray
}

Set-PSReadLineOption -Colors $colors
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Function AcceptSuggestion -Key Alt+l
Import-Module -Name CompletionPredictor
Import-Module git-aliases -DisableNameChecking

# No fastfetch for non interactive shells
# if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
#     return
# }
# fastfetch

fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
