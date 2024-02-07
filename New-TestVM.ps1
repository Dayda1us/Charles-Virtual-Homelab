function New-TestVM {
    <#
        .SYNOPSIS
            Creates a new VM using a created VM template.

        .NOTES
            This cmdlet only works if you have Hyper-V installed as it uses cmdlets from Hyper-V.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, 
            HelpMessage = "Specify the path where you put your VM templates.")]
        $VMTemplate,
        [Parameter(Manadatory,
            HelpMessage = "Specify the destination path where you want your VHD/VHDX file at.")]
        $DestinationPath,
        [Parameter(HelpMessage = "Power on the VM once it is created.")]
        $StartVM
    )

    BEGIN {
        if (Test-Path $VMTemplate -eq $true) {
            if (Test-Path $DestinationPath -eq $true) {
                try {
                    Copy-Item -Path $VMTemplate -Destination $DestinationPath
                } #End try
                catch {
                    Write-Warning "An error has occurred."
                    Write-Host $_ -Foreground Red
                } #end catch
            } #End if
        } #end if
        else {
            Write-Warning "The VM Template path doesn't exist. Please double check directory and try again."
            break
        } #end if
    } #END BEGIN

    PROCESS {

    } #END PROCESS

    END {

    } #END
}