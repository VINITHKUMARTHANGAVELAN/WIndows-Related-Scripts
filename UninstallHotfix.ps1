#***********************************************************************************************************************
#This script does the following:
#Gets Hotfix id to be uninstalled from user.
#Checks whether the hotfix id is available in all list of servers.
#If Hotfix id available it will uninstalls the patch from the server.
#Date of Creation: 6th OCT 2018 Vinith Kumar T 
#OS Type: Windows
#Execution: .\UninstallHotfix.ps1 -GetHotFixID ID
#************************************************************************************************************************
param(
        [Parameter(mandatory=$true)]
        [string] $GetHotFixID
)
try{
$ComputerName=Get-Content -path C:\Users\vt\Desktop\Servers.txt
if($ComputerName)
{
ForEach($Computer in $ComputerName)
{
$HotFixIDList=(Get-WmiObject Win32_QuickFixEngineering -ComputerName $Computer -ErrorAction Stop).HotFixID 

if($GetHotFixID -in $HotFixIDList)
{
$InstalledBy=(Get-Hotfix -id $GetHotFixID -ComputerName $Computer -ErrorAction Stop).InstalledBy
$InstalledOn=(Get-Hotfix -id $GetHotFixID -ComputerName $Computer -ErrorAction Stop).InstalledOn
Write-Host "$GetHotFixID is installed on $InstalledOn by $InstalledBy for Server $Computer"

$HotFixID = $GetHotfixID.Replace("KB","")
$UninstallString = "cmd.exe /c wusa.exe /uninstall /KB:$HotFixID /quiet /norestart"
    ([WMICLASS]"\\$Computer\ROOT\CIMV2:win32_process").Create($UninstallString) | out-null            

    while (@(Get-Process wusa -computername $Computer -ErrorAction SilentlyContinue).Count -ne 0) {
        Start-Sleep 3
        Write-Host "Waiting for update removal to finish ..."
    }
write-host "Completed the uninstallation of $GetHotFixID for Server $Computer"
}
else
{
Write-Host "$GetHotFixID is not installed"
}
}
}
else
{
Write-Host "Server List is Empty"
}

}
catch
{
$_.exception.message
 
}