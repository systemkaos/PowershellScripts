#Admin user powershell > 5
#Working on Server 2012

$varUname =  "mpierce"
$varGroup = "Administrators"
$varPassword = Read-Host "Enter User Password" -AsSecureString

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | where {$_.SchemaClassName -eq 'user' -and $_.Name -eq $varUname}

if($existing -eq $null){

    Write-host "Creating new local user $Username."
    & NET USER $varUname $varPassword /add /y /expires:never

    Write-Host "Adding local user $varUname to $varGroup."
    & NET LOCALGROUP $varGroup $varUname /add

}else{

    Write-Host "Setting Password for existing local user $varUname"
    $exisiting.SetPassword($varPassword)

}

Write-host "Never expires set"
& WMIC USERACCOUNT WHERE "Name='$varUname'" SET PasswordExpires=FALSE