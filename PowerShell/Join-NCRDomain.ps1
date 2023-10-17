function Join-NCRDomain {
    [CmdletBinding()]
    Param(
        [String[]]$computerName
    )

    BEGIN {
        $RandomNumber = Get-Random -Minimum 10000000 -Maximum 99999999
        if ($null -ne $computerName) {
            [ValidateSet('Desktop','Laptop')]
            $ComputerType = Read-Host "Are $computerName Desktop or Laptop?"
            if ($ComputerType -eq 'Desktop') {
                foreach ($computer in $computerName) {
                    Rename-Computer -ComputerName $computer -NewName "DESKTOP-$RandomNumber" -WhatIf
                }
            } elseif ($ComputerType -eq 'Laptop') {
                foreach ($computer in $computerName) {
                    Rename-Computer -ComputerName $computer -NewName "LAPTOP-$RandomNumber" -WhatIf
                }
            }
        }

    }
    PROCESS {

    }
    END {

    }
}