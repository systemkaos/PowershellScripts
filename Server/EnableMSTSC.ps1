function Enable-MSTSC (){
  #TODO: Check to Verify
  #TODO: Add switch to check just firewall Rule
  #TODO: Add switch to enable/disable firewall rule
  Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0
  $fwrunning = (Get-Service | where {$_.Name -eq 'mpssvc'}).Status
  #Adds firewall rule   
   if($fwrunning -eq 'Running'){
     Enable-NetFirewallRule -DisplayGroup "Remote Desktop"   
     #Rule CHeck
     $fwcheckenabled = (Get-NetFirewallRule -DisplayGroup "Remote Desktop")[0].Enabled
     Write-Output "Firewall rule enabled: $fwcheckenabled"
   }
}