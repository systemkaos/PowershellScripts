Function Check-DomainJoined(){
    $varWMIQuery = (gwmi win32_computersystem).partofdomain
    $boolDomainStatus = $false
    if ($varWMIQuery -eq $true) {
        $boolDomainStatus = $true
        $boolDomainStatus
    } elseif ($varWMIQuery -eq $false) {
        $boolDomainStatus
    }
}