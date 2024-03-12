############################################################
#                                                          #
#                 FOR TESTING PURPOSES ONLY                #
#                                                          #
#   This script automates the deployment of creating       #
#   a Domain Controller (DC).                              #
#                                                          #
############################################################ 

#requires -version 5.0

function Deploy-Forest {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter a domain name for your forest")]
        [ValidateNotNullOrEmpty()]
        [String]$ForestName,

        [Parameter(Mandatory, HelpMessage = "Enter the forest level. Lowest level is 2 (Windows Server 2003).")]
        [ValidateRange(2,7)]
        [int]$ForestLevel,

        [Parameter(Mandatory, HelpMessage = "Enter the domain level. Lowest level is 2 (Windows Server 2003).")]
        [ValidateRange(2,7)]
        [int]$DomainLevel
    )

    BEGIN {
        # Prequisite Check
        Write-Verbose "[BEGIN] Checking if $env:COMPUTERNAME is running Windows Server 2016 or later."
        Write-Output "Performing a prerequisite check..."
        $OS = (Get-ComputerInfo).OsName

        # If the operating system is not running Windows Server 2016 or later, notify the user that this cmdlet will not work without Server 2016 or later.
        Write-Verbose "[BEGIN] Checking the host operating system"
        if ($OS -notmatch "Windows Server") {
            Write-Warning "$OS is not supported. Only Windows Server 2016 or later can perform the operation."
            start-sleep -Seconds 2
            exit
        } #if ($OS -notmatch "Windows Server")

        Write-Output 'Please set a password for the Directory Services Restore Mode (DSRM)'
        Write-Warning 'Please keep the password in a safe place. If you lose the password, you will not be able to recover your Active Directory.'
        #$Password = Read-Host 'Password' -AsSecureString

        $Title = 'DC Forest Deployment'
        $Description = "You are about to create new forest name $ForestName. Make sure you have already setup a static IP address as well as well as modified the hostname of the server. Would you like to deploy Active Directory Domain Services now?"
        $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Y", "Deploy $ForestName"
        $No = New-Object System.Management.Automation.Host.ChoiceDescription "&N", "Do not deploy a new forest at this time."
        $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
        $Default = 1    # 0 = Yes, 1 = No
        
        
        do {
            $ForestResponse = $Host.UI.PromptForChoice($Title, $Description, $Options, $Default)
            if ($ForestResponse -eq 0) {
                return 0 | Out-Null
            }
        } until ($ForestResponse -eq 1)
    } #BEGIN

    PROCESS {
        if ($ForestResponse -eq 0) {
            Write-Output "Installing Active Directory Domain Services..."
            try {
                if ((Get-WindowsFeature AD-Domain-Services).InstallState -contains "Installed") {
                    Write-Warning "AD DS is already installed on $env:COMPUTERNAME!"
                    Start-Sleep -seconds 3
                }
                else {
                    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
                }
            }
            catch {
                Write-Warning 'An error has occurred that could not be resolved.'
                Write-Host $_ -ForegroundColor Red
                Write-Warning "Operation cancelled on $env:COMPUTERNAME."
                Start-Sleep -Seconds 3
                exit
            }#try/catch
                
            $ForestArguments = @{ 
    
                # Domain name
                DomainName                    = $ForestName
    
                # Directory Services Restore Mode Password (DSRM)
                SafeModeAdministratorPassword = $Password
                
                # Specify the forest and domain functional level.
                ForestMode                    = $ForestLevel
                DomainMode                    = $DomainLevel
    
                # Specify the location name for each of these.
                DatabasePath                  = "$ENV:WINDIR\NTDS"
                LogPath                       = "$ENV:WINDIR\NTDS"
                SysVolPath                    = "$ENV:WINDIR\SYSVOL"
    
            } #$ForestNameArguments
    
            Test-ADDSForestInstallation @ForestArguments
            Install-ADDSForest @ForestArguments
        } #if ($NCRForestResponse -eq 0)
    } #PROCESS

    END {
        if ($ForestResponse -eq 1) {
            Write-Warning "Operation cancelled on $env:COMPUTERNAME."
            Start-Sleep -Seconds 1
            exit
        } #end if
        else {
            Write-Output 'The operation was successful'
        } #if/else ($NCRForestResponse -ne 0)
    } #END
} #function Deploy-Forest
