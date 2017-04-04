$BackupFolderPath = '#{BackupFolderPath}'
$DatabaseBackupShareName = '#{DatabaseBackupShareName}'

if ([String]::IsNullOrWhiteSpace($SQLServerAccount))
{
    Write-Error "The 'SQLServerAccount' variable is not set. The script will not proceed."
    exit
}

#Create Folder and set write permissions to SQL Server account
if (!(Test-Path $BackupFolderPath)) {
    Write-Host "Creating new directory $BackupFolderPath ..."
    New-Item $BackupFolderPath -ItemType Directory -Force -Verbose
}

$acl = Get-Acl $BackupFolderPath
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($SQLServerAccount,"Write, Read", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl $BackupFolderPath $acl

#Create SMB Share and set permissions
if (!(Get-SmbShare $DatabaseBackupShareName -ErrorAction SilentlyContinue)) {
New-SmbShare -Name $DatabaseBackupShareName -Path $BackupFolderPath `
                                            -ConcurrentUserLimit "10" `
                                            -FullAccess 'NT AUTHORITY\SYSTEM' `
                                            -ChangeAccess 'BUILTIN\Administrators' `
                                            -ReadAccess 'NT AUTHORITY\Authenticated Users' `
                                            -NoAccess 'BUILTIN\Guests' `
                                            -Description 'Created by Octopus step'
Write-Host "New SMB share $DatabaseBackupShareName created."
}

else {
Write-Host "SMB share $DatabaseBackupShareName already exists."
$permissions = @{
     'NT AUTHORITY\SYSTEM' = 'Full';
     'BUILTIN\Administrators' = 'Change';
     'NT AUTHORITY\Authenticated Users' = 'Read';
     }

$permissions.GetEnumerator() | ForEach-Object {
    Grant-SmbShareAccess -Name $DatabaseBackupShareName -AccountName $_.Key -AccessRight $_.Value -Force -Verbose
    }
}