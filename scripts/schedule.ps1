$TaskName = "VirusTC-Monthly-CIO-Report-Subscription"
$ScriptPath = "C:\Certs\Scripts\VirusTC-Monthly-Email-Subscription.ps1"

# Create action block pointing directly to script target execution lanes
$TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""

# Establish subscription cadence interval (Monthly on Day 1 at 06:00 AM)
$TaskTrigger = New-ScheduledTaskTrigger -MonthlyOn @(1) -DaysOfWeek @(1) -At "6:00AM"

# Register the new engine task under administrative execution rights
Register-ScheduledTask -TaskName $TaskName `
                       -Action $TaskAction `
                       -Trigger $TaskTrigger `
                       -User "NT AUTHORITY\SYSTEM" `
                       -RunLevel Highest `
                       -Description "Automated monthly HTML delivery of VirusTC clinical infrastructure reports directly to the hospital CIO office."
