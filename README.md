Azure - Count VHDs Per Storage Account
======================================


  *  Customers may experience Azure IaaS VM performance issues if too many OS and/or data disk VHD files are stored in each Storage Account

  *  Storage Accounts are limited to **20,000 IOPS** 
  *  We expect each disk to experience up to **500 IOPS** 
  *  We can determine approximately how many OS and data disk VHD files, as a maximum number, should reside in each storage account

  *  20,000 IOPS / 500 per-disk IOPS = **40 VHDs max per Storage Account**

  *  This is detailed here: http://azure.microsoft.com/en-us/documentation/articles/azure-subscription-service-limits/#storagelimits



 


  *  The purpose of this sample script is to easily display a count of VHDs per Storage Account for a given Azure subscription

  *  This sample counts all VHD files in each Storage Account, regardless of whether or not the VHD files are currently attached as a OS disk or data disk to a Azure VM object

  *  If the results of this script show that VHDs should be copied to another Storage Account, see the following script sample:

  *  [http://gallery.technet.microsoft.com/Azure-Virtual-Machine-Copy-1041199c](http://gallery.technet.microsoft.com/Azure-Virtual-Machine-Copy-1041199c)



 


 


 

 

        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
