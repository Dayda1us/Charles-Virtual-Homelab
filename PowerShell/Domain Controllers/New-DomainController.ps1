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

### DOMAIN CONTROLLER ARGUMENTS ###

# Domain credentials
$DCCredential = "cooldomain\Administrator"
# Domain Name
$DomainName = "cooldomain.com"

# Read Only Domain Controller
$ReadOnlyDC = $false

# Safe Mode Administrator Password
$Password = ""

# Site name
$SiteName = "Default-First-Site-Name"

# Install DNS
$InstallDNS = $true

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
if ((Get-ExecutionPolicy -Scope Process) -ne 'Bypass') {
    Write-Warning "Your current PowerShell execution policy is set to $(Get-ExecutionPolicy -Scope Process), which prevents scripts from running."
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
    Write-Host "AD Domain Services is already installed!"
} #end else

$DomainArgument = @{
    # Credentials
    Credential                    = $(Get-Credential $DCCredential)
    # Domain name
    DomainName                    = $DomainName

    # RODC
    ReadOnlyReplica               = $ReadOnlyDC
    
    # Directory Services Restore Mode Password (DSRM)
    SafeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText $Password -Force

    #Site Name
    SiteName                      = $SiteName
    
    # Install DNS server.
    InstallDns                    = $InstallDNS
    
    # Specify the DC directory paths
    DatabasePath                  = $DatabasePath
    LogPath                       = $LogPath
    SysVolPath                    = $SysVolPath
} #end $DomainArgument


# Test the forest arguments. If passed, proceed to install the forest.
if ((Test-ADDSDomainControllerInstallation @DomainArgument).Status -eq "Success") {
    Write-Output "Creating a new domain controller..."
    try {
        Install-ADDSDomainController @DomainArgument -Confirm:$true
        Write-Host "The Domain Controller has been successfully installed!" -ForegroundColor Green
    } #end try
    catch {
        Write-Error "An error occurred while creating the forest: $_"
        Pause
        exit
    } #end catch
} #end if
else {
    Write-Output "Failed the domain contoller test!"
    Pause
    exit
} #end else