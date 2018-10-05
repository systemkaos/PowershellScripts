$inputs = Get-BEJob | where {$_.Name -like "*Weekly*Disk*Full"}

foreach ($input in $inputs)
	{
		Start-bejob -Input $input.name	-confirm:0
	}
	
	
	