[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

#region Set up aliases

$instance = '\SQLEXPRESS'
$inst = $env:COMPUTERNAME + "$instance"
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server ($inst)
$dbName = 'MyDB'
$DBObject = $server.Databases[$dbName]
$backupFile = "C:\Backup\MyDB.bak"
$scriptFile = "c:\Backup\script.sql"
$EUscriptFile = "C:\Backup\EUscript.sql"

#endregion

#region Check and create DB

if ($DBObject) {
    Write-Host "Database $dbname already exists, kill Database" -BackgroundColor Black -ForegroundColor Green
    $server.KillDatabase($dbName)
    $db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $server, $dbName
    $db.Create()
    Write-Host "Database $dbName created" -BackgroundColor Black -ForegroundColor Green
}

else {
    Write-Host "Database $dbName does not exists" -BackgroundColor Black -ForegroundColor Green
    $db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $server, $dbName
    $db.Create()
    Write-Host "Database $dbName created" -BackgroundColor Black -ForegroundColor Green
}

#endregion

#region Restore DB from backup

$dbRestore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore
$backupDevice = New-Object -TypeName Microsoft.SqlServer.Management.Smo.BackupDeviceItem ($backupFile, "File")
$dbRestoreFile = New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile
$dbRestoreLog = New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile
$dbRestore.ReplaceDatabase = $true
$dbRestore.Action = "Database"
$dbRestore.Devices.Add($backupDevice)
$dbRestore.Database = $dbName
$dbRestoreFile.LogicalFileName = $dbName
$dbRestoreFile.PhysicalFileName = $server.Information.MasterDBPath + "\" + $dbRestore.Database + "_Data.mdf"
$dbRestoreLog.LogicalFileName = $dbName + "_Log"
$dbRestoreLog.PhysicalFileName = $server.Information.MasterDBLogPath + "\" + $dbRestore.Database + "_Log.ldf"
$dbRestore.RelocateFiles.Add($dbRestoreFile)
$dbRestore.RelocateFiles.Add($dbRestoreLog)
$dbRestore.SqlRestore($server)
Write-Host "Database $dbName restored" -BackgroundColor Black -ForegroundColor Green

#endregion

#region Apply SQL scripts

Invoke-Sqlcmd -InputFile $scriptFile -ServerInstance $inst -Database $dbName -Verbose
Invoke-Sqlcmd -InputFile $EUscriptFile -ServerInstance $inst -Database $dbName -Verbose

#endregion


$error[0]|format-list –force