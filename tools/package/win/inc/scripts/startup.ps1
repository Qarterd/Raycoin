
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs; exit }

$path = $(Resolve-Path $($PSScriptRoot + "/.."))
& "$path/scripts/settings.ps1"
if (Test-Path "$env:APPDATA/Raycoin/settings.ps1") { & "$env:APPDATA/Raycoin/settings.ps1" }

$hidden = ($args[-1] -eq "hidden")

if ($args[0] -eq "remove")
{
    if (Get-ScheduledTask -TaskName "Raycoin" -ErrorAction ignore)
    {
        Unregister-ScheduledTask -TaskName "Raycoin" -Confirm:$false | Out-Null
    }
    if (Get-ScheduledTask -TaskName "Raycoin-Mining" -ErrorAction ignore)
    {
        Unregister-ScheduledTask -TaskName "Raycoin-Mining" -Confirm:$false | Out-Null
    }
    echo "Removed Raycoin from Windows startup."
}
else
{
    $action = New-ScheduledTaskAction -Execute "powershell" -Argument "-WindowStyle Hidden -Command `"Start-Process -Wait `'$path\scripts\Raycoin.lnk`'`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $trigger.Delay = 'PT30S'
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0
    Register-ScheduledTask -Force -Action $action -Trigger $trigger -Settings $settings -TaskName "Raycoin" | Out-Null

    if ($args[0] -eq "generate")
    {
        $speed = if ($args[1] -eq "hidden") { "" } else { $args[1] }
        $action = New-ScheduledTaskAction -Execute "powershell" -Argument "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command `"& `'$path\scripts\generate.ps1`' $speed`""
        $trigger = New-ScheduledTaskTrigger -AtStartup
        $trigger.Delay = 'PT1M'
        Register-ScheduledTask -Force -Action $action -Trigger $trigger -Settings $settings -TaskName "Raycoin-Mining" | Out-Null

        if ($speed -eq "background")
        {
            echo "Added Raycoin mining in background to Windows startup."
        }
        elseif ($speed -eq "fullspeed")
        {
            echo "Added Raycoin mining at full speed to Windows startup."
        }
        else
        {
            echo "Added Raycoin mining to Windows startup."
        }
    }
    else
    {
        echo "Added Raycoin to Windows startup."
    }
}

echo ""
if (!($hidden)) { pause }