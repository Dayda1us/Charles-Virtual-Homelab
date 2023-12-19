############################################################
#                                                          #
#                 FOR TESTING PURPOSES ONLY                #
#                                                          #
#   This script automates the deployment of promoting      #
#   a Domain Controller (DC) to an existing DC.            #
#                                                          #
############################################################   

function Deploy-DomainController {
    [CmdletBinding()]
    Param()

    BEGIN {
        $ForestName = "NCR.com" # <-- Forest name must match if you plan on adding a new DC to an existing DC.
        $IntAlias = 'Ethernet0' # <-- Change interface index if needed. Default is Ethernet0 if network adapter is set to E1000E on VMware.

        # Prequisite Check
        Write-Verbose "[BEGIN] Checking if $env:COMPUTERNAME is running Windows Server 2016 or later."
        Write-Output "Performing a prerequisite check..."
        $OS = (Get-ComputerInfo).OsName

        # If the operating system is not running Windows Server 2016 or later, warn the user that this cmdlet will not work without Server 2016 or later.
        Write-Verbose "[BEGIN] Checking the host operating system"
        if ($OS -notmatch "Windows Server" -and (($PSVersionTable).PSVersion).Major -gt 4) {
            Write-Warning "$OS is not supported. Only Windows Server 2016 or later can perform the operation."
            start-sleep -Seconds 2
            break
        } #End If

        # Check the IPv4/IPv6 configuration if it is set to static. Warn the user if DHCP is enabled on the server.
        Write-Verbose "[BEGIN] Checking IPv4 configuration on $env:COMPUTERNAME"
        $IPv4Dhcp = (Get-NetIPInterface -AddressFamily Ipv4 -Dhcp Enabled -InterfaceAlias $IntAlias).Dhcp -eq 'Enabled'
        if ($IPv4Dhcp -eq $true) {
            Write-Warning "IPv4 DHCP is enabled on $env:COMPUTERNAME. Please set a static IP address and rerun the script."
            start-sleep 5
            exit
        } #End if
    } #BEGIN
    
    PROCESS {
        # WARN THE USER THAT IF THEY HAVE ALREADY SETUP A HOSTNAME AND STATIC IP FOR THIS SERVER.
        $Title = 'DC Promotion'
        $Description = "You are about to promote this server onto to an existing $ForestName Domain Controller. Are you sure you want to do this?"
        $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Promote this server."
        $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not promote this server at this time."
        $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
        $Default = 1    # 0 = Yes, 1 = No

        Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object @{Name = "TARGET SERVER"; e = { $_.Name } } | Format-List
        Get-NetIPConfiguration -InterfaceAlias $IntAlias
        Write-Output "Forest Name: $ForestName`n"
        
        
        do {
            $NCRDomainResponse = $Host.UI.PromptForChoice($Title, $Description, $Options, $Default)
            if ($NCRDomainResponse -eq 1) {
                # No
                return 1 | Out-Null
            }
        } until ($NCRDomainResponse -eq 0) #do/until

        if ($NCRDomainResponse -eq 0) {

            Write-Verbose -Message "[PROCESS] Checking if $env:COMPUTERNAME has AD DS installed."
            Write-Output "Installing Active Directory Domain Services..."
            try {
                if ((Get-WindowsFeature AD-Domain-Services).InstallState -contains "Installed") {
                    Write-Warning "AD DS is already installed on $((Get-Ciminstance Win32_ComputerSystem).Name)!"
                }
                else {
                    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
                } #if/else ((Get-WindowsFeature AD-Domain-Services).InstallState -contains "Installed")
            }
            catch {
                Write-Warning 'An error has occurred that could not be resolved.'
                Write-Host $_ -ForegroundColor Red
                Write-Warning "Operation cancelled on $env:COMPUTERNAME."
                Start-Sleep -Seconds 3
                exit
            }#try/catch

            Write-Output "Please enter the username and password credentials for the $ForestName domain. (Example: CORP\Administrator)"
            $DomainCredentials = Get-Credential

            Write-Output 'Please enter the $ForestName Directory Services Restore Mode (DSRM) password.'
            $Password = Read-Host 'DSRM Password' -AsSecureString
        
                    
            $ForestArguments = @{ 
        
                # Domain name
                DomainName                    = $ForestName

                # Domain credentials
                Credentials                   = $DomainCredentials
        
                # Directory Services Restore Mode Password (DSRM).
                SafeModeAdministratorPassword = $Password
                    
                # Specify the forest and domain functional level.
                ForestMode                    = 7 # Windows Server 2016
                DomainMode                    = 7 # Windows Server 2016

                # Install DNS server.
                InstallDns                    = $true
        
                # Specify the location name for each of these.
                DatabasePath                  = "$ENV:WINDIR\NTDS"
                LogPath                       = "$ENV:WINDIR\NTDS"
                SysVolPath                    = "$ENV:WINDIR\SYSVOL"
        
            } #$ForestArguments
            
            Write-Verbose -Message "[PROCESS] Performing an ADDS DC Check."
            Test-ADDSDomainController @ForestArguments
        
            Install-ADDSDomainController @ForestArguments
                
        } #if ($NCRDomainResponse -eq 0)
    } #PROCESS

    END {
        if ($NCRDomainResponse -ne 0) {
            Write-Warning "Operation cancelled on $env:COMPUTERNAME."
            Start-Sleep -Seconds 1
            exit
        }
        else {
            Write-Output 'The operation was successful'
        } #if/else ($NCRDomainResponse -ne 0)
    } #END
} #function Deploy-NCRDomainController

Deploy-NCRDomainController
