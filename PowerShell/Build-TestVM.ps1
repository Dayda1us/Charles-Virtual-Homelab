
<#
    .SYNOPSIS
        Creates a new VM by copying a VHD/VHDx template then starting up the virtual machine

    .NOTES
        This cmdlet only works if Hyper-V is installed on the computer as it uses a few cmdlets from Hyper-V.

    .PARAMETER SourcePath
        Specifies the folder where the VHD/VHDx template files are located.
    .PARAMETER DestinationPath
        Specifies the destination path where VHD/VHDx files are kept.
    .PARAMETER VHDName
        Specifies the name of the VHD/VHDx file. The parameter must include either the .vhd or .vhdx file extention.
    .PARAMETER VMName
        Specifies a name for the virtual machine (VM). If no name is given, it'll use the default VM name: Test VM.
    .PARAMETER StartVM
        Specifies whether to power on the virutal machine (VM) once the VM is created.
    .NOTES
        Author: Charles Thai
        Created: February 22, 2024
#>

# This cmdlet requires administrative privileges.
#Requires -RunAsAdministrator

[CmdletBinding()]
Param(
    [Parameter(HelpMessage = "Specify the folder where you keep your VHD/VHDx files.", Mandatory)]
    $SourcePath,
    [Parameter(HelpMessage = "Specify the name of the VHD/VHDx template. You must include either the .vhd or .vhdx file extention.", Mandatory)]
    $VHDName,
    [Parameter(HelpMessage = "Specify the destination path where you store your VMs.")]
    $DestinationPath = "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks",
    [Parameter(HelpMessage = "Name the test VM.")]
    $VMName = "Test VM",
    [Parameter(HelpMessage = "Start the VM once it is created.")]
    $StartVM = $false
)

BEGIN {
    if ((Test-Path $SourcePath\$VHDName) -eq $true) {
        if ((Test-Path $DestinationPath) -eq $True) {
            Write-Output "Copying VHD to $DestinationPath."
            try {
                Copy-Item -Path $SourcePath\$VHDName -Destination $DestinationPath
            } #end try
            catch {
                Write-Warning "An error has occurred that could not be resolved!"
                Write-Host $_ -ForegroundColor Red
                start-sleep -Seconds 3
                exit
            } #end catch
        }
    }
    else {
        Write-Warning "$SourcePath is a non-existant path! Please double check the path and try again."
        start-sleep -Seconds 3
        exit
    }
} #End BEGIN

PROCESS {
    Write-Output "Creating a new VM."
    try {
        if ((Test-Path $DestinationPath\$VHDName) -eq $true) {
            New-VM -Name $VMName -MemoryStartupBytes 4GB -Generation 2 -VHDPath $DestinationPath\$VHDName
            if ($startVM -eq $true) {
                Write-Output "Starting the VM..."
                Start-sleep -Seconds 5
                Start-VM $VMName
            }
        } # end if
    } #End try
    catch {
        Write-Warning "An error occurred that could not be resolved."
        Write-Host $_ -ForegroundColor Red
        Start-Sleep -Seconds 3
        exit
    } #End catch

} #End PROCESS

END {
    if ((Get-VM).VMName -contains $VMName) {
        Write-Output "The operation was successful!"
    } #end if
    else {
        Write-Output "Operation has been cancelled."
    } #end else
} #END
