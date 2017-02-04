<#
Will add parameters to values: vmname, switchname, vhdpath etc.
Will add netadapter connection check and choose.
Will add choose if it needs VMSwitch.
Need to create basic VHD, then add it to VM and start.
#>

#Variables
#VM
$vmname = "WIN-SRV-01" #Here is the Virtual Machine Name
$vmmemory = 2GB
#Net
$netadapter = Get-NetAdapter -Physical | Where-Object -Property Status -EQ Up | Select-Object -Property Name
$netadaptername = $netadapter.Name #Here is the Network Adapter Name
$switch = "VMSwitch" #Here is the VSwitch Name
#VHD
$iso = "" #Path to ISO with OS
$autounattend = "" #Path to autounattend file
$vhdpath = "D:\VM\VHD-$vmname\$vmname.vhdx" #VHD Path
$vhdsize = 3Mb #Start vhd size

#Create a new VM Switch if it needs
$checkswitch = Get-VMSwitch
if ($checkswitch -notmatch $switch) {New-VMSwitch -Name $switch -AllowManagementOS $True -NetAdapterName $netadaptername}

#Create a new VM
New-VM -Name $vmname -MemoryStartupBytes $vmmemory -BootDevice CD -Generation 2 -NewVHDPath $vhdpath -NewVHDSizeBytes $vhdsize

#Configure new VM
Set-VM -Name $vmname -ProcessorCount 2
Connect-VMNetworkAdapter -SwitchName $switch -VMName $vmname
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $vmname

#Start-VM $vmname