$tapedrive = Get-BEStorage "__STORAGE__NAME__";
[datetime]$Year = "Saturday, January 21, 2017 2:00:00 AM";
$Yearmedia = Get-BEMediaSet "4 - Yearly";
$yearly = New-BESchedule -YearlyEvery Second -Day Saturday -Month January -StartingAt $Year;
$Readyjobs = get-bejob -status ready;

foreach ($job in $readyjobs) {
    ;
    if ($job.name -match "Yearly") {
        ;
        $def = $job.BackupDefinition | Get-BEBackupDefinition;
        $def | Remove-BEBackupTask $job.taskname -confirm:0;
        $def | Add-BEDuplicateStageBackupTask -name $job.taskname -VerifyAsPartOfJob:0 -Schedule $yearly -Storage $tapedrive -TapeStorageMediaSet $Yearmedia -SourceBackup MostRecentFullBackup;
        $def | Save-BEBackupDefinition -confirm:1    
    };
};
