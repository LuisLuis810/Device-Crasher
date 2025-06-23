@echo off
$scriptPath = "C:\Path\To\LoopReboot5Times.ps1"
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $regPath -Name "LoopReboot5Times" -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""


Add-Type -AssemblyName System.Windows.Forms

# Path of this script file (assumes .ps1)
$scriptPath = $MyInvocation.MyCommand.Path

# Registry startup key path for current user
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName = "LoopReboot5Times"

function Remove-StartupEntry {
    if (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $regPath -Name $regName
        Write-Host "Startup entry removed from registry."
    }
}

# Show confirmation dialog
$result = [System.Windows.Forms.MessageBox]::Show(
    "Are you sure?",
    "Confirmation",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)

if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
    # Kill explorer.exe (desktop)
    Write-Host "Killing explorer.exe..."
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force

    Start-Sleep -Seconds 2

    # Loop to reboot 5 times
    for ($i = 1; $i -le 5; $i++) {
        Write-Host "Reboot attempt #$i"

        Restart-Computer -Force

        Start-Sleep -Seconds 10
    }

    # After loop, remove startup entry so it doesn’t run again
    Remove-StartupEntry
}
else {
    # User clicked No — remove startup and kill this script

    Remove-StartupEntry

    # Kill this script process
    Stop-Process -Id $PID -Force
}
