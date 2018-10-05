#Get-Uptime
function get-uptime(){
    param(
    )

    $date = get-date -format G
    #TODO: Add paramater for Days back to check
    $dateb = (get-date).AddDays(-60).ToString('MM/dd/yyyy hh:mm:ss tt')
    $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue | Select @{
        Name       = "LastBootUpTime";
        Expression = { [Management.ManagementDateTimeConverter]::ToDateTime($_.LastBootUpTime) }
    }
    function get-rebootevents(){
        #TODO: Add params for
      # $filter = @{LogName='System';id='1074';level='4'}
      $filter = @{LogName='System';id='1074'}
      $rebootfinder = get-winevent -FilterHashtable $filter | where {$_.TimeCreated -ge $dateb}
      foreach($event in $rebootfinder)
      {
      $AccountResponsible = ($event.message -split 'user (.*?\.*?) ')[1]
      $timestampofReboot = $event.Timecreated
      $rebootobject = @{Rebooted=$timestampofReboot;
      Account=$AccountResponsible;
      Message=$event.message}}
      $rebootobject
    }
    #TODO: paramater for check period
    if($os.LastbootUpTime -le (get-date).AddDays(-2))
    {
      get-rebootevents

        write-host "The last boot time was " $os.LastBootUpTime
      }else
      {
        write-host "The last boot time was "$os.LastBootupTime
      }
}