# MATLAB on Microsoft Azure (Windows VM)


## Prerequisites

To deploy this reference architecture, you must have the following permissions that allow you to create and assign Azure&reg; roles in your subscription:

1. `Microsoft.Authorization/roleDefinitions/write`
2. `Microsoft.Authorization/roleAssignments/write`

To check if you have these permissions for your Azure subscription, follow the steps mentioned in [Check access for a user to Azure resources](https://learn.microsoft.com/en-us/azure/role-based-access-control/check-access).

If you do not have these permissions, you can obtain them in two ways:

1. The built-in Azure role [User Access Administrator](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#user-access-administrator) contains the above-mentioned permissions. Administrators or Owners of the subscription can directly assign you this role in addition to your existing role. To assign roles using the Azure portal, see [Assign Azure roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal).

2. The Azure account administrator or Owner can also create a custom role containing these permissions and attach it along with your existing role. To create custom roles using the Azure portal, see [Create Custom roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles-portal).

To get a list of Owners in your subscription, see [List Owners of a Subscription](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-portal#list-owners-of-a-subscription).

## Step 1. Launch the Template

Click the **Deploy to Azure** button below to deploy the cloud resources on Azure. This will open the Azure Portal in your web browser.

| Create Virtual Network | Use Existing Virtual Network |
| --- | --- |
| Use this option to deploy the resources in a new virtual network<br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure-win%2Fmaster%2Freleases%2FR2022b%2Fazuredeploy-R2022b.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> | Use this option to deploy the resources in an existing virtual network <br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure-win%2Fmaster%2Freleases%2FR2022b%2Fazuredeploy-existing-vnet-R2022b.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> |

> VM Platform: Windows Server 2022 (R2023a and later), Windows Server 2019 (R2022b and earlier)

> MATLAB&reg; Release: R2022b

To deploy a custom machine image, see [Deploy Your Own Machine Image](#deploy-your-own-machine-image).

## Step 2. Configure the Cloud Resources

> **Note:** To deploy the resource group, you must have permissions to create Azure roles and assign them to resources in your subscription.

Clicking the **Deploy to Azure** button opens the "Custom deployment" page in your browser. You can configure the parameters on this page. It is easier to complete the steps if you position these instructions and the Azure Portal window side by side. Create a new resource group by clicking **Create New**. Alternatively, you can select an existing resource group, but this can cause conflicts if resources are already deployed in it.

1. Specify and check the defaults for these resource parameters:

| Parameter label | Description |
| --------------- | ----------- |
| **Vm Size** | The Azure instance type to use for this VM. See [Azure virtual machines](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes) for a list of instance types. |
| **Client IP Addresses** | IP address range that can be used to access the VM. This must be a valid IP CIDR range of the form x.x.x.x/x. Use the value &lt;your_public_ip_address&gt;/32 to restrict access to only your computer. |
| **Admin Username** | Admin username for this virtual machine. To avoid any deployment errors, please check the list of [disallowed values](https://docs.microsoft.com/en-us/rest/api/compute/virtual-machines/create-or-update?tabs=HTTP#osprofile) for adminUsername. |
| **Admin Password** | Choose the password for the admin username. This password is required when logging in remotely to the instance. For the deployment to succeed, your password must meet [Azure's password requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm-). |
| **Virtual Network Resource ID** | Resource ID of an existing virtual network to deploy your VM into. You can find this under the Properties of your virtual network. Specify this parameter only when deploying with the Existing Virtual Network option. |
| **Subnet Name** | Name of an existing subnet within your virtual network to deploy your VM into. Specify this parameter only when deploying with the Existing Virtual Network option. |
| **Auto Shutdown** | Select the duration after which the VM should be automatically shut down post launch. |
| **Enable NICE DCV** | Choose whether to create a [NICE DCV](https://aws.amazon.com/hpc/dcv/) connection to this VM. If you select 'Yes', NICE DCV will be configured with a 30 days trial license (unless a production license is provided). You can access the desktop on a browser using the NICE DCV connection URL in the Outputs section of the deployment page once the resource group is successfully deployed. By using NICE DCV, you agree to the terms and conditions outlined in the [NICE DCV End User License Agreement](https://www.nice-dcv.com/eula.html). If you select 'No', then, NICE DCV will not be installed in the VM and you can connect to the VM using a remote desktop connection (RDP). |
| **NICE DCV License Server** | If you have opted to enable NICE DCV and have a production license, use this optional parameter to specify the NICE DCV license server's port and hostname (or IP address) in the form of port@hostname. This field must be left blank if you have opted not to enable NICE DCV or want to use NICE DCV with a trial license. |
| **MATLAB License Server** | Optional License Manager for MATLAB, specified as a string in the form port@hostname. If not specified, online licensing is used. If specified, the license manager must be accessible from the specified virtual network and subnets. For more information, see https://github.com/mathworks-ref-arch/license-manager-for-matlab-on-azure. |
| **Logging** | Choose whether you want to enable [Azure monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-sources-custom-logs) logging for the MATLAB instance. To see the logs, go to the log workspace in your resource group and click on Logs. You can also view the logs in your virtual machine Logs section. |
| **Optional User Command** | Provide an optional inline PowerShell command to run on machine launch. For example, to set an environment variable CLOUD=AZURE, use this command excluding the angle brackets: &lt;[System.Environment]::SetEnvironmentVariable("CLOUD","AZURE", "Machine");&gt;. You can use either double quotes or two single quotes. To run an external script, use this command excluding the angle brackets: &lt;Invoke-WebRequest "https://www.example.com/script.ps1" -OutFile script.ps1; .\script.ps1&gt;. Find the logs at '$Env:ProgramData\MathWorks\startup.log'. |


2. Click the **Review + create** button.

3. Review the Azure Marketplace terms and conditions and click the **Create** button.

## Step 3. Connect to the Virtual Machine in the Cloud

>   **Note:** Complete these steps only after your resource group has been successfully created.

1.  In the Azure Portal, on the navigation panel on the left, click **Resource
    groups**. This will display all your resource groups.

2.  Select the resource group you created for this deployment from the list. This
    will display the Azure blade of the selected resource group with its own
    navigation panel on the left.

3.  Select the resource labeled **matlab-publicIP**. This resource
    contains the public IP address to the virtual machine that is running MATLAB.

4.  Copy the IP address from the IP address field.

5.  Launch any remote desktop client, paste the IP address in the appropriate field, and connect. On the Windows Remote Desktop Client you need to paste the IP address in the **Computer** field and click **Connect**.

6.  If you enabled NICE DCV during deployment, you can access the virtual machine's desktop via the url `https://<public-ip-of-vm>:8443`.

7. In the login screen, use the username and the password you specified while configuring cloud resources in [Step 2](#step-2-configure-cloud-resources).

## Step 4. Start MATLAB

Double-click the MATLAB icon on the virtual machine desktop to start MATLAB. The first time you start MATLAB, you need to enter your MathWorks&reg; Account credentials to license MATLAB. For other ways to license MATLAB, see [MATLAB Licensing in the Cloud](https://www.mathworks.com/help/install/license/licensing-for-mathworks-products-running-on-the-cloud.html). 

>**Note**: It may take up to a minute for MATLAB to start the first time.

# Deploy Your Own Machine Image
For details of the scripts which form the basis of the MathWorks Windows Virtual Hard Disk (VHD) build process,
see [Build Your Own Machine Image](https://github.com/mathworks-ref-arch/matlab-on-azure-win/blob/main/packer/v1/README.md).
You can use these scripts to build your own custom Windows machine image for running MATLAB on Azure.
You can then deploy this custom image with the following MathWorks infrastructure as code (IaC) templates.
| Create Virtual Network for Custom Image | Use Existing Virtual Network for Custom Image|
| --- | --- |
| Use this option to deploy the custom image and other resources in a new virtual network<br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure-win%2Fmaster%2Freleases%2FR2022b%2Fazuredeploy-R2022b-test.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> | Use this option to deploy the custom image and other resources in an existing virtual network <br><br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure-win%2Fmaster%2Freleases%2FR2022b%2Fazuredeploy-existing-vnet-R2022b-test.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a></br></br> |

To launch a custom image, the following fields are required by these templates.
| Argument Name | Description |
|---|---|
|`Custom VHD`                 | URL of custom VHD. This is the `artifact_id` listed in the `manifest.json`. |
|`Custom VHD Storage Account` | Storage account that contains the custom VHD. This is the storage account that was specified in the Packer build using the `STORAGE_ACCOUNT` parameter. |
|`Custom VHD Resource Group`  | Resource group that contains the custom VHD. This is the resource group that was specified in the Packer build using the `RESOURCE_GROUP_NAME` parameter. |

# Additional Information

## Delete Your Resource Group
You can remove the Resource Group and all associated resources when you are done with them. Note that you cannot recover resources once they are deleted.

1.  Login to the Azure Portal.
2.  Select the resource group containing your resources.
3.  Select the **Delete resource group** icon to destroy all resources deployed
    in this group.
4.  You will be prompted to enter the name of the resource group to confirm the
    deletion.

## Troubleshooting
If your resource group fails to deploy, check the Deployments section of the Resource Group. It will indicate which resource deployments failed and allow you to navigate to the causing error message.

----

Copyright 2020-2024 The MathWorks, Inc.

----