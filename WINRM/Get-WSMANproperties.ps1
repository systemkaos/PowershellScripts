#Enable WINRM Service
$winrmRunning = $false
function Check-WinRMService {
    $script:winrmRunning
    if ((get-service -Name WinRM).Status -ne 'Running') {
        Write-host 'Service not running'
        Start-Service -Name WinRM -ErrorAction SilentlyContinue

        If ((get-service -Name WinRM).Status -eq 'Running') {
            $script:winrmRunning = $true
            Write-Host "WINRM started"
        }
        else {
            $script:winrmRunning = $false
            Write-Host "Could not start winrm"
        }
    }
    else {
        $script:winrmRunning = $true
        Write-host "Winrm Already running"
    }
}
Check-WinRMService


if ($winrmRunning = $true) {

    $obj = [pscustomobject]@{
        
    }

}#End If Statement for Service Running

else {
    Write-Error -Message "WinRM service not running"
}