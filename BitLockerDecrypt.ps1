<#
.SYNOPSIS
    Disables BitLocker and initiates decryption on all protected volumes.
    Designed for SCCM deployment - runs silently, exits immediately after
    decryption is initiated. Decryption continues in the background.
#>

$LogPath = "C:\ProgramData\BitLockerDecrypt.log"

function Write-Log {
    param([string]$Message)
    $Entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path $LogPath -Value $Entry
}

Write-Log "BitLocker decryption script started."
Write-Log "Running as: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"

$Volumes = Get-BitLockerVolume | Where-Object {
    $_.VolumeStatus -in @('FullyEncrypted', 'EncryptionInProgress', 'DecryptionPaused', 'EncryptionPaused')
}

if (-not $Volumes) {
    Write-Log "No BitLocker-encrypted volumes found. Exiting."
    exit 0
}

foreach ($Volume in $Volumes) {
    $Drive = $Volume.MountPoint
    Write-Log "Initiating decryption on $Drive | VolumeStatus: $($Volume.VolumeStatus)"

    try {
        Disable-BitLocker -MountPoint $Drive -ErrorAction Stop
        Write-Log "SUCCESS: Decryption initiated on $Drive."
    }
    catch {
        Write-Log "ERROR: Failed to initiate decryption on $Drive. $_"
    }
}

Write-Log "Script complete. Decryption running in background."
exit 0
