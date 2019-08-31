param (
    [switch]$shutdown = $false
)

$pids = Get-Process putty

ForEach ($pidobj in $pids) {
    Stop-Process -id $pidobj.Id
}

Stop-VM -Name MBE

If ($shutdown) {
    Stop-Computer
}
else
{
    Stop-Process -Id $PID
}