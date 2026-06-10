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

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathworks-ref-arch%2Fmatlab-on-azure-win%2Fmaster%2Freleases%2FR2026a%2Fazuredeploy-R2026a.json" target="_blank"><img src="https://aka.ms/deploytoazurebutton"/></a>

> VM Platform: Windows Server 2025 (R2026a and later), Windows Server 2022 (R2022b - R2025b), Windows Server 2019 (R2022a and earlier)

> MATLAB&reg; Release: R2026a

To deploy a custom machine image, see [Deploy Your Own Machine Image](#deploy-your-own-machine-image).

## Step 2. Configure the Cloud Resources

> **Note:** To deploy the resource group, you must have permissions to create Azure roles and assign them to resources in your subscription.

Clicking the **Deploy to Azure** button opens the "Custom deployment" page in your browser. You can configure the parameters on this page. It is easier to complete the steps if you position these instructions and the Azure Portal window side by side. Create a new resource group by clicking **Create New**. Alternatively, you can select an existing resource group, but this can cause conflicts if resources are already deployed in it.

1. Specify and check the defaults for these resource parameters:

| Parameter label | Description |
| --------------- | ----------- |
| **Vm Size** | The Azure instance type to use for this VM. See [Azure virtual machines](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes) for a list of instance types. |
| **Create Public IP Address** | Choose whether to attach a public IP address to the MATLAB VM. For details about using a private network configuration, see [Configure Private Network](#configure-private-network). |
| **Client IP Addresses** | Comma-separated list of IPv4 address ranges that can connect to the MATLAB VM. Each IP CIDR must have the format \<ip_address>/\<mask>. The mask determines the number of IP addresses to include. A mask of 32 specifies a single IP address. Examples of allowed values: 10.0.0.1/32 or 10.0.0.0/16,192.34.56.78/32. To build a specific range, you can use this tool: https://www.ipaddressguide.com/cidr. To determine which address is appropriate, contact your IT administrator. |
| **Admin Username** | Admin username for this virtual machine. To avoid any deployment errors, please check the list of [disallowed values](https://docs.microsoft.com/en-us/rest/api/compute/virtual-machines/create-or-update?tabs=HTTP#osprofile) for adminUsername. |
| **Admin Password** | Choose the password for the admin username. You need this password to log in remotely to the instance.  If you enabled the setting to access MATLAB in a browser, you need to enter this password as an authentication token. Your password must meet the [Azure password requirements](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm-). |
| **Virtual Network Resource ID** | (Optional) The Resource ID of an existing virtual network to deploy your VM into. You can find this under the Properties of your virtual network. If left empty, a new virtual network with a default subnet will be created. |
| **Subnet Name** | (Optional) The name of an existing subnet within your chosen virtual network to deploy your VM into. Required if a Virtual Network Resource ID is specified. |
| **New Vnet Address Space** | (Optional) Address space to use for the new Virtual Network that the template creates, effective only if not using an existing virtual network. |
| **New Subnet Address Space** | (Optional) Address space of the default subnet in the new Virtual Network that the template creates, effective only if not using an existing virtual network. This address range must be a subset of the address space defined for the new virtual network. |
| **Auto Shutdown** | Select the duration after which the VM should be automatically shut down post launch. |
| **Enable MATLAB Proxy** | Use this setting to access MATLAB in a browser on your cloud instance. Note that the MATLAB session in your browser is different from one you start from the desktop in your Remote Desktop Protocol (RDP) or NICE DCV session. |
| **Enable NICE DCV** | Choose whether to create a [NICE DCV](https://aws.amazon.com/hpc/dcv/) connection to this VM. If you select 'Yes', NICE DCV will be configured with a 30 days trial license (unless a production license is provided). You can access the desktop on a browser using the NICE DCV connection URL in the Outputs section of the deployment page once the resource group is successfully deployed. By using NICE DCV, you agree to the terms and conditions outlined in the [NICE DCV End User License Agreement](https://www.nice-dcv.com/eula.html). If you select 'No', then, NICE DCV will not be installed in the VM and you can connect to the VM using a remote desktop connection (RDP). |
| **NICE DCV License Server** | If you have opted to enable NICE DCV and have a production license, use this optional parameter to specify the NICE DCV license server's port and hostname (or IP address) in the form of port@hostname. This field must be left blank if you have opted not to enable NICE DCV or want to use NICE DCV with a trial license. |
| **MATLAB License Server** | Optional License Manager Server for MATLAB, specified as a string in the form \<port>@\<license-manager-hostname> or \<port>@\<license-manager-ip-address> (for example: 27000@netlm-server or 27000@10.0.0.4). Ensure that the MATLAB VM can reach or resolve the license manager's IP or hostname. If you do not provide this string, MATLAB uses online licensing. For more information, see [Network License Manager for MATLAB on Microsoft Azure](https://github.com/mathworks-ref-arch/license-manager-for-matlab-on-azure). |
| **Logging** | Choose whether you want to enable [Azure monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-sources-custom-logs) logging for the MATLAB instance. To see the logs, go to the log workspace in your resource group and click on Logs. You can also view the logs in your virtual machine Logs section. |
| **Optional User Command** | Provide an optional inline PowerShell command to run on machine launch. For example, to set an environment variable CLOUD=AZURE, use this command excluding the angle brackets: &lt;[System.Environment]::SetEnvironmentVariable("CLOUD","AZURE", "Machine");&gt;. You can use either double quotes or two single quotes. To run an external script, use this command excluding the angle brackets: &lt;Invoke-WebRequest "https://www.example.com/script.ps1" -OutFile script.ps1; .\script.ps1&gt;. Find the logs at '$Env:ProgramData\MathWorks\startup.log'. |
| **Image ID** | Optional Resource ID of a custom managed image in the target region. To use a prebuilt MathWorks image instead, leave this field empty. If you customize the build, for example by removing or modifying the included scripts, this can make the image incompatible with the provided ARM template. To ensure compatibility, modify the ARM template or image accordingly. |


2. Click the **Review + create** button.

3. Review the Azure Marketplace terms and conditions and click the **Create** button.

If you use a network license manager, deploy the resources into a subnet within the same or peered virtual network as the network license manager to ensure that your VM can access the port and hostname (or IP address) of the network license manager. If your network license manager is on a peered network, use the Private IPv4 address of the network license manager instead of the hostname to avoid name resolution issues.

## Step 3. Connect to the Virtual Machine in the Cloud

>   **Note:** Complete these steps only after your resource group has been successfully created.

1.  In the Azure Portal, on the navigation panel on the left, click **Resource
    groups**. This will display all your resource groups.

2.  Select the resource group you created for this deployment from the list. This
    will display the Azure blade of the selected resource group with its own
    navigation panel on the left.

3.  If you enabled a Public IP address during deployment, select the resource labeled **matlab-publicIP**. 
    This resource contains the public IP address of the MATLAB virtual machine. Otherwise, 
    you must use the private IP address of the MATLAB virtual machine to connect to it.

4.  Launch any remote desktop client, paste the IP address in the appropriate field, and connect. On the Windows Remote Desktop Client, you must paste the IP address in the **Computer** field, and click **Connect**.

5. If you enabled NICE DCV during deployment, you can access the virtual machine desktop using the URL `https://<public-ip-of-vm>:8443`. For a private VM, use the URL `https://<private-ip-of-vm>:8443`. You can also access the desktop using the NICE DCV Client. In the login screen, use the username and password you specified while configuring cloud resources in [Step 2](#step-2-configure-cloud-resources).

6. If you enabled the setting to access MATLAB in your browser, you can access the desktop on your virtual machine using the URL `https://<public-ip-of-vm>:8123`. For a private VM, use the URL `https://<private-ip-of-vm>:8123`. For the `auth token`, use the password you specified during deployment. Access to MATLAB in a browser is enabled through `matlab-proxy`, a Python&reg; package developed by MathWorks&reg;. For details, see [MATLAB Proxy (Github)](https://github.com/mathworks/matlab-proxy).

## Step 4. Start MATLAB

To start MATLAB, double click the MATLAB icon on the desktop in your virtual machine. The first time you start MATLAB, you need to enter your MathWorks Account credentials. For more information about licensing MATLAB, see [MATLAB Licensing in the Cloud](https://www.mathworks.com/help/install/license/licensing-for-mathworks-products-running-on-the-cloud.html). 

>**Note**: It may take up to a minute for MATLAB to start the first time.

# Deploy Your Own Machine Image
For details of the scripts which form the basis of the MathWorks Windows managed image build process,
see [Build Your Own Machine Image](https://github.com/mathworks-ref-arch/matlab-on-azure-win/blob/main/packer/v1/README.md).
You can use these scripts to build your own custom Windows machine image for running MATLAB on Azure.
You can then deploy this custom image with the above MathWorks infrastructure as code (IaC) templates.
To launch a custom image, the following fields are required by the templates.
| Argument Name | Description |
|---|---|
|`Image ID` | Resource ID of the custom managed image. This is the `artifact_id` listed in the `manifest.json`. |

# Additional Information

## Configure Private Network

To deploy the MATLAB VM without a public IPv4 address, set the `createPublicIPAddress` parameter to `No`. Ensure to meet these requirements before deploying the template in a private network configuration.

### Client Access
Without a public IP address, you cannot access the MATLAB VM directly from the internet. Use one of these methods to connect to your VM. 

- Azure Bastion: Provides secure RDP/SSH access through the Azure portal.
- Jumpbox Virtual Machines: An intermediate layer between your machine and the MATLAB VM. Deploy a jumpbox VM in the same virtual network or peered network as the MATLAB VM. Log in to the jumpbox and then connect to the MATLAB VM using its private IP address.
- VPN Gateway or ExpressRoute: Establishes a private, secure tunnel between your local on-premises network and your Azure Virtual Network. This allows you to connect to the MATLAB VM using its private IP address.

Use the `clientIPAddresses` parameter to specify the private IPv4 addresses of the existing jumpbox or client(s) that will access the MATLAB VM. 

For details about Azure bastion and jumpboxes, see the Azure documentation on [Overview of Azure Bastion host and jumpboxes](https://learn.microsoft.com/azure/cloud-adoption-framework/scenarios/cloud-scale-analytics/architectures/connect-to-environments-privately#overview-of-azure-bastion-host-and-jumpboxes). For details about VPN Gateway, see [What is Azure ExpressRoute?](https://learn.microsoft.com/azure/expressroute/expressroute-introduction).

### Licensing MATLAB
To use online licensing for MATLAB, the MATLAB virtual machine must be able to access domains at `*.mathworks.com` over the internet. If you deploy the MATLAB VM in an existing virtual network, ensure that outbound access to these domains is allowed.

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

Copyright 2020-2026 The MathWorks, Inc.

----