#STORED CREDENTIAL CODE
$Domain = Read-Host "Enter Domain Name"
$AdminName = Read-Host "Enter your UserName"
$CredsFile = "C:\Users\chrisas\Documents\nsu-vcheck\Password\$AdminName-PowershellCreds.txt"
$FileExists = Test-Path $CredsFile
if ($Domain -eq "") {
$Username = $AdminName
}
else {
$Username = $Domain+"\"+$AdminName
}
if  ($FileExists -eq $false) {
    Write-Host 'Credential file not found. Enter your password:' -ForegroundColor Red
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $CredsFile
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$password}
else
    {Write-Host 'Using your stored credential file' -ForegroundColor Green
	Read-Host "Enter your new password" -AsSecureString | ConvertFrom-SecureString | Out-File $CredsFile
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$password}