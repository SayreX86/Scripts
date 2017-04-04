#$BackupFolderPath = "C:\Temp"
#$DatabaseBackupShareName = "ShareName" 

$BackupFolderPath = '#{BackupFolderPath}'
$DatabaseBackupShareName = '#{DatabaseBackupShareName}' 

if (!(Test-Path $BackupFolderPath)) {
    New-Item $BackupFolderPath -ItemType Directory -Force -Verbose
}

if (!(Get-SmbShare $DatabaseBackupShareName)) {
New-SmbShare -Name $DatabaseBackupShareName -Path $BackupFolderPath `
                                            -ConcurrentUserLimit "10" `
                                            -FullAccess 'NT AUTHORITY\SYSTEM' `
                                            -ChangeAccess 'BUILTIN\Administrators' `
                                            -ReadAccess 'NT AUTHORITY\Authenticated Users' `
                                            -NoAccess 'BUILTIN\Guests' `
                                            -Description 'Created by Octopus step'
}

else {
$permissions = @{
     'NT AUTHORITY\SYSTEM' = 'Full';
     'BUILTIN\Administrators' = 'Change';
     'NT AUTHORITY\Authenticated Users' = 'Read';
     }
$permissions.GetEnumerator() | ForEach-Object {
    Grant-SmbShareAccess -Name $DatabaseBackupShareName -AccountName $_.Key -AccessRight $_.Value -Force -Verbose
    }
}