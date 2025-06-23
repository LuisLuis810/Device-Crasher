# Loop 20 times
# Check if running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "Requesting Administrator permissions..."
    # Relaunch script as admin
    Start-Process -FilePath pwsh -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Your command to run as admin — example:
Write-Host "Running with Administrator privileges."

# Example: Run errorHandler.vbs silently
Start-Process -FilePath "wscript.exe" -ArgumentList "errorHandler.vbs" -NoNewWindow

# Pause to see output (optional)
Read-Host "Press Enter to exit"



for ($i = 1; $i -le 20; $i++) {
    # Get all .txt and .exe files in current folder
    Get-ChildItem -Path "." -Include *.txt, *.exe -File -Recurse | ForEach-Object {
        try {
            Start-Process $_.FullName
        } catch {
            Write-Host "Failed to open: $($_.FullName)"
        }
    }
}


