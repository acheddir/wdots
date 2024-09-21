# Run As Administrator or use sudo
# Requires Pwsh (PowerShell 7.*)

$wingetApps = @(
		"Microsoft.Bicep"
		"Kitware.CMake"
		"Microsoft.Azd"
		"Microsoft.AzureCLI"
		"Microsoft.Azure.FunctionsCoreTools"
		"Neovim.Neovim"
		"Schniz.fnm" # Fast Node Manager to manage node versions
		"Starship.Starship"
		"wez.wezterm"
	    )

$scoopBuckets = @(
		"main"
		"extras"
		"nerd-fonts"
		)

$scoopApps = @(
		# Packages
		"altsnap" # Easily resize and drag windows
		"bat" # A fancy alternative to cat
		"fastfetch" # A tool that fetches system information and displays them in the shell
		"fd" # An alternative to find
		"fzf" # A general-purpose fuzzy finder (used by neovim telescope)
		"gsudo" # Run command with elevated permissions from within your shell
		"lazygit" # A terminal UI for git commands (can be used within neovim)
		"lsd" # An alternative to the ls command
		"make"
		"ripgrep" # Recursively searches directories for a regex pattern.
		"sqlite"
		"sed" # A non-interactive command-line text editor
		"zig" # "ziglang.org"
		"zoxide" # A faster way to navigate the fs (directory jumper)
		# Nerd Fonts
		"FiraCode-NF"
		"FiraCode-NF-Mono"
		"IBMPlexMono-NF"
		"IBMPlexMono-NF-Mono"
		"JetBrainsMono-NF"
		"JetBrainsMono-NF-Mono"
		"Meslo-NF"
		"Meslo-NF-Mono"
	      )

$psModules = @(
		"PSFzf"
		"PSScriptAnalyzer"
	      )

$symbolicLinks = @{
			$PROFILE.CurrentUserAllHosts = ".\PSProfile.ps1"
            "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\WindowsTerminal\settings.json"
}

# Set CWD
Set-Location $PSScriptRoot
[Environment]::CurrentDirectory = $PSScriptRoot

# Install Winget Dependencies
Write-Host "Installing Winget dependencies..."
$currentWingetApps = winget list | Out-String
foreach ($wingetApp in $wingetApps) {
	if ($currentWingetApps -notmatch $wingetApp) {
		winget install --id $wingetApp
	}
}

# Check if scoop is already installed
Write-Host "Installing/Updating scoop package manager..."
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    # Update it
	scoop update
} else {
    # Otherwise install it
	Set-ExecutionPolicy Bypass -Scope Process -Force
		Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Add scoop buckets
Write-Host "Adding scoop buckets..."
foreach ($bucket in $scoopBuckets) {
	scoop bucket add $bucket
}

# Install scoop packages
Write-Host "Installing scoop packages..."
$currentScoopApps = scoop list | Out-String
foreach ($scoopApp in $scoopApps) {
	if ($currentScoopApps -notmatch $scoopApp) {
		scoop install $scoopApp
	}
}

# Install bat themes
bat cache --clear
bat cache --build

# Install PS Modules
Write-Host "Installing PowerShell modules..."
foreach ($psModule in $psModules) {
	if  (!(Get-Module -ListAvailable -Name $psModule)) {
		Install-Module -Name $psModule -Force -AcceptLicense -Scope CurrentUser
	}
}

# Create Symbolic Links
Write-Host "Creating Symbolic Links..."
foreach ($symbolicLink in $symbolicLinks.GetEnumerator()) {
	Get-Item -Path $symbolicLink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
	New-Item -ItemType SymbolicLink -Path $symbolicLink.Key -Target (Resolve-Path $symbolicLink.Value) -Force | Out-Null
}

# Persist WezTerm config file environment variable
[System.Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', "$PSScriptRoot\wezterm\wezterm.lua", [System.EnvironmentVariableTarget]::User)

# Set Git globals
$gitEmail = "acheddir@outlook.fr"
$gitName = "Abderrahman Cheddir"

git config --global --unset user.email | Out-Null
git config --global --unset user.name | Out-Null
git config --global user.email $gitEmail | Out-Null
git config --global user.name $gitName | Out-Null

# Schedule AltSnap to start on Windows logon
$trigger = New-ScheduledTaskTrigger -AtLogOn -RandomDelay "00:00:10"
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Highest
$action = New-ScheduledTaskAction -Execute "$HOME\AppData\Roaming\AltSnap\AltSnap.exe"
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit 0
Register-ScheduledTask -TaskName "AltSnap" -Trigger $trigger -Principal $principal -Action $action -Description "Start AltSnap on logon" -Force -Settings $settings | Out-Null
