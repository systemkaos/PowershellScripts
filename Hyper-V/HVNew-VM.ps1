<#
    !DEV COMMENTOUT
    $VMNAME = 'DEVVARVMNAME'
    $templateDir = 'C:\VHD\Templates\'
    $virtualMachineDir = 'C:\VirtualMachines\'
    $templateName = 'Windows Server 2016 Datacenter Full.vhdx'
    $isodir = 'C:\ISO'
    $ISONAME = 'Windows-10'
    #!DEV COMMENTOUT

#>

$VMNAME = $null
#$path = $null
$vhd = $null
$ISONAME = $null

$ErrorActionPreference = 'Stop'

function isoObjConstruct {
    <#
      .SYNOPSIS
      Creates a hash table of items in the directory provided by the paramater

      .DESCRIPTION
      A rough implementation to create a hash table that helps maps a user input. This simply maps the directory and creates the hash

      .PARAMETER isodir
      The directory you store your .iso files

      .EXAMPLE
      isoObjConstruct -isodir Value
      Outputs a hashtable mapping a directories items basenames to their full names.

      .NOTES
      Any .iso file in the directory you map to has to have a basename.
      Make sure any basename you intend to use is named in a way you understand
  #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'The Directories you store your .iso files.')]
        [String[]]
        $isodir
    )

    #TODO: Error Handling function Differencing
    $d = (Get-ChildItem -Path $isodir)
    Write-Debug "Before foreach" -Debug
    foreach ($i in $d) {
        $obj = @{
            $i.BaseName = $i.FullName
        }
        Write-Output -InputObject $obj
    }#End Foreach
}#End function isoObjConstruct -isodir $isodir

function Differencing {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'The Virtual Machine Name you wish to make a differencing disk of')]
        [String[]]
        $VMNAME,
        [Parameter(Mandatory = $true, HelpMessage = 'The Directory you store your virtual machines in')]
        #[??[]]
        $virtualMachineDir,
        [Parameter(Mandatory = $true, HelpMessage = 'The Template we will create a differencing VHD from')]
        [String[]]
        $templateDir,
        $templatename = 'Windows Server 2016 Datacenter Full.vhdx'
    )

    #TODO: Document function Differencing
    #TODO: Error Handling function Differencing

    #Creates a Differencing disk for use in templates
    #$path = @()
    #New Dir
    Write-Verbose -Message 'Setting path of VHD'
    Try {
        $path = New-Item -Path ($virtualMachineDir + $VMNAME) -ItemType Directory -Verbose -ErrorAction $ErrorActionPreference -ErrorVariable newvmpatherr
    } Catch {
        #Write-Error 'Unable to set the VHD path variable function Differencing'
        Write-Error -Message 'Error is: ' -Exception $newvmpatherr
    }
    #New VHD for Differencing
    Write-Verbose -Message 'Setting VHD with newley created VHD'
    Try {
        $script:vhd = New-VHD -Path ($path.FullName + '\' + $VMNAME + '.vhdx') -ParentPath $TemplateDir$templatename -Differencing -Verbose -ErrorAction $ErrorActionPreference -ErrorVariable newVhdDiffErr
    } Catch {
        Write-Error 'Unable to create a Differencing VHD and set the variable function Differencing'
    }

}#End function Differencing
function CreateHypervVM {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'The Virtual Machine Name you wish to create')]
        [alias('VirtualMachine', 'VM')]
        #[String[]]
        $VMNAME,
        $virtualMachineDir,
        $ISODIR,
        [parameter(Mandatory = $true, HelpMessage = 'The Selected ISO to be mounted to your Virtual Machine')]
        [ValidateSet('Centos-7-everything', 'SVR2016.ENU.APR2017', 'ubuntu-18', 'Windows-10')]
        #[String[]]
        $ISONAME,
        $MemoryStartupBytes = 2147483648,
        $NewVHDSizeBytes = 128849018880
    )
    #TODO: Document function CreateHypervVM
    #TODO: Error Handling function CreateHypervVM
    #TODO: Map parmaters with object function CreateHypervVM
    #TODO: Implement Better switch detection

    <#
      !ISO TABLE <isoObjConstruct($isodir)>
      Name                           Value
      ----                           -----
      Centos-7-everything            C:\ISO\Centos-7-everything.iso
      SVR2016.ENU.APR2017            C:\ISO\SVR2016.ENU.APR2017.iso
      ubuntu-18                      C:\ISO\ubuntu-18.iso
      Windows-10                     C:\ISO\Windows-10.iso
    #>


    $Path = ($virtualMachineDir + $VMName)

    $NewVHDPath = "$virtualMachineDir$VMName\$VMName.vhdx"

    #TODO: Better Switch Validation function CreateHypervVMTemplated
    Try {
        Write-Verbose -Message 'Setting Switch'
        $SwitchName = (Get-VMSwitch -Verbose -ErrorAction $ErrorActionPreference -ErrorVariable getVMSwitchErr).Name[0]
    } Catch {
        Write-Error -Message 'Unable to find a switch to set' -ErrorAction Stop
    }

    #Build our VM
    Try {
        Write-Debug -Message 'Entering New-VM'
        Write-Verbose -Message 'Building New VM with attached ISO'
        New-VM `
            -Name $VMName `
            -MemoryStartupBytes $MemoryStartupBytes `
            -BootDevice CD `
            -SwitchName $SwitchName `
            -NewVHDPath $NewVHDPath `
            -NewVHDSizeBytes $NewVHDSizeBytes `
            -Generation 1 `
            -Path $Path `
            -Force `
            -Verbose
    } Catch {
        Write-Debug -Message 'newVmErr Catch Clause'
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.InnerException

        Write-Error -Message "The item was $FailedItem. Unable to Create a new VM $ErrorMessage."
    }

    #Build our Processor
    Write-Verbose -Message 'Building Processor'
    Set-VMProcessor -VMName $VMName -Count 2 -Reserve 10 -Maximum 75 -RelativeWeight 200 -Verbose -ErrorAction $ErrorActionPreference -ErrorVariable buildvmprocessorErr
    Try {
        Write-Verbose -Message 'Setting DVD drive and Attaching ISO'
        Set-VMDvdDrive -VMName $VMNAME -Path (isoObjConstruct -isodir ($isodir)).$ISONAME -Verbose -ErrorVariable attachisoerr
    } Catch {
        Write-Warning -Message "Unable to mount your ISO. Your error is $attachisoerr"
    }

}#End function CreateHypervVM
function CreateHypervVMTemplated() {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'The Virtual Machine Name you wish to create')]
        [alias('VirtualMachine', 'VM')]
        $VMNAME,
        $virtualMachineDir,
        $MemoryStartupBytes = '2147483648',
        $templateDir = 'X:\VHD\Templates',
        $templateName = 'Windows Server 2016 Datacenter Full.vhdx'
    )

    #TODO: Move Params CreateHypervVMTemplated
    #TODO: Document CreateHypervVMTemplated
    #TODO: Error Handling CreateHypervVMTemplated
    #TODO: Map parmaters with object CreateHypervVMTemplated


    #$BootDevice = "VHD"
    #TODO: Better Switch Validation function CreateHypervVMTemplated
    Try {
        Write-Verbose -Message 'Setting Switch'
        $SwitchName = (Get-VMSwitch -Verbose -ErrorAction $ErrorActionPreference -ErrorVariable getVMSwitchErr).Name[0]
    } Catch {
        Write-Error -Message 'Unable to find a switch to set' -ErrorAction Stop
    }

    #!Required for Templated VMs
    Try {
        Differencing -VMNAME $VMNAME -virtualMachineDir $virtualMachineDir -templateDir $templateDir -templatename $templatename
    } Catch {
        Write-Error "Unable to create a differencing disk in function CreateHypervVMTemplated"
    }

    #Try {
    Write-Verbose -Message 'Creating New VM from template'
    Write-Debug "Entering new-vm"
    new-vm `
        -Name $VMNAME `
        -Path $virtualMachineDir `
        -VHDPath ($script:vhd).Path  `
        -BootDevice VHD `
        -Generation 2 `
        -SwitchName $SwitchName | Set-VMMemory `
        -DynamicMemoryEnabled $false `
        -StartupBytes $MemoryStartupBytes `
        -Verbose `
        -ErrorAction $ErrorActionPreference `
        -ErrorVariable newVmErr
    #} Catch {
    #Write-Error -Message 'Unable to Create a new VM'
    #Write-Error -Message 'Error is: ' -Exception $newVmErr
    #}

}#End function CreateHypervVMTemplated



function AddHardDrive {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'The Virtual Machine Name you wish to add a Hard Drive to')]
        [alias('VirtualMachine', 'VM')]
        #[String[]]
        $VMNAME,
        [Parameter(Mandatory = $true, HelpMessage = 'Will be used for the total size of the drive you will create')]
        [alias('HDSize', 'DriveSize', 'HardDriveSizeInBytes')]
        #[String[]]
        $HDS,

        $VHDName
    )
    #TODO: Move Params function AddHardDrive
    #TODO: Document function AddHardDrive
    #TODO: Error Handling function AddHardDrive

    $hdn = $virtualMachineDir + $VMNAME + '\' + $VHDName + (get-date).ticks + '.vhdx'
    Write-Verbose -Message "Creat Random name for Hard drive: $hdn"

    #Create VHD
    try {
        Write-Verbose -Message 'Creating new VHD'
        New-VHD -Path $hdn -Dynamic -SizeBytes $HDS -Verbose -ErrorAction $ErrorActionPreference -ErrorVariable newVHDerr
    } Catch {
        Write-Error -Message 'Unable to Create new VHD'
    }
    #Add VHD
    #Add-VMHardDiskDrive -VMName $VMNAME -Path $VHDPath
    try {
        Write-Verbose -Message 'Adding VHD to VM'
        Add-VMHardDiskDrive -VMName $VMNAME -Path $hdn -Verbose -ErrorAction $ErrorActionPreference -ErrorVariable addharddiskdriveErr
    } Catch {
        write-error -Message 'Unable to add VMHardDiskDrive'
    }
}#End function AddHardDrive
Function DeleteVM {
    [CmdletBinding(SupportsShouldProcess = $true)]
    <#
      .SYNOPSIS
      Used to delete VM by name and location from Hyper-V.

      .DESCRIPTION
      Deletes Virtual machines and their folders from Hyper-V and Windows. This is a very heavy handed approach but works fine for dev

      .PARAMETER VMNAME
      The Exact name of the virtual machine as displayed in Hyper-V

      .PARAMETER virtualMachineDir
      The directory that holds your virtual machines. Requires trailing slash.

      .EXAMPLE
      DeleteVM -VMNAME Value -virtualMachineDir Value
      Deletes the VMname and assuming the folder is named after the VM, that will be removed.

      .NOTES
      Requires that the VM name be the folder name where you store the VMs.
  #>

    #TODO: Add data validation to $virtualMachineDir to check for slashes at front
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'The Virtual Machine Name you wish to delete')]
        [alias('VirtualMachine', 'VM')]
        [String[]]
        $VMNAME,
        [Parameter(Mandatory = $true, HelpMessage = 'The path your virtual machines are stored in,')]
        [String[]]
        $virtualMachineDir
    )
    Try {
        Write-Verbose -Message 'Removing VM'
        Remove-VM -Name $VMNAME -Force -ErrorAction $ErrorActionPreference -ErrorVariable rmVMerr -Verbose
    } Catch {
        Write-Output -InputObject 'VM Removed.' -ErrorAction $ErrorActionPreference
    }
    Try {
        Write-Verbose -Message 'Removing VM Directory'
        Remove-item -Path ($virtualMachineDir + $vmname) -Recurse -Force -Verbose -ErrorAction $ErrorActionPreference -ErrorVariable rmDirErr
    } Catch {
        Write-Output -InputObject 'Dir Removed' -ErrorAction $ErrorActionPreference
    }
}#End Function DeleteVM
function readonlyVHDX {
    [CmdletBinding(SupportsShouldProcess = $true)]
    #!Only needed once
    #TODO: Move Params function readonlyVHDX
    #TODO: Document function readonlyVHDX
    #TODO: Error Handling function readonlyVHDX

    #!Hardcoded
    $templatePath = 'C:\VHD\Templates\DEV-SERVER2016-N01.vhdx'

    #Set File Read-Only
    Set-ItemProperty -Path $templatePath -Name IsReadOnly -Value $true -Verbose
    #-ErrorAction $ErrorActionPreference -ErrorVariable setVHDXReadOnlyErr

}#End function readonlyVHDX
