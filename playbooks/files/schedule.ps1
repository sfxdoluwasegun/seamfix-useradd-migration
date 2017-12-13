# for windows 8 and higher versions

ipmo ScheduledTasks
$action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-ExecutionPolicy Unrestricted -NonInteractive -File C:\Tower\request_tower_configuration.ps1'
$trigger =  New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
$principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "callAnsibleTower" -Description "call Ansible Tower" 