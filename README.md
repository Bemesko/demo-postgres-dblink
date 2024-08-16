Here’s a README file you can use for your Terraform repository:

---

# Azure PostgreSQL Flexible Server to Azure VM Connection

This repository contains Terraform configuration files to create a connection between an Azure PostgreSQL Flexible Server and a PostgreSQL server hosted on an Azure Virtual Machine (VM). This setup allows you to use a foreign data wrapper (`postgres_fdw`) to query data from the PostgreSQL server on the Azure VM as if it were local to the Azure PostgreSQL Flexible Server.

## Table of Contents

- [Azure PostgreSQL Flexible Server to Azure VM Connection](#azure-postgresql-flexible-server-to-azure-vm-connection)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Architecture](#architecture)
  - [Getting Started](#getting-started)
    - [Clone the Repository](#clone-the-repository)
    - [Initialize Terraform](#initialize-terraform)
    - [Deploy the Infrastructure](#deploy-the-infrastructure)
  - [Post-Deployment Setup](#post-deployment-setup)
    - [Configure PostgreSQL on the Azure VM](#configure-postgresql-on-the-azure-vm)
    - [Configure Foreign Data Wrapper on the Flexible Server](#configure-foreign-data-wrapper-on-the-flexible-server)
  - [Cleaning Up](#cleaning-up)
  - [Contributing](#contributing)
  - [License](#license)

## Prerequisites

Before using this Terraform configuration, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) v1.0.0 or later
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) for authenticating to your Azure account
- An active [Azure subscription](https://azure.microsoft.com/en-us/free/)

## Architecture

This Terraform configuration will provision the following resources:

- **Resource Group**: To group all related resources.
- **Virtual Network (VNet)**: A VNet with a subnet to host the Azure PostgreSQL Flexible Server and the Azure VM.
- **Azure PostgreSQL Flexible Server**: A managed PostgreSQL instance.
- **Azure Virtual Machine (VM)**: A VM running Ubuntu, on which PostgreSQL will be installed.
- **Network Security Group (NSG)**: To control inbound and outbound traffic to the Azure VM.
- **Network Interface (NIC)**: Associated with the Azure VM for network connectivity.

## Getting Started

### Clone the Repository

Start by cloning this repository to your local machine:

```bash
git clone https://github.com/yourusername/azure-postgres-dblink.git
cd azure-postgres-dblink
```

### Initialize Terraform

Initialize the Terraform working directory. This will download the necessary providers and modules:

```bash
terraform init
```

### Deploy the Infrastructure

To deploy the infrastructure, run the following command:

```bash
terraform apply
```

Terraform will show you an execution plan and ask for your confirmation before proceeding. Type `yes` to confirm and start the deployment.

## Post-Deployment Setup

After the infrastructure is deployed, you need to perform a few manual steps to configure the PostgreSQL server on the Azure VM and set up the foreign data wrapper on the Azure PostgreSQL Flexible Server.

### Configure PostgreSQL on the Azure VM

1. **SSH into the VM**:
   ```bash
   ssh adminuser@<VM_Public_IP>
   ```

2. **Install PostgreSQL**:
   ```bash
   sudo apt-get update
   sudo apt-get install postgresql postgresql-contrib
   sudo systemctl start postgresql
   ```

3. **Set PostgreSQL Password**:
   ```bash
   sudo -i -u postgres psql
   ALTER USER postgres PASSWORD 'newpassword';
   ```

4. **Configure `pg_hba.conf`**:
   ```bash
   sudo nano /etc/postgresql/12/main/pg_hba.conf
   ```
   Add the following line to allow connections from the Azure PostgreSQL Flexible Server:
   ```
   host    all             all             10.0.1.0/24          md5
   ```
   Restart PostgreSQL after making the changes:
   ```bash
   sudo systemctl restart postgresql
   ```

### Configure Foreign Data Wrapper on the Flexible Server

1. **Connect to the Azure PostgreSQL Flexible Server** using a PostgreSQL client like `psql`:

   ```bash
   psql -h <flexible_server_name>.postgres.database.azure.com -U psqladmin -d <dbname>
   ```

2. **Create the Foreign Data Wrapper**:

   ```sql
   CREATE EXTENSION IF NOT EXISTS postgres_fdw;

   CREATE SERVER azure_vm_server
   FOREIGN DATA WRAPPER postgres_fdw
   OPTIONS (host '10.0.1.4', port '5432', dbname 'yourdbname');

   CREATE USER MAPPING FOR psqladmin
   SERVER azure_vm_server
   OPTIONS (user 'postgres', password 'newpassword');

   CREATE FOREIGN TABLE foreign_table_name (
       id integer,
       name text
   )
   SERVER azure_vm_server
   OPTIONS (schema_name 'public', table_name 'remote_table_name');
   ```

3. **Query the Foreign Table**:
   ```sql
   SELECT * FROM foreign_table_name;
   ```

## Cleaning Up

To destroy the infrastructure created by this Terraform configuration, run:

```bash
terraform destroy
```

This will remove all the resources created by Terraform.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
