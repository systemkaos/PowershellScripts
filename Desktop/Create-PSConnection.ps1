#NOTE: Creates a named PS connection.
#Will automatically connect
#TODO: Add error handeling
#TODO: Add logic
function create-psconnection () {
		Param([parameter(Mandatory=$True,Position=0)]
		[string]$remotehost,
		[parameter(Mandatory=$False,Position=1)]
		[string]$name
		)

		$creds = Get-Credential
		$sessionobject = New-PSSession -ComputerName $remotehost -Credential $creds -Name $name
		Enter-PSSession $sessionobject
	}