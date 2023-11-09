function Test-InternetConnection {
    [CmdletBinding()]
    Param()

    BEGIN {
        Write-Verbose -Message "[BEGIN] Running an Internet connectivity check for $((Get-CimInstance Win32_ComputerSystem).Name)"
        Write-Output "Checking for Internet connectivity...."
    } #BEGIN
    PROCESS {
        # Company Website
        $TestWebsite = "3RTechnology.com"

        # If there is no Internet connection, display an error until an Internet connection is found.
        Write-Verbose -Message "[PROCESS] Checking if $((Get-CimInstance -ClassName Win32_ComputerSystem).Name) can ping to $TestWebsite"
        while (-not((Test-Connection $TestWebsite -Quiet -Count 1) -eq $true)) {
            Write-Warning "No Internet connection found. Please double check your network configuration. Retrying..."
            Start-Sleep -Seconds 5
        }
    }#PROCESS
    END {
        Write-Verbose -Message "[END] $((Get-CimInstance -ClassName Win32_ComputerSystem).Name) successfully pings $TestWebsite"
        Write-Host "Internet connection established!" -ForegroundColor Green
        Start-sleep -Seconds 5
        Clear-Host
    } #END 
}#Test-InternetConnection