# импортируем модуль ActiveDirectory
Import-Module ActiveDirectory
#определяем массивы
$servers_dontneedreboot=@()
$servers_notavail=@()
$servers_rebooted=@()
$servers_witherror=@()
$From = "mail"
$SMTPServer = "ip"
$SMTPPort = "25"


$need=@()


# найти все серверы
$servers = Get-ADComputer -Filter {OperatingSystem -Like "*Server*"} -Property *
#$servers = Get-ADComputer -Filter 'name -like "*RODC*"'
# перебираем все что нашли
$servers | foreach {
#проверяем доступность
$ping_res =Test-Connection -Cn $_.name -BufferSize 16 -Count 1 -ea 0 -quiet
#если доступен
 if ($ping_res) {

  $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_.name)
  $RegSubKey = $Reg.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\")
  $RegSubKey2 = $reg.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")

    if ($RegSubKey)  {
    $RegValue = $RegSubKey.GetValue("PendingFileRenameOperations",$null)
    # проверяем необходимость перезагрузки
      if (($RegValue) -or ($RegSubKey2)) {
      # нужна
      $need += $_.name
      if( $_.name -notlike "*ksc*"){
       Restart-Computer -computername $_.name -force
       }
      if ($_.name -like "*DC*"){
      Start-Sleep -s 600
      }
      
      } else {
      # не нужна
      $servers_dontneedreboot += $_.name
      } 

    } 
  $RegValue = $null
  # закрываем соединение
  $Reg.Close()
  } else {
  $servers_notavail += $_.name
  }
}

      # ждем
     Start-Sleep -s 600

$need | foreach {

      #  проверяем еще раз необходимость перезагрузки и доступность сервера

      $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_.name)
      $RegValue = $RegSubKey.GetValue("PendingFileRenameOperations",$null)
      $RegSubKey2 = $reg.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired")
      $RegSubKey = $Reg.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\")
      $ping_res = Test-Connection -Cn $_.name -BufferSize 16 -Count 1 -ea 0 -quiet

        if (($RegValue) -or (!($ping_res) -or ($regsubkey2)))  {
        #после перезагрузки, все равно требуется перезагрузка, или сервер не доступен - значит что-то не так.
        $servers_witherror += $_.name
        } else {
        $servers_rebooted += $_.name
        }


}

#Write-host "servers reboted"
#$servers_rebooted
#Write-Host "servers not need to reboot"
#$servers_dontneedreboot
#Write-host "servers not availible"
#$servers_notavail
#Write-host "servers with error"
#$servers_witherror
#Write-host "need to reboot"
#$need
#Write-host "all selected servers"
#$serves
Send-MailMessage -From $From -to 'mail' -Subject "$(Get-Date -format 'u') Servers with error during process" -Body($servers_witherror | ft | Out-String) -SmtpServer $SMTPServer -port $SMTPPort 
Send-MailMessage -From $From -to 'mail' -Subject "$(Get-Date -format 'u') Unavailable servers" -Body($servers_notavail | ft | Out-String) -SmtpServer $SMTPServer -port $SMTPPort 
Send-MailMessage -From $From -to 'mail' -Subject "$(Get-Date -format 'u') Rebooted servers" -Body($servers_rebooted | ft | Out-String) -SmtpServer $SMTPServer -port $SMTPPort 
Send-MailMessage -From $From -to 'mail' -Subject "$(Get-Date -format 'u') Servers that do not require a reboot" -Body($servers_dontneedreboot | ft | Out-String) -SmtpServer $SMTPServer
Send-MailMessage -From $From -to 'mail' -Subject "$(Get-Date -format 'u') Servers with error during process" -Body($servers_witherror | ft | Out-String) -SmtpServer $SMTPServer 
Send-MailMessage -From $From -to 'mail' -Subject "$(Get-Date -format 'u') Unavailable servers" -Body($servers_notavail | ft | Out-String) -SmtpServer $SMTPServer 
Send-MailMessage -From $From -to 'mail' -Subject "$(Get-Date -format 'u') Rebooted servers" -Body($servers_rebooted | ft | Out-String) -SmtpServer $SMTPServer 
