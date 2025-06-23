# Loop 20 times
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


