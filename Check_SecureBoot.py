import winreg
from win32com.client import GetObject
import sys

def check_secure_boot():
    try:
        # Check if system uses UEFI firmware
        wmi = GetObject("winmgmts:")
        system = wmi.InstancesOf("Win32_ComputerSystem")[0]
        uefi_enabled = system.Properties_("PCSystemType").Value == 2
        
        if not uefi_enabled:
            print("This system uses Legacy BIOS, so Secure Boot is not applicable.")
            return

        # Check Secure Boot status via registry
        sb_key_path = r"SYSTEM\CurrentControlSet\Control\SecureBoot\State"
        try:
            key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, sb_key_path, 0, winreg.KEY_READ)
            secure_boot_value, _ = winreg.QueryValueEx(key, "SecureBootEnabled")
            winreg.CloseKey(key)
            
            if secure_boot_value == 1:
                print("Secure Boot is enabled.")
            else:
                print("Secure Boot is disabled.")
                
        except FileNotFoundError:
            print("Secure Boot information could not be retrieved. The system may not support it or the key is missing.")
        except PermissionError:
            print("Permission denied accessing registry. Run the script as Administrator.")
            
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        
if __name__ == "__main__":
    check_secure_boot()