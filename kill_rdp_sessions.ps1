# Title: Enforcing RDP Session Per User Limit: Auto-Logoff Excess Sessions
#
# This PowerShell script enforces a per-user session limit for Remote Desktop Protocol (RDP) connections on a local server. 
# It retrieves active RDP sessions using qwinsta, filters out disconnected/system sessions, and identifies users exceeding two active sessions. 
# When a user surpasses the allowed session limit, the script automatically logs off the most recent session to maintain compliance with session policies and optimize system resources.

# Get all active RDP sessions
$RdpSessions = qwinsta /server:localhost | ForEach-Object {
    $line = ($_ -replace '\s{2,}', ',') -split ','  # Normalize spaces and split into columns

    # Ensure we process only valid session entries
    if ($line.Count -ge 4 -and $line[1] -ne 'USERNAME' -and $line[2] -match '^\d+$') {
        [PSCustomObject]@{
            SessionName = $line[0]
            Username    = $line[1]
            SessionID   = [int]$line[2]  # Convert Session ID to an integer for sorting
            State       = $line[3]
        }
    }
}

# Filter only active RDP sessions (ignore disconnected/system sessions)
$ActiveSessions = $RdpSessions | Where-Object { $_.State -eq 'Active' -and $_.Username -ne $null }

# Group sessions by username and find those with more than 2 active sessions
$UsersOverLimit = $ActiveSessions | Group-Object Username | Where-Object { $_.Count -gt 2 }

foreach ($UserGroup in $UsersOverLimit) {
    $Username = $UserGroup.Name
    $Sessions = $UserGroup.Group | Sort-Object SessionID -Descending  # Sort by Session ID (newest first)

    # Log off the newest session (first in the sorted list)
    $SessionToLogOff = $Sessions[0]  # Newest session
    Write-Host "Logging off user $Username (Newest Session ID: $($SessionToLogOff.SessionID))"

    # Log off the session
    logoff $SessionToLogOff.SessionID /server:localhost
}

Write-Host "Script execution completed."
