$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user -RandomDelay "00:00:10"
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Highest
$action = New-ScheduledTaskAction -Execute "$HOME\scoop\apps\altsnap\current\AltSnap.exe"
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit 0
Register-ScheduledTask -TaskName "AltSnap" -Trigger $trigger -Principal $principal -Action $action -Description "Start AltSnap on logon" -Force -Settings $settings
