$errorType = 'error'
#$LogType = 'Application'
$LogType = 'System'
$TimespanInDays = 30

function CollectEvents ($TimespanInDays, $errorType, $LogType) {
  #$LogType = 'System'
  #$TimespanInDays = 30
  $x = (get-date) - (New-TimeSpan -Days $TimespanInDays)
  $events = Get-WinEvent -LogName $LogType | Where-Object {$_.TimeCreated -ge $x -and $_.LevelDisplayName -eq $errorType}
  Return $events;
}

function MostFrequent($EventCollection) {
  #$SystemEvents | Group-Object -Property Id -NoElement | Sort-Object -Property Count -Descending
  $EventCollection | Group-Object -Property Id -NoElement | Sort-Object -Property Count -Descending
}

function CollectFrequentEvents($TimespanInDays, $errorType, $LogType) {
  $EventCollection = CollectEvents -TimespanInDays  $TimespanInDays -errorType $errorType -LogType $LogType
  $m = MostFrequent -EventCollection $EventCollection

  foreach ($x in $m) {
    #$x.Name
    $EventCollection | Where-Object {$_.Id -eq $x.Name}
    Write-Output '----------'

  }
}

function ReadMessage($frequentEvents, $Id){
  #Use CollectFrequentEvents to populate the $frequentEvents Value
  $msg = ($frequentEvents | Where-Object {$_.Id -eq $Id}).Message | Select-Object -First 1
  return $msg;
}


$ErrorCollection = CollectEvents -TimespanInDays '2' -errorType $errorType -LogType $LogType
#CollectFrequentEvents -evnts $ErrorCollection

#CollectFrequentEvents -TimespanInDays '10' -errorType $errorType -LogType $LogType
$frequentEvents = CollectFrequentEvents -TimespanInDays '30' -errorType $errorType -LogType $LogType


$frequentEvents[0].Message | Format-Custom * -Depth 5

($ErrorCollection | where {$_.Id -eq 7}).count
$frequentEvents

ReadMessage -frequentEvents $frequentEvents -Id 4
