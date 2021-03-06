#------------------------------------------------------------------------------
#
# Copyright © 2014 Microsoft Corporation.  All rights reserved.
#
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR 
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
#------------------------------------------------------------------------------
#
# PowerShell Source Code
#
# NAME:
#    AzureStorageVhdCount.ps1
#
# VERSION:
#    1.0
#
#------------------------------------------------------------------------------

#set thresholds for warning
[int] $MaxCount = 40
[int] $WarnCount = 35
[int] $TotalDiskCount = 0

#get azure sub details
Get-AzureSubscription | Remove-AzureSubscription -Force
Add-AzureAccount
Get-AzureSubscription | Select-AzureSubscription
$SubscriptionName = (Get-AzureSubscription).SubscriptionName

#get all storage accounts
$AllStorageAccounts = Get-AzureStorageAccount

Write-Host "`n ##############################" -ForegroundColor White
Write-Host ("`n List of disks per Storage Account:").ToUpper() -ForegroundColor White

#loop through each storage account
ForEach ($StorageAccount in $AllStorageAccounts)
{
	Set-AzureSubscription -SubscriptionName $SubscriptionName -CurrentStorageAccountName $StorageAccount.StorageAccountName
	Write-Host "`n Storage Account: " $StorageAccount.StorageAccountName.ToUpper() -ForegroundColor White -BackgroundColor Blue
	$StorageAccountDiskCount = New-Object PSObject
	$DiskCount = 0
	
	#get all containers for this storage account
	$AllContainers = Get-AzureStorageContainer
	
	#loop through all containers in this storage account
	ForEach ($Container in $AllContainers)
	{
		$CurrentContainer = $Container.Name
		
		#get all blobs in this container
		$AllBlobs = Get-AzureStorageBlob -Container $CurrentContainer
		
		#loop through each blob in this container
		ForEach ($Blob in $AllBlobs)
		{	
			$BlobName = $Blob.Name
			$BlobType = $Blob.BlobType
			
			#we only count vhds
			If ($BlobName -like '*.vhd' -and $BlobType -eq "PageBlob")
			{
				$DiskCount++
				$TotalDiskCount++
				Write-Host " $BlobName"
			}
		}
	}
	
	#build custom object for reporting at the end
	Add-Member -InputObject $StorageAccountDiskCount -MemberType NoteProperty -Name "StorageAccountName" -Value $StorageAccount.StorageAccountName
	Add-Member -InputObject $StorageAccountDiskCount -MemberType NoteProperty -Name "DiskCount" -Value $DiskCount
	
	#show warnings if counts are high
	If ($DiskCount -gt $MaxCount)
	{
		Write-Host "`n Disk count: $DiskCount (Exceeds maximum recommended disk count per storage account)" -ForegroundColor Red
	}
	ElseIf (($DiskCount -ge $WarnCount) -and ($DiskCount -le $MaxCount))
	{
		Write-Host "`n Disk count: $DiskCount (Approaches maximum recommended disk count per storage account)" -ForegroundColor Yellow
	}
	Else
	{
		Write-Host "`n Disk count: $DiskCount" -ForegroundColor Green
	}
	
	[array]$DiskCountPerStorageAccount += $StorageAccountDiskCount
}

Write-Host "`n ##############################" -ForegroundColor White
Write-Host ("`n Disks per Storage Account:").ToUpper() -ForegroundColor White

#loop for reporting
ForEach ($Item in $DiskCountPerStorageAccount)
{

	$ItemSAName = $Item.StorageAccountName
	$ItemDiskCount = $Item.DiskCount
	
	#show warnings if counts are high
	If ($ItemDiskCount -gt $MaxCount)
	{
		Write-Host "`n ${ItemSAName}: $ItemDiskCount (exceeds maximum recommended disk count per storage account!)" -ForegroundColor Red
	}
	ElseIf (($ItemDiskCount -ge $WarnCount) -and ($ItemDiskCount -le $MaxCount))
	{
		Write-Host "`n ${ItemSAName}: $ItemDiskCount (equals maximum recommended disk count per storage account!)" -ForegroundColor Yellow
	}
	Else
	{
		Write-Host "`n ${ItemSAName}: $ItemDiskCount" -ForegroundColor Green
	}
}

Write-Host "`n ##############################" -ForegroundColor White
Write-Host "`n TOTAL DISKS FOUND:`t$TotalDiskCount"
Write-Host "`n ##############################`n`n" -ForegroundColor White