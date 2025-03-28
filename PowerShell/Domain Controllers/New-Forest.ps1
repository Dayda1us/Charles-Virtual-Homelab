#################################################
#           Editable Variables Begin            #
#################################################
# You only have to edit this part of the script #
#################################################

### DIAGNOSTIC TOOLS ###

#Enable Debugging
#Set-PSDebug -Trace 1

### ACTIVE DIRECTORY MANAGEMENT TOOLS ###

# Include Active Directory Management Tools
$ADMgmtTools = "-IncludeManagementTools"

### FOREST ARGUMENTS ###

# Forest Name
$ForestName = "cooldomain.com"

# Safe Mode Administrator Password
$Password = ""

<#
Domain Mode & Forest Mode

The acceptable values for these parameters are:
Windows Server 2003     : 2 / Win2003
Windows Server 2008     : 3 / Win2008
Windows Server 2008 R2  : 4 / Win2008R2
Windows Server 2012     : 5 / Win2012
Windows Server 2012 R2  : 6 / Win2012R2
Windows Server 2016     : 7 / WinThreshold

#>
$ForestLevel = 7
$DomainLevel = 7

# Specify the location name for each of these.
$DatabasePath = "$env:WINDIR\NTDS"
$LogPath = "$env:WINDIR\NTDS"
$SysVolPath = "$env:WINDIR\SYSVOL"

#################################################
#            Editable Variables End             #
#################################################

######################################################################################
# No edits should take place beyond this comment unless you know what you're doing!  #
# All changes should be made in the Variables section.                               #
######################################################################################

# This function is used to check if a feature in Windows Server is installed. In this case: Active Directory Domain Services.
function IsFeatureInstalled {
    param (
        [string]$FeatureName
    )
    return (Get-WindowsFeature -Name $FeatureName).InstallState -eq 'Installed'
}

# Check if execution policy is set to Bypass
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'Bypass') {
    Write-Warning "Your current PowerShell execution policy is set to $(Get-ExecutionPolicy -Scope CurrentUser), which prevents scripts from running."
    $execResponse = Read-Host "Would you like to change it? [Y/N]"
    if ($execResponse -eq "Y") {
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Confirm:$false
    } #end if
    else {
        Write-Host "This script can't be run without changing the execution policy. Aborting script..." -ForegroundColor Red
        Start-Sleep -Seconds 2
        exit
    } #end else
} #end if

# Check if ADDS is installed on the server.
if (-not (IsFeatureInstalled -FeatureName "AD-Domain-Services")) {

    Write-Host "Installing AD Domain Services and Management Tools..."
    Install-WindowsFeature -Name AD-Domain-Services $ADMgmtTools -Restart
} #end if
else {
    Write-Host "AD Domain Services is already installed."
} #end else

$ForestArgument = @{
    # Domain name
    DomainName                    = $ForestName
    
    # Directory Services Restore Mode Password (DSRM)
    SafeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText $Password -Force
                
    # Specify the forest and domain functional level.
    ForestMode                    = $ForestLevel
    DomainMode                    = $DomainLevel
    
    # Specify the location name for each of these.
    DatabasePath                  = $DatabasePath
    LogPath                       = $LogPath
    SysVolPath                    = $SysVolPath
} #end $ForestArguments


# Test the forest arguments. If passed, proceed to install the forest.
if ((Test-ADDSForestInstallation @ForestArgument).Status -eq "Success") {
    Write-Output "Creating a new AD forest..."
    try {
        Install-ADDSForest @ForestArgument
        Write-Host "Your new forest has been successfully installed!" -ForegroundColor Green
    } #end try
    catch {
        Write-Error "An error occurred while creating the forest: $_"
        Pause
        exit
    } #end catch
} #end if
else {
    Write-Output "Failed the ADDS Forest Installation test!"
    Pause
    exit
} #end else