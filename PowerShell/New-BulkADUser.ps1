
<#

    .DESCRIPTION
        Create bulk AD users using a CSV file.

    .NOTES
        This cmdlet is used for testing purposes only.

#>



function New-BulkADUser {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage="Enter the path to the CSV file")]
        [ValidateScript( {
            if (Test-Path $_) {
                $true
            }
            else {
                Throw "Path $_ doesn't exist!"
            }
        })]
        $CSV,
        [Parameter(Mandatory,HelpMessage="Type in a temporary password for all AD users")]
        [ValidateNotNullOrEmpty()]
        $TempPass
    ) #end Param

    BEGIN {
        Write-Output "Creating user accounts..."
    } #END BEGIN

    PROCESS {
        Import-CSV $CSV -Delimiter : | ForEach-Object {

            $ADUserArguments = {
                Name                    = "${$_.Firstname} ${$_.LastName}"
                GivenName               = ${$_.Firstname}
                SurName                 = ${$_.LastName}
                
                SamAccountName          = ${$_.SamAccountName}
                UserPrincipleName       = "${$_.SamAccountName}"

                AccountPassword         = (ConvertTo-SecureString -AsPlainText $TempPass -Force)

                Path                    = $OU
            } #end $ADUserArguments
            New-ADUser $ADUserArguments

            #Change user password at Logon
            Set-ADUser -Identity ${$_.SamAccountName} -PasswordAtNextLogOn $true
        } #end ForEach-Object

    } #END PROCESS

    END {
        Import-CSV $CSV | ForEach-Object {
            Get-ADUser -SamAccountName ${$_.SamAccountName}
        } #end ForEach-Object
    } #END
} #End New-BulkADUser
