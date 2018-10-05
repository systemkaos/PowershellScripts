$tapedrive = Get-BEStorage "__RENAME__STORAGE__";
[datetime]$Month = "Saturday, January 23, 2016 2:00:00 AM";
$Monthlymedia = Get-BEMediaSet "3 - Monthly";
$Monthly = New-BESchedule -MonthlyEvery Second -Day Saturday -StartingAt $Month;
$Readyjobs = get-bejob -status ready;

foreach ($job in $readyjobs){;
    if ($job.name -match "Monthly"){;
    #I need backup deftinitions (no filtering)
      $def = $job.BackupDefinition | Get-BEBackupDefinition;
      $def | Remove-BEBackupTask $job.taskname -confirm:0;
      $def | Add-BEDuplicateStageBackupTask -name $job.taskname -VerifyAsPartOfJob:0 -Schedule $monthly -Storage $tapedrive -TapeStorageMediaSet $Monthlymedia -SourceBackup MostRecentFullBackup;
      $def | Save-BEBackupDefinition -confirm:1    };
};

if(){
    #the process is longer than something

    #Do this


}ifelse(){
    #if the process is not longer than this

    #do this other thign

}ifelse(){

}




foreach(#dog in the kennel){

        #we have to feed

}else{
    #dog dies

}
