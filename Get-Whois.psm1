Function Get-Whois {
    [CmdletBinding()]
    Param (
        [Parameter(
            Position=0,
            Mandatory=$True,
            ValueFromPipeline=$True)]
        [string]$Target
    )
    Process {
        $response = Invoke-RestMethod "http://whois.arin.net/rest/ip/$target"
        
        $response.net.netBlocks.netBlock | ForEach-Object {

            $props = [ordered]@{
                StartIP = $_.startAddress
                EndIP = $_.endaddress
                Name = $response.net.orgRef.name
            }
            $outobj = New-Object -TypeName PSObject -Property $props

            Write-Output $outobj
            }
        }
        
}