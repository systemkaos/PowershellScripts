<#
What are you modifying
-Firewall Properties
1.Domain Profile
    State: on
    Inbound: Allow
    Outbound Allow
2.Private Profile
    State: on
    Inbound: Allow
    Outbound Allow
3.Public Profile
    #!Check this state
    State: off
    Inbound: Allow
    Outbound Allow
4.IPSec
    ICMP Exempt NO

Open Ports for WINRM

    #>

Set-NetFirewallProfile -Profile Domain,Private -Enabled true -DefaultInboundAction Allow -DefaultOutboundAction Allow -Verbose
Set-NetFirewallProfile -Profile Public -Enabled false -Verbose

#TODO: IPSec
#Set-NetFirewallProfile -Profile IPSec -AllowUnicastResponseToMulticast True -Verbose

Enable-PSRemoting -Force -Verbose
Enable-WSManCredSSP -Role Server -Force -Verbose

$winrmRunning = $false

function Check-WinRMService{
    if ((get-service -Name WinRM).Status -ne 'Running') {
        Write-host 'Service not running'
        Start-Service -Name WinRM -ErrorAction SilentlyContinue

        If ((get-service -Name WinRM).Status -eq 'Running') {
            $script:winrmRunning = $true
            Write-Host "WINRM started"
        } else {
            $script:winrmRunning = $false
            Write-Host "Could not start winrm"
        }
    } else {
        $script:winrmRunning = $true
        Write-host "Winrm Already running"
    }
}

Check-WinRMService

if ($winrmRunning = $true) {

    #Enable PSRemoting for non domain machines
    function Enable-PSRemotingNonDomain {
        #Run on local machine
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value "1" -PropertyType DWORD -Force

        Enable-PsRemoting -Force

        #TODO:This is a hammer solution. * is not advised
        #INFO: ONLY USE IN DEV/TEST
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
    }#End Enable-PSRemotingNonDomain function

    #Enable Public Firewall Inbound connection
    Set-NetFirewallProfile -Name Public -DefaultInboundAction Allow


    Enable-PSRemotingNonDomain
    Write-Verbose -Message "PS-Remoting Enabled"
} else {
    Write-Error -Message "WinRM service not running"
}