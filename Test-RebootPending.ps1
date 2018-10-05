﻿param ([switch] $Report)

Begin
{
	function GetStatusReport ()
	{
		# Trusted Installer related
		if ($host.Version.Build -ge 6001)
		{
			$0 = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
			$cbs = ((Get-ChildItem $0 -ErrorAction SilentlyContinue) -ne $null)
		}
		else
		{
			$cbs = $false
		}

		# Windows update related
		$0 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
		$wua = ((Get-Item $0 -ErrorAction SilentlyContinue) -ne $null)

		try
		{ 
			$util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
			$status = $util.DetermineIfRebootPending()
			$sdk = [bool](($status -ne $null) -and $status.RebootPending)
		}
		catch
		{
			$sdk = $false
		}

		# MSI file rename related
		$0 = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
		$key = Get-Item -LiteralPath $0
		$val = $key.GetValue('PendingFileRenameOperations', $null)
		# ternary operation ?: indexed hashtable
		$msi = @{$true=($val | ? { $_ -notmatch 'TEMP' -and $_ -ne '' }).Count -gt 0; $false=$false}[$null -ne $val]

		## computer rename related
		$currName = (Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' -Name 'ComputerName')
		$pendName = (Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' -Name 'ComputerName')
		$com = ($currName -ne $pendName)

		return @{
			CBSServicing = $cbs
			MSIFileRename = $msi
			WindowsUpdate = $wua
			ClientSDK = $sdk
			ComputerRename = $com
		}
	}
}
Process
{
	$status = GetStatusReport

	if ($Report)
	{
		return $status
	}

	return $status.CBSServicing -or $status.MSIInstaller -or $status.WindowsUpdate `
		-or $status.ClientSDK -or $status.FileRename -or $status.ComputerRename
}