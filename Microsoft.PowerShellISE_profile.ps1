[System.Console]::ForegroundColor = "white"
[System.Console]::BackgroundColor = "DarkBlue"
$console = $host.UI.RawUI
$colors = $host.PrivateData
$console.WindowTitle = "Marks Profile"
$colors.VerboseForegroundColor = "white"
$colors.VerboseBackgroundColor = "blue"
$colors.WarningForegroundColor = "yellow"
$colors.WarningBackgroundColor = "darkgreen"
$colors.ErrorForegroundColor = "white"
$colors.ErrorBackgroundColor = "red"



#Readline location
#C:\Users\markp\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline

#ISE Application Modification
function CheckSteroids {
    if (Get-Command -Name Start-Steroids) {
        Write-Output -Message 'Steroids Inejcted'
    }
    else {
        Write-Output -Message 'Steroids Not found. Not injected'
    }
}

function TestMessages {
    #Output for testing the shell color style, just uncomment to test
    Write-Output "This is a test message."
    Write-Verbose "This is a verbose message." -Verbose
    Write-Warning "This is a warning message."
    Write-Error "This is an error message."
}



CheckSteroids

$varHomeDrive = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath '.\WindowsPowershell\'
$varScriptDir = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath '.\WindowsPowerShell\scripts\'
$varModulesDir = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath '.\WindowsPowerShell\Modules\'


New-PSDrive -Name Scripts -PSProvider FileSystem -Root $varScriptDir
New-PSDrive -Name Modules -PSProvider FileSystem -Root $varModulesDir

New-Alias -name nu -Value Invoke-NormalUser
New-Alias -name su -Value Invoke-SuperUser

Set-Location $varHomeDrive

#$PSVersionTable
Set-PSDebug -Strict
Write-Verbose ("[{0}] Initialize Transcript" -f (Get-Date).ToString()) -Verbose
If ($host.Name -eq "Windows PowerShell ISE Host") {

    $transcripts = "$varHomeDrive\Transcripts\ISE"

    If (-Not (Test-Path $transcripts)) {

        New-Item -path $transcripts -Type Directory | out-null

    }

    $global:TRANSCRIPT = ("{0}\PSLOG_{1:dd-MM-yyyy}.txt" -f $transcripts, (Get-Date))

    Start-Transcript -Path $transcript -Append

    Get-ChildItem $transcripts | Where {

        $_.LastWriteTime -lt (Get-Date).AddDays(-14)

    } | Remove-Item -Force -ea 0

}

function prompt {
    $a = get-date
    $id = 1
    $historyItem = get-history -count 1
    if ($historyitem) {

        $id = $historyItem.id + 1

    }

    write-host -foregroundcolor black "`n[$(get-location)]"
    write-host "[" -noNewLine
    write-host -foregroundcolor Green -backgroundcolor Black $id -noNewLine
    write-host "]" -noNewLine
    write-host "[" -noNewLine
    write-host  -noNewLine $a.ToShortTimeString()
    write-host "]" -noNewLine
    #	write-host $($(Get-Location).Path.replace($home,"~").replace("\","/")) -foreground White -background Black -noNewLine
    write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine

    return "> "
    "`b"
}
