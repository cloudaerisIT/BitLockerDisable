# BitLocker Decryption Script

Disables BitLocker and initiates full volume decryption on all protected drives. Designed for silent deployment via SCCM or similar enterprise tooling. Decryption runs in the background after the script exits.

## Requirements

- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1+
- Must run as SYSTEM or a local administrator account
- BitLocker feature must be present (enabled by default on supported SKUs)

## Deployment (SCCM)

1. Add `BitLockerDecrypt.ps1` as a Script or Package in SCCM
2. Set the deployment program command line to:
  powershell.exe -ExecutionPolicy Bypass -NonInteractive -WindowStyle Hidden -File "BitLockerDecrypt.ps1"

3. Set the program to run as **SYSTEM**
4. Deploy to your target collection

## Behavior

- Scans all volumes for BitLocker encryption
- Calls `Disable-BitLocker` on each protected volume, which removes all key protectors and initiates decryption
- Exits immediately after decryption is initiated — the script does not wait for completion
- Decryption continues in the background and survives reboots
- If no encrypted volumes are found, the script exits cleanly with no action taken

## Logging

The script logs all activity to:
  C:\ProgramData\BitLockerDecrypt.log

Log entries include timestamp, volume mount point, volume status at time of execution, and success or error per volume.

## Checking Decryption Status

To check progress on a target machine, run the following in PowerShell:

```powershell
Get-BitLockerVolume | Select-Object MountPoint, VolumeStatus, EncryptionPercentage
```

Decryption is complete when `VolumeStatus` shows `FullyDecrypted` and `EncryptionPercentage` is `0`.

## Notes

- Decryption time varies depending on drive size and type. SSDs are significantly faster than HDDs.
- The volume remains fully accessible during decryption.
- If the machine reboots mid-decryption, Windows will automatically resume the process.
- This script initiates decryption only — it does not verify completion. Use a compliance baseline or follow-up discovery script if fleet-wide reporting is required.
