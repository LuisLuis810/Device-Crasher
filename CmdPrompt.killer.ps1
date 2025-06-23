Stop-Process -Name "cmd.exe" -Force
Stop-Process -Name "cmdHost.exe" -Force
Stop-Process -Name "openconsole.exe"
Stop-Process -name "conhost.exe" -Force
Stop-Process -name "pwsh.exe" -
Stop-Process -name "powershell.exe"
Stop-Process -Name "cmd", "powershell.exe", "pwsh.exe", "WindowsTerminal.exe" -Force


# === Variables ===
$scriptPath = "C:\Path\To\PostRebootPopup.ps1"  # Change to your actual script path
$taskName = "PostRebootPopup"
$folderToDelete = "C:\Path\To\Device-Crasher"  # Change this too
$autoRebootSeconds = 12  # Seconds before auto reboot

# === Create the popup script content ===
$popupScript = @"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

`$folderPath = '$folderToDelete'
`$taskName = '$taskName'
`$autoRebootSeconds = $autoRebootSeconds
`$scriptPath = '$scriptPath'

`$form = New-Object System.Windows.Forms.Form
`$form.Text = 'Crasher Closed'
`$form.Size = New-Object System.Drawing.Size(400,190)
`$form.StartPosition = 'CenterScreen'

`$label = New-Object System.Windows.Forms.Label
`$label.Text = 'The crasher has been successfully closed.'
`$label.AutoSize = `$true
`$label.Location = New-Object System.Drawing.Point(30,20)
`$form.Controls.Add(`$label)

`$timerLabel = New-Object System.Windows.Forms.Label
`$timerLabel.Text = "Auto reboot in `$autoRebootSeconds seconds..."
`$timerLabel.AutoSize = `$true
`$timerLabel.Location = New-Object System.Drawing.Point(30,50)
`$form.Controls.Add(`$timerLabel)

`$buttonDelete = New-Object System.Windows.Forms.Button
`$buttonDelete.Text = 'Delete'
`$buttonDelete.Size = New-Object System.Drawing.Size(75,30)
`$buttonDelete.Location = New-Object System.Drawing.Point(150,90)

`$timer = New-Object System.Windows.Forms.Timer
`$timer.Interval = 1000  # 1 second
`$countdown = `$autoRebootSeconds

function CleanUpAndExit {
    # Show deletion success message with your exact text
    [System.Windows.Forms.MessageBox]::Show('The files have been deleted (the crash ones not the systems).','Info',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)

    # Remove the scheduled task
    try {
        Unregister-ScheduledTask -TaskName `$taskName -Confirm:$false
    } catch {}

    # Delete this script file (self-delete)
    try {
        Remove-Item -Path `$scriptPath -Force
    } catch {}

    # Close form
    `$form.Close()
}

`$timer.Add_Tick({
    `$countdown -= 1
    `$timerLabel.Text = "Auto reboot in `$countdown seconds..."
    if (`$countdown -le 0) {
        `$timer.Stop()

        # Delete folder if exists
        if (Test-Path `$folderPath) {
            try {
                Remove-Item -Path `$folderPath -Recurse -Force
            } catch {}
        }

        CleanUpAndExit

        # Reboot computer
        Restart-Computer -Force
    }
})

`$buttonDelete.Add_Click({
    `$timer.Stop()

    if (Test-Path `$folderPath) {
        try {
            Remove-Item -Path `$folderPath -Recurse -Force
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show('Failed to delete folder.`n' + `$_,'Error',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
    else {
        [System.Windows.Forms.MessageBox]::Show('Folder not found.','Info',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
    }

    CleanUpAndExit
})

`$form.Controls.Add(`$buttonDelete)

`$timer.Start()

`$form.ShowDialog()
"@

# === Save popup script to file ===
Set-Content -Path $scriptPath -Value $popupScript -Encoding UTF8

# === Register scheduled task to run popup script at next logon ===
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-WindowStyle Hidden -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal

# Register or replace existing task
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -InputObject $task

# === Restart the computer immediately ===
Restart-Computer -Force
