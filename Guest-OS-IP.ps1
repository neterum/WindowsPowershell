param (

    # Param1: The name of the virtual machine being started 

    [string]$vm="MBE",

    # Param2: The name of virtual default switch ethernet adapter. 

    # The parameter does not need to be exact, but must be unique.
    # For Example: 'Hyper-v Virtual Ethernet Adapter #2'
    # can be shortened to: 'Ethernet Adapter #2'

    [string]$interfaceName="Ethernet Adapter #2",

    # Param3: The username for PuTTY SSH connections below

    [string]$username="gameadmin"
)

start-vm -name $vm

# Get the NIC object and store IP and Subnet

$nic = gwmi -computer .  -class "win32_networkadapterconfiguration" | Where-Object -FilterScript { $_.Description -like '*Ethernet Adapter #2*'}
Write-Host $nic.Description
$ip = [IPAddress] $nic.ipaddress[0]
$subnet = [IPAddress] $nic.IPSubnet[0]

# Calculate network and broadcast address based on IP and Subnet

$network = [IPAddress] ([IPAddress] ($ip.Address -band $subnet.Address)).Address
$broadcast = [IPAddress] ([long] ([UInt32]::MaxValue -bxor $subnet.Address) -bor $network.Address)

Write-Output "IP: $ip"
Write-Output "Subnet: $subnet"
Write-Output "Network: $network"
Write-Output "Broadcast: $broadcast"

$networkValue = $network.Address
$ipValue = $ip.Address
$broadcastValue =$broadcast.Address

# Debug information when trying to calculate a simple algorithm
# to create incremental IP addresses. Hex value representation of IP 
# addresses are in reverse of their dot decimal notation.  This did not
# allow me to simply increment the type-long address by 1 to get the
# next IP address.   

#[Convert]::ToString($networkValue, 16)
#[Convert]::ToString($ipValue, 16)
#[Convert]::ToString($broadcastValue, 16)

# Instead, only Class C network addresses will work in this script.
# Fourth quadrant bytes are incremented instead of type-long IP address.

$networkBytes  = $network.GetAddressBytes()
$broadcastBytes = $broadcast.GetAddressBytes()

$networkStart = $networkBytes[3]
$networkFinish = $broadcastBytes[3]

$hasResponded = $false
$foundIp = $null
while (!$hasResponded) {
    For ($i = $networkStart + 1; $i -lt $networkFinish; $i++) {
        $networkBytes[3] += 1
        $tempIP = [IPAddress] $networkBytes
        If ($tempIP -ne $ip) { 
            $hasResponded = Test-Connection $tempIP -Quiet -count 1
        }
        If ($hasResponded) {
            Write-Output "$tempIP response detected"
            $foundIp = $tempIP
            break
        }
    }
    $hasResponded = $true
}

# Modify the two "Start-Process" lines with direct calls
# to SSH if PuTTY is not desired to be used on the system.

If ($foundIp -ne $null) {
    Write-Output "Starting Putty..."
    Start-Process -FilePath "C:\Program Files\PuTTY\putty.exe" -ArgumentList "-ssh $username@$foundIp"
    Start-Process -FilePath "C:\Program Files\PuTTY\putty.exe" -ArgumentList "-ssh $username@$foundIp"

    Stop-Process -id $PID
}
