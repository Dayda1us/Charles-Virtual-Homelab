function Install-RSAT {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$true)]
            [ValidateSet("WindowsClient","WindowsServer")]
            $OperatingSystem
        ) #end param
        
        BEGIN {
            # Check the operating system. Abort the cmdlet if the user attempts to run this cmdlet on an older version of Windows
            $OS = [System.Environment]::OSVersion.Version

            if ($OS.Major -lt 10) {
                Write-Warning "Sorry this cmdlet does not support older versions of Windows. Please update your system and try again."
                exit
            } #end if
        } #end BEGIN
        
        PROCESS {
            function Get-Status {
                $Table = [System.Collections.ArrayList]@()
                Get-Job | ForEach-Object  {
                    $Job = $_
                    $Status = $Job.State
                    $Name = $Job.Name
                } #end Get-Job | ForEach-Object
                [Void]$Table.Add([PSCustomObject]@{
                    Name = $Job.Name
                    Status = $Status
                })
            } #end function

            switch ($OperatingSystem) {
                { $OperatingSystem -eq "WindowsClient"} {
                    # Verify if the OS is a Windows Client.
                    $ProductType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
                    if (!($ProductType -eq 1)) {
                        Write-Warning "This is not a Windows client! Aborting process!"
                        exit
                    } #end if
                    else {
                        $Capabilities = Get-WindowsCapability -Online -Name RSAT* 
                        $Capabilities | ForEach-Object {
                            $Capability = $_
                            $CapabilityName = $Capability.Name
                            $JobName = "$($Capability.DisplayName)"
                            Start-Job -Name $JobName -ScriptBlock {
                                param($RSATCapability)
                                Add-WindowsCapability -Name $RSATCapability -Online
                            } -ArgumentList $CapabilityName
                        }
                    } #end else
                } #end { $OperatingSystem -eq "WindowsClient"}

                { $OperatingSystem -eq "WindowsServer"} {
                    # Verify if the OS is a Windows Server.
                    $ProductType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
                    if (!($ProductType -eq 2) -or !($ProductType -eq 3)) {
                        Write-Warning "This is not a Windows Server! Aborting process!"
                        exit
                    } #end if
                    else {
                        $Features = (Get-WindowsFeature -Name RSAT*).Name
                        $Features | ForEach-Object {
                            $Feature = $_
                            $FeatureName = $Feature.Name
                            $JobName = "$($Feature.DisplayName)"
                            Start-Job -Name $JobName -ScriptBlock {
                                param($RSATFeature)
                                Install-WindowsFeature -Name $RSATFeature -IncludeAllSubFeature
                            } -ArgumentList $FeatureName
                        } #end $Features | ForEach-Object
                    } #end else
                } #end { $OperatingSystem -eq "WindowsClient"}
            } #end switch

            # Monitor the job status
            while (Get-Job -State "Running") {
                Clear-Host
                Get-Status
                Start-Sleep -Seconds 5
            } #end while
            
        }#end PROCESS
        
        END {
            Clear-Host
            Get-Status
        } #END
} #end function

Install-RSAT