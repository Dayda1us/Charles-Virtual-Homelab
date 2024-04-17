<#

    .DESCRIPTION
        A script that allows the user to remove app packages that will not be used by the user.
    
    .NOTES
        Not all packages can be removed as some are essential to the operating system. Below are a list of packages that can be removed without
        affecting the operating system.

        This script requires elevated privileges and execution policy set to "Bypass"

#>
#Requires -RunAsAdministrator
#Requires -Version 5.1

#################################################
#           Editable Variables Begin            #
#################################################
# You only have to edit this part of the script #
#################################################

<#

Below are a list of preinstalled packages that Microsoft installed on the operating system. 
If you wish to exclude any of these apps from being removed, simply add a hashtag (#) on the string.

Example:

$win10Packages = @(
    #"Microsoft.549981C3F5F10"                       # Cortana
    "Microsoft.BingWeather"                         # Microsoft Bing Weather
    "Microsoft.BingFinance"                         # Microsoft Bing Finance
!! omitted for brevity !!
)

#>

# List of Windows 10 preinstalled packages.
$win10Packages = @(                                   
    "Microsoft.549981C3F5F10"                       # Cortana
    "Microsoft.BingWeather"                         # Microsoft Bing Weather
    "Microsoft.BingFinance"                         # Microsoft Bing Finance
    "Microsoft.BingNews"                            # Microsoft Bing News
    "Microsoft.BingSports"                          # Microsoft Bing Sports
    "Microsoft.GetHelp"                             # Microsoft Help
    "Microsoft.Getstarted"                          # Microsoft Get Started
    "Microsoft.WindowsFeedbackHub"                  # Microsoft Windows Feedback Hub
    "Microsoft.windowscommunicationsapps"           # Microsoft Mail and Calendar
    "Microsoft.MicrosoftOfficeHub"                  # Microsoft Office
    "Microsoft.MicrosoftEDViewer"                   # Microsoft ED Viewer (Word Viewer)
    "Microsoft.MicrosoftStickyNotes"                # Microsoft Sticky Notes
    "Microsoft.Office.OneNote"                      # Microsoft OneNote
    "Microsoft.SkypeApp"                            # Microsoft Skype
    "Microsoft.People"                              # Microsoft People
    "Microsoft.WindowsAlarms"                       # Microsoft Windows Alarms
    "Microsoft.WindowsCalculator"                   # Microsoft Windows Calculator
    "Microsoft.WindowsMaps"                         # Microsoft Windows Maps
    "Microsoft.Windows.Photos"                      # Microsoft Windows Photos
    "Microsoft.WindowsCamera"                       # Microsoft Windows Camera
    "Microsoft.WindowsSoundRecorder"                # Microsoft Windows Sound Recorder
    "Microsoft.YourPhone"                           # Microsoft Your Phone
    "Microsoft.Microsoft3DViewer"                   # Microsoft 3D Viewer (VR)
    "Microsoft.MixedReality.Portal"                 # Microsoft Mixed Reality Portal (VR)
    "Microsoft.StorePurchaseApp"                    # Microsoft Store Purchase App
    "Microsoft.Wallet"                              # Microsoft Wallet
    "Microsoft.WebMediaExtensions"                  # Open source formats on the web
    "Microsoft.VP9VideoExtensions"                  # VP9 video codec for internet streaming
    "Microsoft.WebpImageExtension"                  # WebP image viewing
    "Microsoft.HEIFImageExtension"                  # High Efficiency Image File (HEIF) format
    "Microsoft.XboxApp"                             # Microsoft Xbox
    "Microsoft.XboxGameOverlay"                     # Microsoft Xbox
    "Microsoft.XboxGamingOverlay"                   # Microsoft Xbox
    "Microsoft.XboxIdentityProvider"                # Microsoft Xbox
    "Microsoft.XboxSpeechToTextOverlay"             # Microsoft Xbox
    "Microsoft.Xbox.TCUI"                           # Microsoft Xbox
    "Microsoft.MicrosoftSolitaireCollection"        # Microsoft Solitare
    "Microsoft.ZuneMusic"                           # Microsoft Zune Music
    "Microsoft.ZuneVideo"                           # Microsoft Zune Video
    "SpotifyAB.SpotifyMusic"                        # Spotify
    "Disney.37853FC22B2CE"                          # Disney+
    "Microsoft.Screensketch"                        # Testing removal Microsoft Screen Sketch (Snipping Tool)
)

# List of Windows 11 preinstalled packages.
$win11Packages = @(                                  
    "Microsoft.GamingApp"                           # Microsoft GamingApp
    "Microsoft.PowerAutomateDesktop"                # Microsoft Power Automate Desktop
    "Microsoft.Todos"                               # Microsoft To Do
    "MicrosoftTeams"                                # Microsoft Teams
    "Microsoft.OneDriveSync"                        # Microsoft OneDrive Sync
    "Microsoft.Windows.Ai.Copilot.Provider"         # Microsoft Copilot
    "Microsoft.Windows.DevHome"                     # Microsoft DevHome
    "Microsoft.Windows.DevHomeGitHubExtension"      # Microsoft DevHome GitHub Extension
    "Clipchamp.Clipchamp"                           # Clip Champ
)

## OPTIONAL PACKAGES ##

# Remove Microsoft Edge. (Default is 0).
$removeEdge = 0

# Remove Windows Store (Default is 0).
$removeWindowsStore = 0

# Remove Microsoft Paint [Formerly MS Paint] (Default is 0).
$removeMSPaint = 0

###############################################
#          Editable Variables End             #
###############################################

######################################################################################
# No edits should take place beyond this comment unless you know what you're doing!  #
# All changes should be made in the Variables section.                               #
######################################################################################

# Retrieve the build number of the operating system.
$buildNumber = [System.Environment]::OSVersion.Version.Build

# If running Windows 10, run this command.
if ($buildNumber -lt 22000) {
    foreach ($AppPackage in $win10Packages) {
        Write-Warning "Removing $AppPackage"
        if (-not(Get-AppxPackage -name $AppPackage -EA SilentlyContinue)) {
            Write-Warning "$AppPackage not found."
        } #end if
        else {
            try {
                Get-AppxPackage -Name $AppPackage | Remove-AppxPackage
                Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $AppPackage } | Remove-AppxProvisionedPackage -Online
            } #end try
            catch {
                Write-Warning "Could not remove $AppPackage."
            } #end catch
        } #end else
    } #end foreach
} #end if

# If running Windows 11 or later, run this this command.
if ($buildNumber -ge 22000) {
    foreach ($AppPackage in $win10Packages) {
        if (-not(Get-AppxPackage -name $AppPackage -EA SilentlyContinue)) {
            Write-Warning "$AppPackage not found."
        } #end if
        else {
            Write-Warning "Removing $AppPackage"
            try {
                Get-AppxPackage -Name $AppPackage | Remove-AppxPackage
                Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $AppPackage } | Remove-AppxProvisionedPackage -Online
            } #end try
            catch {
                Write-Warning "Could not remove $AppPackage."
            } #end catch
        } #end else
    } #end foreach

    foreach ($AppPackage in $win11Packages) {
        if (-not(Get-AppxPackage -name $AppPackage -EA SilentlyContinue)) {
            Write-Warning "$AppPackage not found."
        } #end if
        else {
            Write-Warning "Removing $AppPackage"
            try {
                Get-AppxPackage -Name $AppPackage | Remove-AppxPackage
                Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $AppPackage } | Remove-AppxProvisionedPackage -Online
            } #end try
            catch {
                Write-Warning "Could not remove $AppPackage."
            } #end catch
        } #end else
    } #end foreach
} #end if

#############################
#       OPTIONAL PKGS.      #
#############################

if ($removeEdge -eq 1) {
    if (-not(Get-AppxPackage -name "Microsoft.MicrosoftEdge.Stable" -EA SilentlyContinue)) {
        Write-Warning "Microsoft Edge not found"
    } #end if
    else {
        Write-Warning "Removing Microsoft Edge"
        Get-AppxPackage -Name "Microsoft.MicrosoftEdge.Stable" | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq "Microsoft.MicrosoftEdge.Stable" } | Remove-AppxPackage -Online
    } #end else
} #end if

if ($removeWindowsStore -eq 1) {
    if (-not(Get-AppxPackage -name "Microsoft.Store" -EA SilentlyContinue)) {
        Write-Warning "Microsoft Store not found"
    } #end if
    else {
        Write-Warning "Removing Microsoft Store"
        Get-AppxPackage -Name "Microsoft.Store" | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq "Microsoft.Store" } | Remove-AppxPackage -Online
    } #end else
} #end if

if (($removeMSPaint -eq 1) -and ($buildNumber -ge 22000)) {
    if (-not(Get-AppxPackage -name "Microsoft.Paint" -EA SilentlyContinue)) {
        Write-Warning "Microsoft Paint not found"
    } #end if
    else {
        Write-Warning "Removing Microsoft Paint"
        Get-AppxPackage -Name "Microsoft.Paint" | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq "Microsoft.Paint" } | Remove-AppxPackage -Online
    } #end else
} #end if
elseif (($removeMSPaint -eq 1) -and ($buildNumber -lt 22000)) {
    if (-not(Get-AppxPackage -name "Microsoft.MSPaint" -EA SilentlyContinue)) {
        Write-Warning "Microsoft Paint not found"
    } #end if
    else {
        Write-Warning "Removing Microsoft Paint"
        Get-AppxPackage -Name "Microsoft.MSPaint" | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq "Microsoft.MSPaint" } | Remove-AppxPackage -Online
    } #end else
} #end elseif