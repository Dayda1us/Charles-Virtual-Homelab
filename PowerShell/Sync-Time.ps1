function Sync-Time {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]$Timezone,
        [Parameter(
            HelpMessage = "Enter a computer name to check",
            ParameterSetName = 'name',
            Position = 0,
            ValueFromPipeline)]
        [Alias("cn")]
        [String[]]$ComputerName
    )

    BEGIN {
        Write-Verbose "Retrieving the timezone and preferred timezone."
        Write-Output 'Checking the current timezone...'
        # Checks the current timezone of the computer
        $CurrentTimeZone = (Get-TimeZone).Id

        # The preferred timezone.
        $PreferredTimeZone = (Get-TimeZone -ID $Timezone).Id

    } #BEGIN
    PROCESS {

        Start-sleep -Seconds 2

        # Set the preferred Timezone if current timezone is set incorrectly.
        Write-Verbose "[BEGIN] Checking the timezone for $((Get-CimInstance Win32_ComputerSystem).Name)"
        if ($CurrentTimeZone -eq $PreferredTimeZone) {
            Write-Output "Timezone is already set to $PreferredTimeZone`n"
            Get-TimeZone
        } else {
            Set-TimeZone -ID $PreferredTimeZone
            Get-Date
            Write-Output "Timezone changed to $PreferredTimeZone`n"
            Get-TimeZone
        } #if/else

        # Name of the Windows Time service
        $WindowsTime = 'W32Time'

        Write-Output "Syncing the local time..."
        if ((Get-Service -Name $WindowsTime).Status -eq 'Stopped') {
            Write-Output "Starting $WindowsTime..."
            Start-Sleep -seconds 2
            try {
                Write-Verbose "[PROCESS] Starting $WindowsTime on $ComputerName"
                Start-Service -Name $WindowsTime -EA Stop
                # IF "W32Time" started successfully, run the "w32tm /resync" command.
                if ((Get-Service -Name $WindowsTime).Status -eq 'Started')
                {
                    Write-Verbose "[PRCOESS] Syncing the local time using 'w32tm /resync' on $ComputerName"
                    Write-Output 'Syncing local time...'
                    start-sleep -Seconds 2
                    Invoke-Command -ScriptBlock {w32tm.exe /resync} -ComputerName $ComputerName
                    Get-Date
                } #if (Get-Service -Name $WindowsTime).Status -eq 'Started')
            } catch {
                Write-Warning "An error has occurred that could not be resolved."
                Write-Host $_ -ForegroundColor Red
                break
            } #try/catch
        } else {
            Write-Output "$WindowsTime is already running. Syncing local time..."
            Get-Service -Name W32Time
            if ((Get-Service -Name $WindowsTime).Status -eq 'Started')
            {
                Write-Verbose "[PRCOESS] Syncing the local time using 'w32tm /resync' on $ComputerName"
                Write-Output 'Syncing local time...'
                start-sleep -Seconds 2
                w32tm.exe /resync
                (Get-Date).DateTime
            } #if ((Get-Service -Name $WindowsTime).Status -eq 'Started')
        } #if/else ((Get-Service -Name $WindowsTime).Status -eq 'Stopped')
    } #PROCESS
    END {
        Write-Verbose "[END] Verifying that the timezone and today's date is synced"
        if ($CurrentTimeZone -eq $PreferredTimeZone -and (Get-Date).DateTime -eq (Get-Date).DateTime) {
            Write-Host 'The operation was successful' -ForegroundColor Green
            Get-TimeZone
            Get-Date
        } else {
            Write-Warning 'The operation was not successful'
        } #if/else ($CurrentTimeZone -eq $PreferredTimeZone -and (Get-Date).DateTime -eq (Get-Date).DateTime)
    }#END
}#Sync-Time