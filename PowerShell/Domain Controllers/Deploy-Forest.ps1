############################################################
#                                                          #
#                 FOR TESTING PURPOSES ONLY                #
#                                                          #
#   This script automates the deployment of creating       #
#   a Domain Controller (DC).                              #
#                                                          #
############################################################ 


function Deploy-NCRForest {
    [CmdletBinding()]
    Param()

    BEGIN {
        $ForestName = "NCR.com" # <-- Rename the forest however you like.
        $IntAlias = 'Ethernet0' # <-- Change interface index if needed. Default is Ethernet0 if network adapter is set to E1000E on VMware.

        # Prequisite Check
        Write-Verbose "[BEGIN] Checking if $env:COMPUTERNAME is running Windows Server 2016 or later."
        Write-Output "Performing a prerequisite check..."
        $OS = (Get-ComputerInfo).OsName

        # If the operating system is not running Windows Server 2016 or later, notify the user that this cmdlet will not work without Server 2016 or later.
        Write-Verbose "[BEGIN] Checking the host operating system"
        if ($OS -notmatch "Windows Server" -and (($PSVersionTable).PSVersion).Major -gt 4) {
            Write-Warning "$OS is not supported. Only Windows Server 2016 or later can perform the operation."
            start-sleep -Seconds 2
            break
        } #if ($OS -notmatch "Windows Server")

        $ForestName = "NCR.com" # Rename the forest however you like.

        # WARN THE USER THAT IF THEY HAVE ALREADY SETUP A HOSTNAME AND STATIC IP FOR THIS SERVER.

        Write-Warning "You are about to deploy a new forest on this server. Before running the script, double check the hostname and the IP address is set to static."
        Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object @{Name = "TARGET SERVER"; e = { $_.Name } } | Format-List
        Get-NetIPConfiguration -InterfaceAlias $IntAlias
        Write-Output "Forest Name: $ForestName`n"

        $Title       = 'DC Forest Deployment'
        $Description = "You are about to create new forest name $ForestName. Are you sure you want to do this?"
        $Yes         = New-Object System.Management.Automation.Host.ChoiceDescription "&Y", "Deploy $Forestname"
        $No          = New-Object System.Management.Automation.Host.ChoiceDescription "&N", "Do not deploy a new forest at this time."
        $Options     = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
        $Default     = 1    # 0 = Yes, 1 = No
        
        
        do {
            $NCRForestResponse = $Host.UI.PromptForChoice($Title, $Description, $Options, $Default)
            if ($NCRForestResponse -eq 0) {
                return 0 | Out-Null
            }
        } until ($NCRForestResponse -eq 1)
    } #BEGIN

    PROCESS {
        if ($NCRForestResponse -eq 0) {
            Write-Output "Installing Active Directory Domain Services..."
            try {
                if ((Get-WindowsFeature AD-Domain-Services).InstallState -contains "Installed") {
                    Write-Warning "AD DS is already installed on $env:COMPUTERNAME!"
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

            Write-Output 'Please set a password for the Directory Services Restore Mode (DSRM)'
            Write-Warning 'Please keep the password in a safe place. If you lose the password, you will not be able to recover your Active Directory.'
            $Password = Read-Host 'Password' -AsSecureString
    
                
            $ForestArguments = @{ 
    
                # Domain name
                DomainName                    = $ForestName
    
                # Directory Services Restore Mode Password (DSRM)
                SafeModeAdministratorPassword = $Password
                
                # Specify the forest and domain functional level.
                ForestMode                    = 7 # Windows Server 2016
                DomainMode                    = 7 # Windows Server 2016
    
                # Specify the location name for each of these.
                DatabasePath                  = "$ENV:WINDIR\NTDS"
                LogPath                       = "$ENV:WINDIR\NTDS"
                SysVolPath                    = "$ENV:WINDIR\SYSVOL"
    
            } #$ForestArguments
    
            Test-ADDSForestInstallation @ForestArguments
    
            Install-ADDSForest @ForestArguments
        } #if ($NCRForestResponse -eq 0)
    } #PROCESS

    END {
        if ($NCRForestResponse -ne 0 -or $PrereqResponse -ne 'Y') {
            Write-Warning "Operation cancelled on $env:COMPUTERNAME."
            Start-Sleep -Seconds 1
            exit
        }
        else {
            Write-Output 'The operation was successful'
        } #if/else ($NCRForestResponse -ne 0)
    } #END
} #function Deploy-NCRForest

Deploy-NCRForest
