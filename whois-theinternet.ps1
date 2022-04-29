$ip = "0.0.0.1"
$results = @()
while ($endip -ne "255.255.255.255") {
    $result = Get-Whois $ip
    Write-Output $result
    $results += $result
    $endip = $result[$result.Length-1].EndIP

    # Manually count up IP
    $octets = $endip.Split('.')
    foreach ($i in 3..0) {
        if ([int]$octets[$i] -lt 255) {
            ([int]$octets[$i])++
            break
        }
        else {
            $octets[$i] = "0"
        }
    }
    $ip = [String]::Join(".",$octets)
}
