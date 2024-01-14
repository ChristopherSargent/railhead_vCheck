#=========================================================================================================
# Start of Settings
#=========================================================================================================
$fldr2 = "C:\Users\chrisas\Documents\Scripts\Password\"
$Server = "snsuvim05.nsu.edu"
#=========================================================================================================
#  Get credentials for vsphere access:
#=========================================================================================================
$VC_User = "casargent@nsu.edu"
$encrypted = Get-Content "$fldr2$VC_User-PowershellCreds.txt" | ConvertTo-SecureString
#$User = "NSU\"+$VC_User
$User = $VC_User
$SA_Credential = New-Object System.Management.Automation.PsCredential ($User, $encrypted)
#=========================================================================================================
#  Connect to vCenter server:
#=========================================================================================================
Try{
$viconnect = Connect-VIServer $Server -Credential $SA_Credential
#=========================================================================================================
#  Get snapshots older than 1 year:
#=========================================================================================================
#Get-VM | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-365)} | Select-Object VM, Name, Created
#=========================================================================================================
#  Delete snapshots older than 1 year:
#=========================================================================================================
#Get-VM | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-1500)} | Remove-Snapshot -Confirm:$false
}
Catch{
    Write-Host "Failed Connecting to VSphere Server."
    Send-MailMessage -From "" -To "casargent" -Subject "Unable to Connect to VSphere to clean snapshots" -Body `
    "The powershell script is unable to connect to host your.vmware.server. Please investigate." -SmtpServer "204.155.176.182"
    Break
}

# Variables
$date = get-date -f MMddyyyy
$logpath = "C:\Users\chrisas\Documents\Scripts\Script_Logs"
 
# Verify the log folder exists.
If(!(Test-Path $logpath)){
    Write-Host "Log path not found, creating folder."
    New-Item $logpath -Type Directory
}
 
# Get all snapshots older than 24 hours, remove them.
If((get-snapshot -vm *) -ne $null){
#    $snapshotlist = get-snapshot -vm * | Where {$_.Created -lt (Get-Date).AddDays(-365)} | select VM, Name, SizeMB @{Name="Age";Expression={((Get-Date)-$_.Created).Days}}
    $snapshotlist = Get-VM | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-365)} | Select-Object VM, Name, Created
    Write-Host "Current Snapshots in NSU vSphere"
    Write-Output $snapshotlist
    Write-Output "Snapshots existing before cleanup" | Out-File $logpath\Snapshots_$date.txt -Append
    Write-Output $snapshotlist | Out-File $logpath\Snapshots_$date.txt -Append
}
# Send snapshot log to email.
$emailbody = (Get-Content $logpath\Snapshots_$date.txt | Out-String)
Send-MailMessage -From "casargent@nsu.edu" -To "casargent@nsu.edu, pcglanville@nsu.edu, therianh@nsu.edu, ercorbett@nsu.edu" -Subject "Deleted vSphere snapshots older than 1 year" -Body $emailbody -SmtpServer "204.155.176.182"

# Cleanup Snapshot logs older than 365 days.
Get-VM | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-365)} | Remove-Snapshot -Confirm:$false