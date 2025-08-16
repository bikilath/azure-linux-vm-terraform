# Azure Linux VM Terraform Deployment

Terraform project to deploy an Ubuntu Linux Virtual Machine in Azure, including networking, security, and public IP configuration. Provides automated infrastructure setup and outputs the VM’s public IP for easy access.


This Terraform project deploys an Ubuntu Linux Virtual Machine in Azure along with the required networking and security infrastructure.

## Resources Created

- **Resource Group:** `mtc-rg`  
- **Virtual Network:** `mtc-network` with address space `10.0.0.0/16`  
- **Subnet:** `mtc-subnet` with address prefix `10.0.1.0/24`  
- **Network Security Group (NSG):** `mtc-nsg` with a default inbound rule allowing all traffic  
- **Public IP:** `mtc-public-ip` (Static, Standard)  
- **Network Interface:** `mtc-nic`  
- **Linux Virtual Machine:** `mtc-vm` (Ubuntu 22.04 LTS)  
- **NSG Association:** Subnet is associated with the NSG  

## Prerequisites

- Terraform >= 1.0  
- Azure CLI installed and logged in  
- SSH key pair (`~/.ssh/mtcazurekey.pub` for admin access)  
- Basic knowledge of Terraform and Azure resources  

## Usage

1. **Clone the repository**

  `git clone <YOUR_REPO_URL>
cd <PROJECT_FOLDER>`

2. **Initialize Terraform**

  `terraform init`

3. **Plan the deployment**

  `terraform plan`

4. **Apply the configuration**

  `terraform apply`

## Terraform will create all Azure resources.

After successful deployment, it will output the public IP of the VM.

5. **Connect to the VM**

  `ssh -i ~/.ssh/mtcazurekey adminuser@<PUBLIC_IP>`

6. **Destroy resources when no longer needed**

  `terraform destroy`

## Variables & Customization

- customdata.tpl – File containing custom startup scripts for VM initialization.

- host_os variable – Determines the interpreter for running the local-exec provisioner.

- Admin username and SSH key can be modified in the azurerm_linux_virtual_machine resource.

## Outputs

- public_ip_address – Displays the public IP of the deployed VM for SSH access.

## Security Notes

- Avoid pushing private SSH keys to GitHub.

- Use .gitignore to prevent sensitive files from being committed:

## Contributing

- Feel free to fork the repository and submit pull requests for improvements.

