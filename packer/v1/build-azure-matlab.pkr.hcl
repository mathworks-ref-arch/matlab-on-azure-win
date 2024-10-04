# Copyright 2024 The MathWorks, Inc.

# The following variables may have different values across MATLAB releases.
# MathWorks recommends that you modify them via the configuration file specific to each release.
# To see the release-specific values, open the configuration file
# in the /packer/v1/release-config/ folder.
variable "PRODUCTS" {
  type        = string
  default     = "5G_Toolbox AUTOSAR_Blockset Aerospace_Blockset Aerospace_Toolbox Antenna_Toolbox Audio_Toolbox Automated_Driving_Toolbox Bioinformatics_Toolbox Bluetooth_Toolbox C2000_Microcontroller_Blockset Communications_Toolbox Computer_Vision_Toolbox Control_System_Toolbox Curve_Fitting_Toolbox DDS_Blockset DSP_HDL_Toolbox DSP_System_Toolbox Data_Acquisition_Toolbox Database_Toolbox Datafeed_Toolbox Deep_Learning_HDL_Toolbox Deep_Learning_Toolbox Econometrics_Toolbox Embedded_Coder Filter_Design_HDL_Coder Financial_Instruments_Toolbox Financial_Toolbox Fixed-Point_Designer Fuzzy_Logic_Toolbox GPU_Coder Global_Optimization_Toolbox HDL_Coder HDL_Verifier Image_Acquisition_Toolbox Image_Processing_Toolbox Industrial_Communication_Toolbox Instrument_Control_Toolbox LTE_Toolbox Lidar_Toolbox MATLAB MATLAB_Coder MATLAB_Compiler MATLAB_Compiler_SDK MATLAB_Production_Server MATLAB_Report_Generator MATLAB_Test MATLAB_Web_App_Server Mapping_Toolbox Medical_Imaging_Toolbox Mixed-Signal_Blockset Model_Predictive_Control_Toolbox Model-Based_Calibration_Toolbox Motor_Control_Blockset Navigation_Toolbox Optimization_Toolbox Parallel_Computing_Toolbox Partial_Differential_Equation_Toolbox Phased_Array_System_Toolbox Powertrain_Blockset Predictive_Maintenance_Toolbox RF_Blockset RF_PCB_Toolbox RF_Toolbox ROS_Toolbox Radar_Toolbox Reinforcement_Learning_Toolbox Requirements_Toolbox Risk_Management_Toolbox Robotics_System_Toolbox Robust_Control_Toolbox Satellite_Communications_Toolbox Sensor_Fusion_and_Tracking_Toolbox SerDes_Toolbox Signal_Integrity_Toolbox Signal_Processing_Toolbox SimBiology SimEvents Simscape Simscape_Battery Simscape_Driveline Simscape_Electrical Simscape_Fluids Simscape_Multibody Simulink Simulink_3D_Animation Simulink_Check Simulink_Coder Simulink_Compiler Simulink_Control_Design Simulink_Coverage Simulink_Design_Optimization Simulink_Design_Verifier Simulink_Desktop_Real-Time Simulink_Fault_Analyzer Simulink_PLC_Coder Simulink_Real-Time Simulink_Report_Generator Simulink_Test SoC_Blockset Spreadsheet_Link Stateflow Statistics_and_Machine_Learning_Toolbox Symbolic_Math_Toolbox System_Composer System_Identification_Toolbox Text_Analytics_Toolbox UAV_Toolbox Vehicle_Dynamics_Blockset Vehicle_Network_Toolbox Vision_HDL_Toolbox WLAN_Toolbox Wavelet_Toolbox Wireless_HDL_Toolbox Wireless_Testbench"
  description = "Target products to install in the machine image, e.g. MATLAB SIMULINK."
}

variable "SPKGS" {
  type        = string
  default     = "Deep_Learning_Toolbox_Model_for_AlexNet_Network Deep_Learning_Toolbox_Model_for_EfficientNet-b0_Network Deep_Learning_Toolbox_Model_for_GoogLeNet_Network Deep_Learning_Toolbox_Model_for_ResNet-101_Network Deep_Learning_Toolbox_Model_for_ResNet-18_Network Deep_Learning_Toolbox_Model_for_ResNet-50_Network Deep_Learning_Toolbox_Model_for_Inception-ResNet-v2_Network Deep_Learning_Toolbox_Model_for_Inception-v3_Network Deep_Learning_Toolbox_Model_for_DenseNet-201_Network Deep_Learning_Toolbox_Model_for_Xception_Network Deep_Learning_Toolbox_Model_for_MobileNet-v2_Network Deep_Learning_Toolbox_Model_for_Places365-GoogLeNet_Network Deep_Learning_Toolbox_Model_for_NASNet-Large_Network Deep_Learning_Toolbox_Model_for_NASNet-Mobile_Network Deep_Learning_Toolbox_Model_for_ShuffleNet_Network Deep_Learning_Toolbox_Model_for_DarkNet-19_Network Deep_Learning_Toolbox_Model_for_DarkNet-53_Network Deep_Learning_Toolbox_Model_for_VGG-16_Network Deep_Learning_Toolbox_Model_for_VGG-19_Network"
  description = "Target products to install in the machine image, e.g. MATLAB SIMULINK."
}

variable "RELEASE" {
  type        = string
  default     = "R2024a"
  description = "Target MATLAB release to install in the machine image, must start with \"R\"."

  validation {
    condition     = can(regex("^R20[0-9][0-9](a|b)(U[0-9])?$", var.RELEASE))
    error_message = "The RELEASE value must be a valid MATLAB release, starting with \"R\"."
  }
}

variable "MATLAB_SOURCE_LOCATION" {
  type        = string
  default     = ""
  description = "Optional parameter which holds the location from which to download a MATLAB and toolbox source file, for use with the mpm --source option."
}

variable "SPKG_SOURCE_LOCATION" {
  type        = string
  default     = ""
  description = "Optional parameter which holds the location from which to download a MATLAB Support Packages source file, for use with the mpm --source option."
}

variable "BUILD_SCRIPTS" {
  type = list(string)
  default = [
    "Install-StartupScripts.ps1",
    "Install-Dependencies.ps1",
    "Install-NVIDIADrivers.ps1",
    "Install-MATLAB.ps1",
    "Install-MATLABSupportPackages.ps1",
    "Install-MSH.ps1",
    "Setup-DDUX.ps1",
    "Remove-IE.ps1"
  ]
  description = "The list of installation scripts Packer will use when building the image."
}

variable "STARTUP_SCRIPTS" {
  type = list(string)
  default = [
    "env.ps1",
    "10_Install-NiceDCV.ps1",
    "20_Setup-MATLAB.ps1",
    "90_WarmUp-MATLAB.ps1",
    "95_WarmUp-MSH.ps1",
    "99_Run-Optional-User-Command.ps1"
  ]
  description = "The list of startup scripts Packer will copy to the remote machine image build, which can be used during the deployment creation."
}

variable "DCV_INSTALLER_URL" {
  type        = string
  default     = "https://d1uj6qtbmh3dt5.cloudfront.net/2023.0/Servers/nice-dcv-server-x64-Release-2023.0-15487.msi"
  description = "The URL to install NICE DCV, a remote display protocol to use."
}

# To locate the URL, open a browser and go to the Microsoft webpage dedicated to downloading the Edge browser.
# https://www.microsoft.com/en-us/edge/business/download?form=MA13FJ
# Select the "Download for Windows 64-bit" option. As the file begins to download, access your
# browser's "Full download history" (the name of this feature may vary across browsers, but we're using Chrome as an example).
# Identify the file currently downloading, right-click on its link, and choose "Copy link address."
variable "EDGE_INSTALLER_URL" {
  type        = string
  default     = "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/624ce5ea-33a7-47f1-af28-5c677f0c18bf/MicrosoftEdgeEnterpriseX64.msi"
  description = "The URL to install the Microsoft Edge Browser."
}

variable "NVIDIA_DRIVER_INSTALLER_URL" {
  type        = string
  default     = "https://us.download.nvidia.com/tesla/538.15/538.15-data-center-tesla-desktop-winserver-2019-2022-dch-international.exe"
  description = "The URL to install NVIDIA drivers into the target machine image."
}

variable "PYTHON_INSTALLER_URL" {
  type        = string
  default     = "https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe"
  description = "The URL to install python into the target machine image."
}

variable "TENANT_ID" {
  type        = string
  description = "The Microsoft Entra ID tenant identifier with which your client_id and subscription_id are associated."
}

variable "CLIENT_ID" {
  type        = string
  description = "The Microsoft Entra ID service principal associated with your builder."
}

variable "CLIENT_SECRET" {
  type        = string
  description = "The password or secret for your service principal."
}

variable "USER_ASSIGNED_MANAGED_IDENTITIES" {
  type        = list(string)
  default     = []
  description = "List of resource IDs of user-assigned managed identities to assign to the Packer builder Virtual Machine."
}

variable "AZURE_KEY_VAULT" {
  type        = string
  default     = ""
  description = "Optional parameter to enter an Azure Key Vault name that can be used to store or retrieve sensitive information during Packer builds."
}

variable "RESOURCE_GROUP_NAME" {
  type        = string
  description = "Resource group under which the final artifact will be stored"
}

variable "STORAGE_ACCOUNT" {
  type        = string
  description = "Storage account under which the final artifact will be stored."
}

variable "SUBSCRIPTION_ID" {
  type        = string
  description = "Subscription under which the build will be performed."
}

variable "AZURE_TAGS" {
  type = map(string)
  default = {
    Name  = "Packer Build"
    Build = "MATLAB"
    Type  = "Windows"
  }
  description = "The tags Packer applies to every deployed resource."
}

variable "MANIFEST_OUTPUT_FILE" {
  type        = string
  default     = "manifest.json"
  description = "The name of the resultant manifest file."
}


variable "PACKER_ADMIN_USERNAME" {
  type        = string
  default     = "Administrator"
  description = "Username for the build instance."
}

variable "PACKER_ADMIN_PASSWORD" {
  type        = string
  description = "Password for the build instance. Must be provided as a build argument. Must satisfy password complexity requirements of base operating system."
  sensitive   = true
}

variable "IMAGE_PUBLISHER" {
  type        = string
  default     = "MicrosoftWindowsServer"
  description = "The publisher of the base image used for customization."
}

variable "IMAGE_OFFER" {
  type        = string
  default     = "WindowsServer"
  description = "The offer of the base image used for customization."
}

variable "IMAGE_SKU" {
  type        = string
  default     = "2022-Datacenter"
  description = "Version of the base image used for customization."
}

variable "VM_SIZE" {
  type        = string
  default     = "Standard_NC4as_T4_v3"
  description = "Size of base Azure VM."

}

# Set up local variables used by provisioners.
locals {
  timestamp             = regex_replace(timestamp(), "[- TZ:]", "")
  build_scripts         = [for s in var.BUILD_SCRIPTS : format("build/%s", s)]
  startup_scripts       = [for s in var.STARTUP_SCRIPTS : format("startup/%s", s)]
  packer_admin_username = "${var.PACKER_ADMIN_USERNAME}"
  packer_admin_password = "${var.PACKER_ADMIN_PASSWORD}"
}

# Configure the AZURE instance that is used to build the machine image.
source "azure-arm" "VHD_Builder" {
  communicator                     = "winrm"
  winrm_username                   = "${local.packer_admin_username}"
  winrm_password                   = "${local.packer_admin_password}"
  winrm_use_ssl                    = true
  winrm_insecure                   = true
  winrm_timeout                    = "30m"
  client_id                        = "${var.CLIENT_ID}"
  client_secret                    = "${var.CLIENT_SECRET}"
  resource_group_name              = "${var.RESOURCE_GROUP_NAME}"
  storage_account                  = "${var.STORAGE_ACCOUNT}"
  subscription_id                  = "${var.SUBSCRIPTION_ID}"
  tenant_id                        = "${var.TENANT_ID}"
  user_assigned_managed_identities = "${var.USER_ASSIGNED_MANAGED_IDENTITIES}"
  capture_container_name           = "images"
  capture_name_prefix              = "matlab-${var.RELEASE}"
  os_type                          = "Windows"
  image_publisher                  = "${var.IMAGE_PUBLISHER}"
  image_offer                      = "${var.IMAGE_OFFER}"
  image_sku                        = "${var.IMAGE_SKU}"
  azure_tags                       = "${var.AZURE_TAGS}"
  location                         = "East US"
  vm_size                          = "${var.VM_SIZE}"
  os_disk_size_gb                  = "128"
}

# Build the machine image.
build {
  sources = ["source.azure-arm.VHD_Builder"]
  provisioner "file" {
    destination = "C:/Windows/Temp/"
    source      = "build/config"
  }

  provisioner "file" {
    destination = "C:/Windows/Temp/startup/"
    sources     = "${local.startup_scripts}"
  }

  provisioner "powershell" {
    elevated_user     = "${local.packer_admin_username}"
    elevated_password = "${local.packer_admin_password}"
    scripts           = ["build/Enable-OpenSSh.ps1"]
  }

  provisioner "powershell" {
    environment_vars = [
      "RELEASE=${var.RELEASE}",
      "SPKGS=${var.SPKGS}",
      "PRODUCTS=${var.PRODUCTS}",
      "DCV_INSTALLER_URL=${var.DCV_INSTALLER_URL}",
      "EDGE_INSTALLER_URL=${var.EDGE_INSTALLER_URL}",
      "NVIDIA_DRIVER_INSTALLER_URL=${var.NVIDIA_DRIVER_INSTALLER_URL}",
      "PYTHON_INSTALLER_URL=${var.PYTHON_INSTALLER_URL}",
      "MATLAB_SOURCE_LOCATION=${var.MATLAB_SOURCE_LOCATION}",
      "SPKG_SOURCE_LOCATION=${var.SPKG_SOURCE_LOCATION}",
      "AZURE_KEY_VAULT=${var.AZURE_KEY_VAULT}"
    ]
    scripts = "${local.build_scripts}"
  }
  provisioner "powershell" {
    scripts = ["build/Remove-TemporaryFiles.ps1"]
  }
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout       = "10m"
  }
  provisioner "powershell" {
    pause_before = "90s"
    scripts      = ["build/Invoke-Sysprep.ps1"]
  }
  post-processor "manifest" {
    output     = "${var.MANIFEST_OUTPUT_FILE}"
    strip_path = true
    custom_data = {
      release             = "MATLAB ${var.RELEASE}"
      specified_products  = "${var.PRODUCTS}"
      specified_spkgs     = "${var.SPKGS}"
      build_scripts       = join(", ", "${var.BUILD_SCRIPTS}")
      storage_account     = "${var.STORAGE_ACCOUNT}"
      resource_group_name = "${var.RESOURCE_GROUP_NAME}"
    }
  }
}
