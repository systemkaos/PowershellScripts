#Powershell v5
#Working on server 2016

$varUname = "markp"
$varGroup = "Administrators"
$varPassword = Read-Host "Enter User Password" -AsSecureString

$isExisting = Get-LocalUser -Name $varUname




if($isExisting -eq $null){
    New-LocalUser -Name $varUname -AccountNeverExpires -Password $varPassword
    Add-LocalGroupMember -Group $varGroup -Member $varUname

}else{
    #TODO: Throw Error
}
