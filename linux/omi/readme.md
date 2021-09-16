# OMI Patching on Azure Linux VMs

The following PowerShell script will enumearte against all subscriptions you have access to and all Azure Linux VMs where Log Analytics was installed by VM Extension. 
It will use Custom Script Extension per VM found and push a bash script to the VM to add MSRepo and Install the lastest OMI. 

[OMI VM CSE Deploy PowerShell Script](https://github.com/swiftsolves-msft/patch4cse/blob/main/linux/omi/OMIVMCSEDeploy.ps1)

*Warning this script as is and has not been thoroughly tested.

On line 8 of PS script you can modify and add -ResourceGroupName rgSwiftFileServers withint the (Get-AzResource ) to limit impact of testing

On line 19 starts the switch to handle differnt Linux OS and Versions of OS, if your Linux OS or Version is not found you can fork or git clone this repo
and work off what you need by using the examples provided.
