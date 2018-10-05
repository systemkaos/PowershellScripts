#NOTE: Empties Recycle bins across a host
Function Global:Clear-RecycleBin {
  <#
      .SYNOPSIS
      PowerShell function to list and delete old files in Recycle Bin
      .DESCRIPTION
      Includes -Delete parameter to remove old files.
      .EXAMPLE
      Clear-RecycleBin -Days 30
      Clear-RecycleBin -Days 7 -Remove
      #>
      [cmdletbinding()]
        Param (
        [parameter(Mandatory=$false)]$Days=10,
        [parameter(Mandatory=$false)][Switch]$Remove
      )
      Begin {
      Clear-Host
      $x=0
            } # End of small begin section
            
      Process {
        $Shell= New-Object -ComObject Shell.Application
        $Bin = $Shell.NameSpace(10)
        $Now = (Get-Date) -(New-TimeSpan -Days $Days)
        ForEach($Item in $Bin.Items()) 
          {
        If($Now -gt $Item.ModifyDate) {
          "{0,-22} {1,-20} {2,-20}" -f $Item.ModifyDate, $Item.Name, $Item.Path
          $x++
        }
      
        If($Remove){
          If($Now -gt $Item.ModifyDate) {
            "{0,-22} {1,-20} {2,-20}" -f $Item.ModifyDate, $Item.Name, $Item.Path
            $x++
            $Item | Remove-Item -Force
                     }
                   }
            }
          }
          
      End {
      "`n Detected $x files older than $Days days"
      "`n Removed = $Remove "
         }
} 
