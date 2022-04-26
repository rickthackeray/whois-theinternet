<#
.SYNOPSIS
Get staff information from Active Directory using wildcard searches.

.DESCRIPTION
Get-Staff is an in-house tool to make finding staff information within Active Directory easier.

.NOTES
So that partial strings match, there are implied wildcards added to the start and end of the search string.


.EXAMPLE
PS C:\> Get-Staff r*.tha


Name       : Thackeray, Richard
Account    : Richard.Thackeray
Office     : District Office
Title      : Technical Support 2
Phone      : 541-757-3903
Enabled    : True
Expiration : 

.EXAMPLE
PS C:\> Get-Staff 3954


Name       : Cadotte, Andy
Account    : Andy.Cadotte
Office     : District Office
Title      : Technical Support 2
Phone      : 541-757-3954
Enabled    : True
Expiration : 


#>
Function Get-Staff {
    [CmdletBinding()]
    Param(
        [Parameter(
            Position=0,
            Mandatory=$True,
            ValueFromPipeline=$True,
            HelpMessage="Search string - can be First, Last, Account, or Phone Number")]
        [string]$Search,
        [switch]$FirstOnly,
        [switch]$LastOnly,
        [switch]$SamAccountName
    )
    Process {
        if ($FirstOnly) {
            $Method = "GivenName"
        }
        elseif ($LastOnly) {
            $Method = "Surname"
        }
        elseif ($SamAccountName) {
            $Method = "SamAccountName"
        }
        else {
            Switch -Regex ($Search) {
                '[\d]' { $Method = "OfficePhone"; break}
                default { $Method = "Name"; break }
            }
        }

        Write-Verbose "Searching for $Search using $Method"
        $staffs = Get-ADUser -Filter "$Method -like '*$Search*'" -Properties OfficePhone,Office,Title,Enabled,MemberOf,AccountExpirationDate,EmailAddress,Description,Department,LockedOut
        foreach ($staff in $staffs) {
            $props = [ordered]@{
                       Name = $staff.Name
                       Account = $staff.SamAccountName
                       Email = $staff.EmailAddress
                       Department = $staff.Department
                       Office = $staff.Office
                       Title = $staff.Title
                       Description = $staff.Description
                       Phone = $staff.OfficePhone
                       Enabled = $staff.Enabled
                       Expiration=$staff.AccountExpirationDate
                       Locked=$staff.LockedOut
                      }
            $obj = New-Object -TypeName PSObject -Property $props
            Write-Output $obj
        }
    }
}  