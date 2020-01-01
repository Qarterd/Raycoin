$path = $(Resolve-Path $($PSScriptRoot + "/.."))
& "$path/scripts/settings.ps1"
if (Test-Path "$env:APPDATA/Raycoin/settings.ps1") { & "$env:APPDATA/Raycoin/settings.ps1" }

$daemons = @()
(1..$env:GPU_COUNT) | %{
    $dir = if ($_ -eq 1) { "" } else { $_ }
    New-Item -Force -Path "$env:APPDATA/Raycoin$dir" -ItemType directory | Out-Null

    $num = $_ - 1
    $args = "-datadir=`"$env:APPDATA/Raycoin$dir`" -rpcport=$(8381 + $num*2) -port=$(8382 + $num*2) -gpu=$num"
    if ($env:DAEMON_ARGS) { $args += " " + $env:DAEMON_ARGS }
    $process = @{}
    if ($_ -eq 1)
    {
        $title = "$path\raycoind.exe"
        $process["NoNewWindow"] = $true
        $process["FilePath"] = "powershell"
    }
    else
    {
        $title = "$path\raycoind.exe - GPU $_"
        $process["FilePath"] = "$path/scripts/Raycoin Console.lnk"

    }
    $daemons += Start-Process @process -PassThru -ArgumentList "`$host.ui.RawUI.WindowTitle = '$title'; & '$path/raycoind' $args; pause"
}
Wait-Process -InputObject $daemons