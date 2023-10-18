function Rename-NCRComputer {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0)]
        [String[]]$ComputerName = (Get-CimInstance Win32_ComputerSystem).Name
    )
    BEGIN {
        [ValidateSet('Desktop','Laptop')]
        $prompt = Read-Host "Is $ComputerName Desktop or Laptop?"
        $ComputerType = $prompt
    }
    PROCESS {
        $RandomNumber = Get-Random -Minimum 1000 -Maximum 9999
        if ($null -ne $computerName) {
            $LocInitial = @('SS','HO','MC')

            if ($ComputerType -eq 'Desktop') {
                [ValidateSet('ShadySands','HeliosOne','McCarren')]
                $Location = Read-Host "Specify the location for these computers [ShadySands, HeliosOne, McCarren]"

                try {
                    switch ($Location) {
                        {$Location -eq 'ShadySands'} {
                            foreach ($computer in $computerName) {
                                Rename-Computer -ComputerName $computer -NewName "$($LocInitial[0])-DT$RandomNumber" -WhatIf
                            }
                        }
                        {$Location -eq 'HeliosOne'} {
                            foreach ($computer in $computerName) {
                                Rename-Computer -ComputerName $computer -NewName "$($LocInitial[1])-DT$RandomNumber" -WhatIf
                            }
                        }
                        {$Location -eq 'McCarren'} {
                            foreach ($computer in $computerName) {
                                Rename-Computer -ComputerName $computer -NewName "$($LocInitial[2])-DT$RandomNumber" -WhatIf
                            }
                        }
                    } #switch Location
                } catch [Microsoft.PowerShell.Commands.RenameComputerCommand] {
                    Write-Warning "$computer does not exist."
                }
            } elseif ($ComputerType -eq 'Laptop') {
                foreach ($computer in $computerName) {
                    Rename-Computer -ComputerName $computer -NewName "LAPTOP-$RandomNumber" -WhatIf
                }
            } #if Desktop/Laptop
        } #if $computername
    } #PROCESS
    END {

    }
}