#Generates a .csv of capacity, provisioned space and Available space
# Negative space is overprovisioning

$report = @()

foreach($cluster in Get-Cluster)
{
    Get-VMHost -Location $cluster | Get-Datastore | %{
        $info = "" | select DataCenter, Cluster, Name, Capacity, Provisioned, Available 
        $info.Datacenter = $_.Datacenter
        $info.Cluster = $cluster.Name
        $info.Name = $_.Name 
        $info.Capacity = [math]::Round($_.capacityMB/1024,2) 
        $info.Provisioned = [math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2) 
        $info.Available = [math]::Round($info.Capacity - $info.Provisioned,2) 
        $report += $info
    }
}

$report | Export-Csv "C:\temp\cluster-ds.csv" -NoTypeInformation -UseCulture


#Get the names of VMs with connected CD drives:
get-vm | where { $_ | get-cddrive | where { $_.ConnectionState.Connected -eq "true" } } | select Name

#Get the names of VMs with connected .ISOs
get-vm | where { $_ | get-cddrive | where { $_.ConnectionState.Connected -eq "true" -and $_.ISOPath -like "*.ISO*"} } | select Name, @{Name=".ISO Path";Expression={(Get-CDDrive $_).isopath }}

#Disconnect all VMs where the CD Drive is connected and it is not an .ISO
$VMs = Get-VM
$CDConnected = Get-CDDrive $VMs | where { ($_.ConnectionState.Connected -eq "true") -and ($_.ISOPath -notlike "*.ISO*")}
If ($CDConnected -ne $null) {Set-CDDrive -connected 0 -StartConnected 0 $CDConnected -Confirm:$false }


#To Disconnect CD Drives, loop
foreach ($cds in $CDConnected)
{
	Set-CDDrive -NoMedia -Confirm:$False
}