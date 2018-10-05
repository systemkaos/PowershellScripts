
#####
#Job Names allow us to pinpoint backups
#This is unique to our environement yours will differ.
$jobSelections = ("Daily - Disk - Incr","Daily - Tape - Incr","Weekly - Disk - Full","Weekly - Tape - Full","Monthly - Tape - Full", "Yearly - Tape - Full")
#####

#Collects all job histories. This takes a while due to the amount of jobs
#Job Status Codes to search for
$jobStatuses = ("Error","Missed","Queued")

#This is used for converting sizes to something more readble
#Taken from online. Im not re-inventing the damn wheel.
 Function Convert-BytesToSize
{
<#
.SYNOPSIS
Converts any integer size given to a user friendly size.
.DESCRIPTION


Converts any integer size given to a user friendly size.

.PARAMETER size


Used to convert into a more readable format.
Required Parameter

.EXAMPLE


ConvertSize -size 134217728
Converts size to show 128MB

#>


#Requires -version 2.0


[CmdletBinding()]
Param
(
[parameter(Mandatory=$False,Position=0)][int64]$Size

)


#Decide what is the type of size
Switch ($Size)
{
{$Size -gt 1PB}
{
Write-Verbose “Convert to PB”
$NewSize = “$([math]::Round(($Size / 1PB),2))PB”
Break
}
{$Size -gt 1TB}
{
Write-Verbose “Convert to TB”
$NewSize = “$([math]::Round(($Size / 1TB),2))TB”
Break
}
{$Size -gt 1GB}
{
Write-Verbose “Convert to GB”
$NewSize = “$([math]::Round(($Size / 1GB),2))GB”
Break
}
{$Size -gt 1MB}
{
Write-Verbose “Convert to MB”
$NewSize = “$([math]::Round(($Size / 1MB),2))MB”
Break
}
{$Size -gt 1KB}
{
Write-Verbose “Convert to KB”
$NewSize = “$([math]::Round(($Size / 1KB),2))KB”
Break
}
Default
{
Write-Verbose “Convert to Bytes”
$NewSize = “$([math]::Round($Size,2))Bytes”
Break
}
}
Return $NewSize

}

Function JobCollector()
  {
    <#
    Function to export all the data for each job selection and each status.
    Requires an amount of days to go back.
    Requires the Parameter of "daysback". This will count back from the day in get-date and pull all information within that period

    The function loops over all possible statuses for each of our job selections
    #>
    Param([parameter(Mandatory=$True,Position=1)]
    [int]$Daysback
    )
    $date = get-date (get-date).AddDays(-$daysback) -format G
    Foreach($status in $jobStatuses)
    {

      Foreach($selection in $jobSelections)
        {
            #Takes the date and how far back and converts it to the same format as Backup Exec
            
            $history = get-bejobhistory -Name "*$selection*" -JobStatus $status -FromStartTime $date
            $history | Select-Object JobName, StartTime, ErrorCode, ErrorMessage | export-csv C:\temp\$status.csv -Append -NoTypeInformation
            
        }        
    }

    #Jobsize Function
    Function JobSizes()
    {
        #$date = get-date (get-date).AddDays(-$Daysback) -format G
        $thedate = get-date -Format MM-dd-yy
        $jobHistory = get-bejobHistory -JobStatus "Succeeded" -FromStartTime $date | where {$_.PercentComplete -eq 100 -and $_.JobType -eq "Duplicate" -or $_.JobType -eq "Backup"}

        #loops through the jobs to change the job size from raw kb to user friendly readable format
        foreach($job in $jobHistory)
        {
           $properties = [Ordered]@{'JobName'=$job.JobName;
           'RawSize'=$job.TotalDataSizeBytes;
           'ConvertedSize'= Convert-BytesToSize -Size ($job.TotalDatasizeBytes);
           'JobDate'=$job.StartTime
            }
            $object = New-Object -TypeName PSObject -Property $properties 
            $filename = "Backup Sizes for $Daysback days since $thedate .csv" 
            $object | export-csv "C:\temp\$filename" -Append -NoTypeInformation
        }             
    }
 JobSizes
  }