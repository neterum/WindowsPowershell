param (
    [switch]$shutdown = $false
)

$pids = Get-Process putty

ForEach ($pidobj in $pids) {
    Stop-Process -id $pidobj.Id
}

Stop-VM -Name MBE
Stop-Process -Id $PID

If ($shutdown) {
    Stop-Computer
}