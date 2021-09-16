# Created On: 9/16/2021 3:35 PM
# Created By: Nathan Swift - nathan.swift@swiftsolves.com
# This script is as is and not supported by Microsoft 
# Microsoft does not assume any risk of data loss
# Use it at your own risk
################################################################################

<#  Links
 
https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-38647
https://github.com/microsoft/omi
https://twitter.com/yuridiogenes/status/1438162235013091330
https://beta.shodan.io/search/report?query=port%3A5986+ssl%3A%22cloudapp.azure.com%22
https://www.greynoise.io/viz/query/?gnql=tags%3A%22Azure%20OMI%20RCE%20Attempt%22
https://docs.microsoft.com/en-us/azure/automation/update-management/overview
https://docs.microsoft.com/en-us/powershell/module/az.resources/new-azresourcegroupdeployment?view=azps-6.4.0
https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux#troubleshooting

Repo:
https://docs.microsoft.com/en-us/windows-server/administration/Linux-Package-Repository-for-Microsoft-Software#configuring-the-repositories

#>

# Get all Azure Subscriptions
$subs = Get-AzSubscription

# For each subscription execute to find and install omi patch on linux vms with Log analytics agent installed by Extension
foreach ($sub in $subs) {

    # Set Azure Subscription context    
    Set-AzContext -Subscription $sub.Id

    # Get all VMs in subscription that have the Linux OMS Agent installed via VM Extension
    $VMs = (Get-AzResource -ResourceType Microsoft.Compute/virtualMachines/extensions).Id | Select-String -SimpleMatch "/OmsAgentForLinux"

    # For each VM in list
    foreach($VM in $VMs) {
    
        # Set variables to be used across the deployment
        $VM = $VM.ToString()
        $RGNAME = $VM.Split('/')[4]
        $VMNAME = $VM.Split('/')[8]
        $VMDetail = Get-AzVM -ResourceGroupName $RGNAME -Name $VMNAME
        $VMIMAGE = $VMDetail.StorageProfile.ImageReference
        $datetime = Get-Date -Format "yyyyMMdd"

        # Switch the bash script to use based on the VM details of the Azure image
        switch ($VMIMAGE) {
        
            #"canonical" {$}
            {($_.Publisher -eq 'Canonical') -and ($_.Sku -eq '20.04-LTS')} {$vmver = "ubu20.04cse.sh"}
            {($_.Publisher -eq 'Canonical') -and ($_.Sku -eq '18.04-LTS')} {$vmver = "ubu18.04cse.sh"}
            {($_.Publisher -eq 'Canonical') -and ($_.Sku -eq '16.04-LTS')} {$vmver = "ubu16.04cse.sh"}
            # Add more versions here use $VMDetail to discover others
        
            #"rhel" {$}
            #{($_.Publisher -eq '???') -and ($_.Sku -eq '???')} {$vmver = "rhel8cse.sh"}
            #{($_.Publisher -eq '???') -and ($_.Sku -eq '???')} {$vmver = "rhel7cse.sh"}
            #{($_.Publisher -eq '???') -and ($_.Sku -eq '???')} {$vmver = "rhel6cse.sh"}

            #"sles" {$}
            #{($_.Publisher -eq '???') -and ($_.Sku -eq '???')} {$vmver = "sles7cse.sh"}
            #{($_.Publisher -eq '???') -and ($_.Sku -eq '???')} {$vmver = "sles6cse.sh"}

            #"debian" {$}
            #{($_.Publisher -eq '???') -and ($_.Sku -eq '???')} {$vmver = "debian10cse.sh"}

            Default {$vmver = "Unable to determine the VM OS and Version"}
        }

        #build varibale for cmd to run and base fileuris to grab bash script
        $cmdtorun = "sudo sh " + $vmver
        $uri = "https://raw.githubusercontent.com/swiftsolves-msft/patch4cse/main/linux/omi/" + $vmver
        [array]$fileuris = $uri

        $csename = "OMICSEPatch_" + $vmver

        # Az Deployment name can only be 64 characters maybe make it a New-GUID as name
        $AzDeployName = $VMNAME + $csename # + $datetime

        #New-AzDeployment -Name $AzDeployName -Location $VMDetail.location -TemplateUri "https://raw.githubusercontent.com/swiftsolves-msft/patch4cse/main/azuredeploy.json" -extensionName $csename -vmName $VMNAME -fileUris $uri -commandToExecute $cmdtorun -isWindowsOS $false -vmlocation $VMDetail.location
        New-AzResourceGroupDeployment -Name $AzDeployName -ResourceGroupName $RGNAME -TemplateUri "https://raw.githubusercontent.com/swiftsolves-msft/patch4cse/main/azuredeploy.json" -extensionName $csename -vmName $VMNAME -fileUris $fileuris -commandToExecute $cmdtorun -isWindowsOS $false -vmlocation $VMDetail.location

    }

}