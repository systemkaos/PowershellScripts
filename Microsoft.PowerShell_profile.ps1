if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    $AdminTitle = "(Admin) "
    $IsAdmin = $true
}

$ipaddress = [System.Net.DNS]::GetHostByName($null)
foreach ($ip in $ipaddress.AddressList) {
    if ($ip.AddressFamily -eq 'InterNetwork') {
        $ModernConsole_IPv4Address = $ip.IPAddressToString
        break
    }
}

$console = $host.UI.RawUI
$colors = $host.PrivateData
$console.WindowTitle = "Marks Profile"
$colors.VerboseForegroundColor = "white"
$colors.VerboseBackgroundColor = "blue"
$colors.WarningForegroundColor = "yellow"
$colors.WarningBackgroundColor = "darkgreen"
$colors.ErrorForegroundColor = "white"
$colors.ErrorBackgroundColor = "red"
$console.BackgroundColor = "Black"
$console.ForegroundColor = "Gray"

$console.WindowTitle = $AdminTitle + "Windows PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"

$Size = $console.WindowSize
$Size.width = 108
$Size.height = 30
$console.WindowSize = $Size

$Size = $console.BufferSize
$Size.width = 108
$Size.height = 5000
$console.BufferSize = $Size

$MaximumHistoryCount = 10000

$RootDir = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
$ModulesDir = 'c:\'
$ScriptsDir = 'c:\'
$HomeDrive = 'c:\'
$scriptdirset = $false
$moddirset = $false
$psdriveset = $false
function TestMessages {
    #Output for testing the shell color style, just uncomment to test
    Write-Output "This is a test message."
    Write-Verbose "This is a verbose message." -Verbose
    Write-Warning "This is a warning message."
    Write-Error "This is an error message."
}
function uptime {
	Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';
	EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}
function reload-profile {
	& $profile
}
function find-file($name) {
	ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
		$place_path = $_.directory
		echo "${place_path}\${_}"
	}
}
function print-path {
	($Env:Path).Split(";")
}
function unzip ($file) {
	$dirname = (Get-Item $file).Basename
	echo("Extracting", $file, "to", $dirname)
	New-Item -Force -ItemType directory -Path $dirname
	expand-archive $file -OutputPath $dirname -ShowProgress
}
function checkmoddrive {
    Try{
        New-PSDrive -Name Modules -PSProvider FileSystem -Root $Script:ModulesDir
        $Script:moddirset = $true
    }
    Catch{
        Write-Error -Message "Unable to set PSDrive Modules" $_.message
    }
}
function checkscriptsdrive {
    try{
        New-PSDrive -Name Scripts -PSProvider FileSystem -Root $Script:ScriptsDir
        $Script:scriptdirset = $true
    }Catch{
        Write-Error -Message "Unable to set PSdrive scripts" $_.message
    }
}
function checkandsetalias{
    param(
        $PathToExe,
        $AliasName
    )
    if(Test-Path -Path $PathToExe){
        Set-Alias -name $AliasName -Value $PathToExe
        return 1
    }else{
        return 0
    }
}
function Clear-Host {
    $space = New-Object System.Management.Automation.Host.BufferCell
    $space.Character = ' '
    $space.ForegroundColor = $host.ui.rawui.ForegroundColor
    $space.BackgroundColor = $host.ui.rawui.BackgroundColor
    $rect = New-Object System.Management.Automation.Host.Rectangle
    $rect.Top = $rect.Bottom = $rect.Right = $rect.Left = -1
    $origin = New-Object System.Management.Automation.Host.Coordinates
    $Host.UI.RawUI.CursorPosition = $origin
    $Host.UI.RawUI.SetBufferContents($rect, $space)
    Write-StartScreen
}
function Write-StartScreen {

    $EmptyConsoleText = @"



+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+
|
|   Domain\Username  :  $env:USERDOMAIN\$env:USERNAME
|   Hostname         :  $([System.Net.Dns]::GetHostEntry([string]$env:computername).HostName)
|   IPv4-Address     :  $ModernConsole_IPv4Address
|   PSVersion        :  $ModernConsole_PSVersion
|   Date & Time      :  $(Get-Date -Format F)
|
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=+
                 _
                /_ _  _  __ /__  _  __/__//_
               ._//_//_|/ //\/_//_|/_//_///_'
                 /          /

"@

    Write-Host -Object $EmptyConsoleText
}

if(!(Test-Path -Path ($RootDir+"\WindowsPowershell"))){
    write-host "Unable to find a WindowsPowershell directory, building one out now"
   #Create WindowsPowershelldrive
    New-Item -ItemType Directory -Path ($RootDir+"\WindowsPowershell\")
    $psdriveset = $true
    #SetHomeDrive
    $Script:HomeDrive = $RootDir+"\WindowsPowershell\"
    #Now check for our sub directories of scripts and modules
    if(!(Test-Path -Path ($Script:HomeDrive + 'scripts\'))){
        write-host "Unable to find a scripts drive, setting one now"
        $Script:ScriptsDir = $Script:HomeDrive+'scripts\'
        #No Scripts Dir
        New-Item -ItemType Directory -Path ($Script:HomeDrive+"scripts\")
        #checkscriptsdrive
    }Else{
        Write-Host "Scripts drive found, setting variables"
        $Script:ScriptsDir = $Script:HomeDrive+'scripts\'
        #checkscriptsdrive
    }
    if(!Test-Path -Path ($Script:HomeDrive + 'Modules\')){
        Write-Host "Unable to find a modules drive, setting one now"
        $Script:ModulesDir = $Script:HomeDrive+'Modules\'
        #no Modules dir
        New-Item -ItemType Directory -Path ($Script:HomeDrive+"Modules\")
        #checkmoddrive
    }else{
        Write-Host "Modules drive found, setting variables"
        $Script:ModulesDir = $Script:HomeDrive+'Modules\'
        #checkmoddrive
    }

}else{
    Write-Host "All drive checks passed, setting variables"
    $Script:HomeDrive = $RootDir + "\WindowsPowershell\"
    $Script:ScriptsDir = $Script:HomeDrive+'scripts\'
    $Script:ModulesDir = $Script:HomeDrive+'Modules\'

    checkscriptsdrive
    checkmoddrive
    #WindowsPowershellDrive is present, set variables
    $psdriveset = $true
    #Check Sub dirs
}

    New-Alias -name nu -Value Invoke-NormalUser

    New-Alias -name su -Value Invoke-SuperUser


checkandsetalias -PathToExe 'C:\Program Files\Mozilla Firefox\firefox.exe' -AliasName 'firefox'

# PSVersion (e.g. 5.0.10586.494 or 4.0)
if ($PSVersionTable.PSVersion.Major -gt 4) {
    $ModernConsole_PSVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Build).$($PSVersionTable.PSVersion.Revision)"
} else {
    $ModernConsole_PSVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
}

Set-PSDebug -Strict


Set-Location -path $HomeDrive


#Prompt Transcripts
Write-Verbose ("[{0}] Initialize Transcript" -f (Get-Date).ToString()) -Verbose
If ($host.Name -eq "ConsoleHost") {
    $transcripts = $HomeDrive + 'Transcripts\Powershell'
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
    $adate = get-date
    $Path = Get-Location
    $CurrentFolder = Split-Path -Leaf -Path $Path
    $id = 1

    $historyItem = get-history -count 1
    if ($historyitem) {

        $id = $historyItem.id + 1

    }

    # Is path a netowrk share?
    if ($Path.ToString().StartsWith("Microsoft.PowerShell.Core\FileSystem")) {
        $NetworkShare = $Path.ToString().Split(":")[2].Replace("\\", "")

        $Hostname = $NetworkShare.Split('\')[0]
        $Share = $NetworkShare.Split('\')[1]

        $RootPath = "\\$Hostname\$Share"
    } else {
        $DriveLetter = Split-Path -Path $Path -Qualifier
        $RootPath = "$DriveLetter"
    }

    if (([String]::IsNullOrEmpty($CurrentFolder)) -or ($CurrentFolder.EndsWith('\'))) {
        $Folder = "\"
    } else {
        $Folder = "$CurrentFolder"
    }

    Write-Host -ForegroundColor gray "`n[$Path]"
    Write-Host -Object "[" -NoNewline -ForegroundColor Gray
    Write-Host -Object "$id" -NoNewline -ForegroundColor Green
    Write-Host -Object "] " -NoNewline -ForegroundColor Gray
    write-host  -noNewLine $adate.ToShortTimeString() -ForegroundColor yellow

    if ($IsAdmin) {
        Write-Host -Object " (" -NoNewline -ForegroundColor Gray
        Write-Host -Object "Admin" -NoNewline -ForegroundColor Red
        Write-Host -Object ") " -NoNewline -ForegroundColor Gray
    }

    Write-Host -Object "~#" -NoNewline -ForegroundColor Gray
    return " "
}

# Clear Console and show start screen
Clear-Host