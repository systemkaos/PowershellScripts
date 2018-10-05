$jobsOnHold = Get-BEJob -Status OnHold
$jobsOnHold.count
foreach ($jobOnHold in $jobsOnHold)
	{
		Resume-BEJob -InputObject $jobOnHold
	}
	
