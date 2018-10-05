#Will Name all Jobs that Have the defined JobStatus

$daysBack = 42
$jobstatus = 'Succeeded'
$today = get-date -Format G
$dateRange = (get-date).AddDays(-$daysBack).ToString('MM/dd/yyyy hh:mm:ss tt')


Get-BEJobHistory -FromStartTime $dateRange | ForEach-Object{
		if ($_.JobStatus -eq "$jobStatus")
			{$name = $_.Name
			  Write-Host $_.Name}
	}

#Loops Through Each type of JobStatus(as defined in the variable) and Counts each type of job status
#Will also list the job that failed
$daysBack = 1
$jobStatus = ("Error","Canceled","Completed","Missed")
$dateRange = (get-date).AddDays(-$daysBack).ToString('MM/dd/yyyy hh:mm:ss tt')


foreach($status in $jobStatus)
	{
	 $BeJobs = Get-BEJobHistory -FromStartTime $dateRange -JobStatus $status
	 #selects teh status of BE Job HIstory and counts all those status
	 $status + " " + $BeJobs.Count + "`r`n "
	 #Outputs Job names with Error Codes
	 $BeJobs.JobName + $BeJobs.ErrorCode +"`r`n"
	 $bejobs @ ($_.Jobname,$_.ErrorCode,$_.ErrorMessage)
	}
