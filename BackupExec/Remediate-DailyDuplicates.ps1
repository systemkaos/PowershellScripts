$tapedrive = Get-BEStorage "__TAPE__LIBRARY__NAME__";
[datetime]$Day = "Saturday, January 23, 2016 2:00:00 AM";
$Dailymedia = Get-BEMediaSet "1 - Daily";
$Daily = New-BESchedule -MonthlyEvery Second -Day Saturday -StartingAt $Day;
$Readyjobs = get-bejob -status ready;

foreach ($job in $readyjobs) {
    ;
    if ($job.name -match "Daily") {
        ;
        $def = $job.BackupDefinition | Get-BEBackupDefinition;
        $def | Remove-BEBackupTask $job.taskname -confirm:0;
        $def | Add-BEDuplicateStageBackupTask -name $job.taskname -VerifyAsPartOfJob:1 -Storage $tapedrive -TapeStorageMediaSet $Dailymedia -ImmediatelyAfterBackup "Daily - Disk - Incr";
        $def | Save-BEBackupDefinition -confirm:0    
    };
};