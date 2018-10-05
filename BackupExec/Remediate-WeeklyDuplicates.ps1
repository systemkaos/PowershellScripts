$tapedrive = Get-BEStorage "__STORAGE__NAME__";
[datetime]$Week = "Saturday, January 23, 2016 2:00:00 AM";
$Weeklymedia = Get-BEMediaSet "2 - Weekly";
$Weekly = New-BESchedule -MonthlyEvery Second -Day Saturday -StartingAt $Week;
$Readyjobs = get-bejob -status ready;

foreach ($job in $readyjobs) {
    ;
    if ($job.name -match "Weekly") {
        ;
        $def = $job.BackupDefinition | Get-BEBackupDefinition;
        $def | Remove-BEBackupTask $job.taskname -confirm:0;
        $def | Add-BEDuplicateStageBackupTask -name $job.taskname -VerifyAsPartOfJob:1 -Storage $tapedrive -TapeStorageMediaSet $Weeklymedia -ImmediatelyAfterBackup "Weekly - Disk - Full";
        $def | Save-BEBackupDefinition -confirm:0    
    };
};
