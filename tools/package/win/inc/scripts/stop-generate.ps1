$path = $(Resolve-Path $($PSScriptRoot + "/.."))
& "$path/scripts/settings.ps1"
if (Test-Path "$env:APPDATA/Raycoin/settings.ps1") { & "$env:APPDATA/Raycoin/settings.ps1" }

$clients = @()
(1..$env:GPU_COUNT) | %{
    $dir = if ($_ -eq 1) { "" } else { $_ }
    $num = $_ - 1
    $args = "-datadir=`"$env:APPDATA/Raycoin$dir`" -rpcport=$(8381 + $num*2)"
    $clients += Start-Process -PassThru -WindowStyle Hidden "$path/raycoin-cli" -ArgumentList $args, stopgenerate
}
Wait-Process -InputObject $clients