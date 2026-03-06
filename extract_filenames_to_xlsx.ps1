# Generates an Excel report by:
# 1) Listing all files inside folders named in $excludeFolders (recursive)
# 2) Listing other first-level folders plus their second-level subfolders as [FOLDER] rows
# 3) Sorting results, converting byte sizes to human-readable text, and exporting to XLSX
# Set encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Define output file
$excelFile = "FoldersDirectoryList.xlsx"

# Check if ImportExcel module is installed, if not install it
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Install-Module -Name ImportExcel -Force -Scope CurrentUser
}

# Import the module
Import-Module ImportExcel

# Delete existing XLSX file
if (Test-Path $excelFile) {
    Remove-Item $excelFile
}

# Folders to treat as "file-extraction" targets.
# Add more folder names here, for example:
# $excludeFolders = @("monitor", "webservers", "logs", "archive")
# Any folder in this list is scanned recursively for files.
# Folders not in this list are handled later as directory-only entries.
$excludeFolders = @("monitor", "webservers")
$rows = @()

# For each folder in $excludeFolders:
# - Recursively collect files
# - Store last modified date, parent folder, file name, and raw byte size
foreach ($folder in $excludeFolders) {
    if (Test-Path $folder) {
        Get-ChildItem -Path $folder -Recurse -File | ForEach-Object {
            $rows += [PSCustomObject]@{
                ModifiedDateTime = $_.LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
                Folder = $_.DirectoryName
                File = $_.Name
                Size = $_.Length
            }
        }
    }
}

# For first-level directories NOT in $excludeFolders:
# - Add the first-level directory itself as a [FOLDER] row
# - Add each second-level subdirectory as a [FOLDER] row
Get-ChildItem -Path . -Directory | Where-Object { $_.Name -notin $excludeFolders } | ForEach-Object {
    $firstLevelDir = $_
    $rows += [PSCustomObject]@{
        ModifiedDateTime = $firstLevelDir.LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
        Folder = $firstLevelDir.FullName
        File = "[FOLDER]"
        Size = 0
    }
    
    # Also list second-level subdirectories
    Get-ChildItem -Path $firstLevelDir.FullName -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $rows += [PSCustomObject]@{
            ModifiedDateTime = $_.LastWriteTime.ToString("MM/dd/yyyy HH:mm:ss")
            Folder = $_.FullName
            File = "[FOLDER]"
            Size = 0
        }
    }
}

# Sort all collected rows to keep output organized
$sorted = $rows | Sort-Object -Property Folder, ModifiedDateTime

# Convert byte sizes into B/KB/MB/GB display values for the Excel output
$exportData = @()
foreach ($row in $sorted) {
    $size = $row.Size
    if ($size -ge 1GB) {
        $humanSize = "{0:N2} GB" -f ($size / 1GB)
    } elseif ($size -ge 1MB) {
        $humanSize = "{0:N2} MB" -f ($size / 1MB)
    } elseif ($size -ge 1KB) {
        $humanSize = "{0:N2} KB" -f ($size / 1KB)
    } else {
        $humanSize = "$size B"
    }
    
    $exportData += [PSCustomObject]@{
        ModifiedDateTime = $row.ModifiedDateTime
        Folder = $row.Folder
        File = $row.File
        Size = $humanSize
    }
}

# Write the final table to Excel (auto-size columns and freeze header row)
$exportData | Export-Excel -Path $excelFile -WorksheetName "Files" -AutoSize -FreezeTopRow

Write-Host "Done. Files extracted and sorted to $excelFile"
