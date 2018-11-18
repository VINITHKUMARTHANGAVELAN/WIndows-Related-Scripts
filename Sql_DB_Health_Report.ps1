#***********************************************************************************************************************
#This script does the following:
#1.Gets list of servers from a file.
#2(a)If server is pingable,Executes the sql query.
##(b)If Sql connection error occurs,It is notified in the report for corresponding server.
##(C)Else list db info in that server is found.
#3.If server is not pingable,it is notified in the report. 
#Date of Creation: 6th Jan 2017 Vinith Kumar T 
#OS Type: Windows
#************************************************************************************************************************
$ErrorActionPreference = 'Silentlycontinue'
$var_Result=@();
$var_ServerName=@();
Write-Host "`nEnter the complete path of file containing server lists : "
$var_Path=Read-Host
$var_ServerName=Import-Csv "$var_Path"  #Database sever path details
foreach($Server in $var_ServerName.InstanceName)   #loop iterate
{
$var_Test=Test-Connection $Server -Quiet  #Checks for Server is pingable
if($var_Test -like "True")    #If Pingable
{
Write-Host "`n$Server is UP" -ForegroundColor GREEN -BackgroundColor Black
Add-PSSnapin SQLServerCmdletSnapin100     #Snapins for sql cmdlets
Add-PSSnapin SqlServerProviderSnapin100
$var_SqlOutputCons=(Invoke-Sqlcmd -Query "Exec sp_helpdb" -ServerInstance "$Server" -ErrorVariable var_Error -ErrorAction Ignore -SuppressProviderContextWarning) # execute sql query

if($var_Error.count -eq 0)   #If no db connection error occurs in server
{
#Gathers all db info in that server

foreach($sqloutput in $var_SqlOutputCons){
$var_Name=$sqloutput.name       
$var_DBsize=$sqloutput.db_size
$var_Owner=$sqloutput.owner
$var_DBid=$sqloutput.dbid
$var_Created=$sqloutput.created
$var_Stat=$sqloutput.status
$var_Compat=$sqloutput.compatibility_level
$var_Status=New-Object PSCustomObject -Property @{
                "SERVER"=$Server;
                "DB NAME"=$var_Name
                "DB SIZE"=$var_DBsize;
                "OWNER" =$var_Owner;
                "DBID" =$var_DBid;
                "CREATED"=$var_Created;
                "STATUS"=$var_Stat
                "COMPATIBILITY LEVEL"=$var_Compat
                } 
     $var_Result = $var_Result + $var_Status   #Stores the DB info in array
               
               }}else{
#If db connection error occurs
#List it as SQL connection error to user
Write-Host "SQL CONNECTION ERROR IN $Server" -ForegroundColor Red -BackgroundColor Black
$var_Name="SQL CONNECTION ERROR"
$var_DBsize="SQL CONNECTION ERROR"
$var_Owner="SQL CONNECTION ERROR"
$var_DBid="SQL CONNECTION ERROR"
$var_Created="SQL CONNECTION ERROR"
$var_Stat="SQL CONNECTION ERROR"
$var_Compat="SQL CONNECTION ERROR"

               $var_Status1=New-Object PSCustomObject -Property @{
                "SERVER"=$Server;
                "DB NAME"=$var_Name
                "DB SIZE"=$var_DBsize;
                "OWNER" =$var_Owner;
                "DBID" =$var_DBid;
                "CREATED"=$var_Created;
                "STATUS"=$var_Stat
                "COMPATIBILITY LEVEL"=$var_Compat
                }
$var_Result = $var_Result + $var_Status1
               
               }}else{
#If server not pingable
Write-Host "$Server is not Pingable" -ForegroundColor Red -BackgroundColor Black
$var_Name="SERVER CONNECTION ISSUE"
$var_DBsize="SERVER CONNECTION ISSUE"
$var_Owner="SERVER CONNECTION ISSUE"
$var_DBid="SERVER CONNECTION ISSUE"
$var_Created="SERVER CONNECTION ISSUE"
$var_Stat="SERVER CONNECTION ISSUE"
$var_Compat="SERVER CONNECTION ISSUE"

               $var_Status2=New-Object PSCustomObject -Property @{
                "SERVER"=$Server;
                "DB NAME"=$var_Name
                "DB SIZE"=$var_DBsize;
                "OWNER" =$var_Owner;
                "DBID" =$var_DBid;
                "CREATED"=$var_Created;
                "STATUS"=$var_Stat
                "COMPATIBILITY LEVEL"=$var_Compat
                } 
     $var_Result = $var_Result + $var_Status2
      
               }}
         $var_Result | select-object -Property "SERVER","DB NAME","DB SIZE","OWNER","DBID","CREATED","STATUS","COMPATIBILITY LEVEL" | Export-Csv "C:\Users\output.csv" -NoTypeInformation  #Outputs to excel format

Write-Host "`nEnter Your Mail Id : "
$var_Mail=Read-Host

Send-MailMessage -From "$var_Mail" -to "abc@gmail.com" -subject "INSTANCE AND DB AVAILABILITY" -attachment  "C:\Users\output.csv" -Body "INSTANCE AND DB AVAILABILITY"-SmtpServer email.abc.com #send mail

