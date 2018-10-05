$date = (get-date).AddDays(-2);
$thedate = $date.ToString('MM/dd/yyyy hh:mm:ss tt');
get-hotfix | where {$_.InstalledOn -ge $thedate };
