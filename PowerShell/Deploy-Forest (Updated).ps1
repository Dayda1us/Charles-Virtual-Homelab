############################################################
#                                                          #
#                 FOR TESTING PURPOSES ONLY                #
#                                                          #
#   This script automates the deployment of creating       #
#   a Domain Controller (DC).                              #
#                                                          #
############################################################ 

#Enable Debugging
#Set-PSDebug -Trace 1

#################################################
#           Editable Variables Begin            #
#################################################
# You only have to edit this part of the script #
#################################################

# Include Active Directory Management Tools
$ADMgmtTools = "-IncludeManagementTools"


########################
#   FOREST ARGUMENTS   #
########################

# Domain Name
$DomainName = "cooldomain.com"

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
$ForestMode = 7
$DomainMode = 7

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

function Add-SafeModeAdminPassword {
    while ($createPassword -ne '') {
        $createPassword = Read-Host "Please enter the Safe Mode Administrator password" -AsSecureString
    } #end while   
    $confirmPassword = Read-Host "Confirm the Safe Mode Administrator password" -AsSecureString

    Convert both secure strings to plain text
    $createPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($createPassword))
    $confirmPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword))

    if ($createPlainText -eq $confirmPlainText) {
        $confirmPlainText
    } #end if
    else {
        Write-Warning "Password do not match. Please try again!"
        $createPassword = ''
        Add-SafeModeAdminPassword
    } #end else
} #end function

# Check if Active Directory Domain Services (ADDS) is installed.
if (Get-WindowsFeature -Name AD-Domain-Services) {
    Write-Output "$((Get-WindowsFeature -Name AD-Domain-Services).Name) is already installed!"
    Enable-Password
} #end if
else {
    Write-Warning "Installing $((Get-WindowsFeature -Name AD-Domain-Services).Name)..."
    Install-WindowsFeature -Name AD-Domain-Services $ADMgmtTools
    Enable-Password
} #end if

$ForestArguments = @{ 
    
    # Domain name
    DomainName                    = $DomainName

    # Directory Services Restore Mode Password (DSRM)
    SafeModeAdministratorPassword = $confirmPlainText
        
    # Specify the forest and domain functional level.
    ForestMode                    = $ForestMode
    DomainMode                    = $DomainMode

    # Specify the location name for each of these.
    DatabasePath                  = $DatabasePath
    LogPath                       = $LogPath
    SysVolPath                    = $SysVolPath

} #$ForestNameArguments

if ((Get-WindowsFeature AD-Domain-Services).InstallState -eq "Installed") {
    Write-Output "Verifying..."
    if ((Test-ADDSForestInstallation @ForestArguments).Status -eq "Success") {
        Write-Warning "Creating the AD forest"
        Install-ADDSForest @ForestArguments
    } #end if
    else {
        Write-Warning "ADDS forest test failed!"
        Start-Sleep -Seconds 5
        exit
    } #end else
} #end if