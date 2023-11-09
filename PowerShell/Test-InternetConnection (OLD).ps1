function Test-InternetConnection {
    [CmdletBinding()]
    Param()

    BEGIN {
        Write-Verbose -Message "[BEGIN] Running an Internet connectivity check for $((Get-CimInstance Win32_ComputerSystem).Name)"
        Write-Output "Checking for Internet connectivity...."

        # Grabs the current version of Powershell by its Major version number.
        $PSVersion = (Get-Host | Select-Object Version).Version
        $CurrentPSVersion = $PSVersion.Major
    } #BEGIN
    PROCESS {
        # For Windows PowerShell v5 or below.
        if ($CurrentPSVersion -lt 6) {
            while ((Test-Connection 3rtechnology.com -Count 1 -EA SilentlyContinue).ResponseTime -lt 0) {
                Write-Warning -Message "No Internet connection. Please double check your network configuration. Retrying..."
                start-sleep -seconds 5
            } #while (Test-Connection 3rtechnology.com -Count 1 -EA SilentlyContinue).ResponseTime -lt 0)
        # For PowerShell (NOT Windows PowerShell) v6 or later.
        } elseif ($CurrentPSVersion -gt 5) {
            while ((Test-Connection 3rtechnology.com -Count 1 -EA SilentlyContinue).Latency -lt 0) {
                Write-Warning -Message "No Internet connection. Please double check your network configuration. Retrying..."
                start-sleep -seconds 5
            } #while (Test-Connection 3rtechnology.com -Count 1 -EA SilentlyContinue).Latency -lt 0)
        } #if/else
    }#PROCESS
    END {
        Write-Host "Internet connection established!" -ForegroundColor Green
        Start-sleep -Seconds 5
        Clear-Host
    } #END 
}#Test-InternetConnection