$jobsHeld = Get-BeJob -Status OnHold

foreach($jobheld in $jobsheld)
	{
	Start-bejob -Inputobject $jobheld.name -force -confirm:0
	}