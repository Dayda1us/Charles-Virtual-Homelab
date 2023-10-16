Function Get-DiskCheck {
    [CmdletBinding(DefaultParameterSetName = 'name')]
    Param(
        [Parameter(Mandatory,
                HelpMessage = "Enter a computer name to check",
                ParameterSetName = 'name',
                Position = 0,
                ValueFromPipeline)]
        [Alias("cn")]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,

        [Parameter(Mandatory,
                HelpMessage = "Enter the path to a text file of computer names",
                ParameterSetName = "file"
                )]
                [ValidateScript( {
                    if (Test-Path $_) {
                        $true
                    }
                    else {
                        Throw "Cannot validate path $_"
                    }
                })]
                [ValidatePattern("\.txt$")]
                [string]$Path,

                [ValidateRange(10, 50)]
                [int]$Threshold = 25,

                [ValidateSet("C:", "D:", "E:", "F:")]
                [string]$Drive = "C:",

                [switch]$test
    )

    Begin {
        Write-Verbose " [BEGIN    ] Starting: $($MyInvocation.MyCommand)"

        $cimParam = @{
            Classname          = "Win32_LogicalDisk"
            Filter             = "DeviceID = '$Drive'"
            ComputerName       = $null
            ErrorAction        = "Stop"
        }
    } #begin

    Process {

        if ($PSCmdlet.ParameterSetName -eq 'name') {
            $names = $ComputerName
        }
        else {
            # Get list of names and trim off any extra spaces
            Write-Verbose "[PROCESS] Importing names from $path"
            $names = Get-Content -Path $path | Where-Object {$_ -match "\w+"} | ForEach-Object {$_.Trim()}
        }

        if ($test) {
            Write-Verbose "[PROCESS] Testing connectivity"
            # Ignore errors for offline computers
            $names = $names | Where-Object {Test-WSMan $_ -ErrorAction SilentlyContinue}
        }

        foreach ($computer in $names) {
            $cimParam.ComputerName = $computer
            Write-Verbose "[PROCESS] Querying $($computer.ToUpper())"
            Try {
                $data = Get-CimInstance @cimParam

                # Write custom results to the pipeline
                $data | Select-Object PSComputerName, DeviceID, Size, Freespace,
                @{Name = "PctFree"; E = {[math]::Round($_.Freespace / $_.Size * 100, 2)}},
                @(Name = "OK"; E = { 
                    [int]$p = ($_.Freespace / $_.Size * 100) 
                    if ($p -ge $Threshold) {
                        $true
                    }
                    else {
                        $false
                    }
                }), @{Name = "Date"; E = { (Get-Date)}}
            }
            catch {
                Write-Warning "[$($computer.ToUpper())] Failed. $($_.Exception.Message)"
            }
        } #foreach computer
    } #process
    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.MyCommand)"
    } #end
}