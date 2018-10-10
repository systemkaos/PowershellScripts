#TODO: This is hardcoded. Dont Hardcode this
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`

        [Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"

    Break

}
else {
    try {. D:\Users\markp\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1}
    catch {Write-Error "You hardcoded your profile.ps1 location"}




}