# Импортируем модуль Active Directory
import-module ActiveDirectory
# Указываем в каком подразделении проверять пользователей
$MSK = "OU="
$OFS = "<br>"
$ASF = "OU="
$KRR = "OU="
$TVR = "OU="
$PZZ = "OU="
$HMA = "OU="
$PASF = echo Пользователи Астрахани: $OFS
$PMSK = echo Пользователи Москвы: $OFS
$PKRR = echo Пользователи Краснодара: $OFS
$PPZZ = echo Пользователи Пензы: $OFS
$PHMA = echo Пользователи Ханты-Мансийска: $OFS
$PTVR = echo Пользователи Твери: $OFS
# Указываем какие свойства должны быть заполнены
$properties = "cn","Surname" ,"DisplayName", "physicalDeliveryOfficeName" ,"telephoneNumber", "EmailAddress","StreetAddress" ,"l", "c","mobile" , "title" ,"Department", "Company"
# Начинаем проверку и формируем тело письма
$MSKu = Get-ADUser -Filter * -SearchBase $MSK  -Properties $properties | Foreach {
$user = $_
if($miss = $properties | Where { !$user. "$_" }) {
"{0} - {1}" -f ( $miss -join ",") ,$user. name + $OFS
}
else {
# Если раскомментировать эту строку, по в список будут попадать пользователи с заполненными полями
#"verify - {0}" -f $user.name
}
} | Sort |   Out-String
$ASFu = Get-ADUser -Filter * -SearchBase $ASF  -Properties $properties |  Foreach {
$user = $_
if($miss = $properties | Where { !$user. "$_" }) {
"{0} - {1}" -f ( $miss -join ",") ,$user. name + $OFS
}
else {
# Если раскомментировать эту строку, по в список будут попадать пользователи с заполненными полями
#"verify - {0}" -f $user.name
}
} | Sort |   Out-String
$KRRu = Get-ADUser -Filter * -SearchBase $KRR  -Properties $properties |  Foreach {
$user = $_
if($miss = $properties | Where { !$user. "$_" }) {
"{0} - {1}" -f ( $miss -join ",") ,$user. name + $OFS
}
else {
# Если раскомментировать эту строку, по в список будут попадать пользователи с заполненными полями
#"verify - {0}" -f $user.name
}
} | Sort |   Out-String
$PZZu = Get-ADUser -Filter * -SearchBase $PZZ  -Properties $properties |  Foreach {
$user = $_
if($miss = $properties | Where { !$user. "$_" }) {
"{0} - {1}" -f ( $miss -join ",") ,$user. name + $OFS
}
else {
# Если раскомментировать эту строку, по в список будут попадать пользователи с заполненными полями
#"verify - {0}" -f $user.name
}
} | Sort |   Out-String
$TVRu = Get-ADUser -Filter * -SearchBase $TVR  -Properties $properties |  Foreach {
$user = $_
if($miss = $properties | Where { !$user. "$_" }) {
"{0} - {1}" -f ( $miss -join ",") ,$user. name + $OFS
}
else {
# Если раскомментировать эту строку, по в список будут попадать пользователи с заполненными полями
#"verify - {0}" -f $user.name
}
} | Sort |   Out-String
$HMAu = Get-ADUser -Filter * -SearchBase $HMA  -Properties $properties |  Foreach {
$user = $_
if($miss = $properties | Where { !$user. "$_" }) {
"{0} - {1}" -f ( $miss -join ",") ,$user. name + $OFS
}
else {
# Если раскомментировать эту строку, по в список будут попадать пользователи с заполненными полями
#"verify - {0}" -f $user.name
}
} | Sort |   Out-String

$BODY = "
<b>$PMSK</b> $MSKu <br>
<b>$PASF</b> $ASFu<br>
<b>$PKRR</b> $KRRu<br>
<b>$PPZZ</b> $PZZu<br>
<b>$PTVR</b> $TVRu<br>
<b>$PHMA</b> $HMAu"
 
# Отправляем сообщения
#Send-MailMessage -From admin-notification@domain.local -To admin@domain.local -Encoding ([System.Text.Encoding]::UTF8) -Subject "Аудит незаполненных полей в Active Directory " -Body $body2$body3$Body -SmtpServer YourMailServer.domain.local
#$secpasswd = ConvertTo-SecureString “Maks2012” -AsPlainText -Force
#$mycreds = New-Object System.Management.Automation.PSCredential (“mail”, $secpasswd)
Send-MailMessage -From "mail" -To "mail" -Encoding ([System.Text.Encoding]:: UTF8) -SmtpServer "IP"  -Subject "Аудит незаполненных полей в Active Directory " -Body $BODY -BodyAsHtml