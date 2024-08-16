# Terraform and Ansible Setup for Azure PostgreSQL and VM

This repository contains Terraform and Ansible configurations for provisioning and configuring an Azure PostgreSQL Flexible Server and a Virtual Machine. The Terraform scripts set up the infrastructure, and the Ansible playbooks handle configuration tasks on the VM.

## Terraform Configuration

### Files

- **`main.tf`**: Contains the Terraform configuration for creating the Azure resources including:
  - Resource Group
  - Virtual Network and Subnet
  - Network Security Group and Rules
  - PostgreSQL Flexible Server
  - Virtual Machine and Network Interface

- **`provider.tf`**: Configures the Azure provider and specifies the Azure Subscription ID using Terraform variables.

- **`variables.tf`**: Defines Terraform variables for resource group name, location, and Azure Subscription ID.

- **`terraform.tfvars`**: Provides the values for Terraform variables, including the Azure Subscription ID.

- **`outputs.tf`**: Contains the Terraform outputs for use in the Ansible configuration, including:
  - VM public IP address
  - PostgreSQL private IP address
  - VM admin username and password

### Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Apply Terraform Configuration**:
   ```bash
   terraform apply
   ```

3. **Extract Terraform Outputs**:
   ```bash
   terraform output -json > terraform_output.json
   ```

## Ansible Configuration

### Files

- **`inventory.yml`**: Defines the inventory for Ansible, including the VM details and SSH configuration.

- **`group_vars/all.yml`**: Contains variables used in the Ansible playbook, including PostgreSQL connection details.

- **`playbook.yml`**: Contains Ansible tasks for:
  - Installing PostgreSQL client
  - Configuring the `.pgpass` file for automated logins
  - Creating a DBLink in the PostgreSQL database

### Usage

1. **Run the Ansible Playbook**:
   ```bash
   ansible-playbook -i inventory.yml playbook.yml --extra-vars "@terraform_output.json"
   ```

## Requirements

- **Terraform**: [Download and Install Terraform](https://www.terraform.io/downloads.html)
- **Ansible**: [Download and Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- **Azure CLI**: [Download and Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Notes

- Make sure to replace placeholder values in the Terraform and Ansible configurations with your specific details.
- Ensure you have the necessary permissions and credentials to create and manage Azure resources.
- The Ansible playbook requires SSH access to the Azure VM. Ensure that your SSH key is correctly configured.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.