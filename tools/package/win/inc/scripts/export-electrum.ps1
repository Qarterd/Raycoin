$path = $(Resolve-Path $($PSScriptRoot + "/.."))
& "$path/scripts/settings.ps1"
if (Test-Path "$env:APPDATA/Raycoin/settings.ps1") { & "$env:APPDATA/Raycoin/settings.ps1" }

if (!(Get-Process raycoind -ErrorAction Ignore))
{
    Start-Process "$path/scripts/Raycoin.lnk"
    Start-Sleep -s 30
}

echo "In Electrum go to Wallet -> Private keys -> Sweep and paste in the following keys (if any)."
echo "These are raycoin command-line wallet keys that contain mature rewards (100 confirmations):"
echo ""
(1..$env:GPU_COUNT) | %{
    $dir = if ($_ -eq 1) { "" } else { $_ }
    $num = $_ - 1
    $args = @("-datadir=`"$env:APPDATA/Raycoin$dir`"", "-rpcport=$(8381 + $num*2)")
    & "$path/raycoin-cli" @args listunspent | Select-String -Pattern '"address": "(\w+)"' | % {$_.matches.groups[1].value} | Sort-Object -Unique | % {& "$path/raycoin-cli" @args dumpprivkey $_}
}
echo ""
pause