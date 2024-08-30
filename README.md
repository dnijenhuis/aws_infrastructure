## AWS Cloud Infrastructure for www.92125638.com - Coded in Terraform

### Overview
This project establishes the foundation of a scalable and secure cloud infrastructure within an AWS environment. The infrastructure supports a website hosted across multiple regions and availability zones, and provides secure access for employees to virtual Windows machines through a VPN connection.

### Core Resources
The core resources of this project include:
- **Route 53 Records**: Directs global traffic to the closest server.
- **Application Load Balancers (ALB)**: Distributes website visitors across servers.
- **VPCs and Subnets**: Deployed in the US and EU regions.
- **VPC Peering Connection**: Connects the US and EU VPCs.
- **Auto Scaling Groups (ASG)**: Automatically creates and destroys web servers per region based on CPU usage.
- **Windows Machines**: For employees, located in a private subnet.
- **VPN Gateway and Internet Gateways**: Facilitate secure and general internet access.
- **Network Address Translation (NAT)**: Allows internet access from the private subnet.
- **Route Tables and Security Groups**: Manage network traffic and security.
- **Web Application Firewall (WAF)**: Basic setup for IP address-based traffic blocking.

A visual overview of the infrastructure is included in the project as `updated_diagram.drawio.png`.

### Code Structure
The code is written using Terraform. Each `.tf` file starts with a general description of its contents. Resources are described with in-code comments as well. Comments at the line-level are added where deemed necessary.

The general order of the code within the `.tf` files is as follows:
- From general resource to specific resource (e.g., VPC before Subnets).
- Resources for the US public subnet code first, followed by US private subnet, and then EU public subnet.
- Lastly, similar code for multiple subnets is organized alphabetically (e.g., `eu_public_subnet_1a` before `eu_public_subnet_1b`).

### Installation Manual
Ensure you have:
- Created an AWS account at [aws.amazon.com](https://aws.amazon.com/).
- Installed Terraform.
- Installed Visual Studio Code.
- Installed OpenVPN.
- Installed OpenSSL (either from the GitHub repository or the user-friendly [OpenSSL Library](https://openssl-library.org/)).

To install Terraform and Visual Studio Code, I refer to the freeCodeCamp.org video "Terraform Course - Automate Your AWS Cloud Infrastructure" on YouTube.

Next, download all files from this GitHub repository and save them to a location of your choice. Open the chosen directory in Visual Studio Code by selecting `File > Open Folder`. Replace the AWS Key placeholders in the `terraform.tfvars` file.

In Visual Studio Code, open the terminal (`Terminal > New Terminal`) and enter the following commands (and enter 'yes' to confirm where necessary):

```bash
terraform init
```
```bash
terraform validate
```
```bash
terraform plan
```
```bash
terraform apply 
```
The infrastructure should now be up and running. However, additional tasks still need to be performed:
- Setting up additional private instances for employees.
- Adjusting code so that private instances remain 'fixed' when updating Terraform code.
- Setting up VPN-connections and creating the necessary certificates per employee.
- Providing the employee instances with SSH access to web servers.
- Tailoring the ASG and WAF needs to the specific requirements of the company.


### Tests
The following features have been tested:

- Correct traffic distribution across regions (based on the location of the website visitor).
- HTTPS setup and redirection of HTTP to HTTPS.
- Blocking specified (demo) IP addresses with the WAF.
- Adequate scaling by the ASG when CPU load exceeded the specified threshold.
- Connecting to the Windows machine in the private subnet using OpenVPN and RDP.
- Testing connectivity with web servers in the EU region (through VPC peering).

