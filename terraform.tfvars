# This file contains the values of the variables used in the complete Terraform code. Variables included
# are keys, instance-specs, scripts for the web servers, and ARNs.
# This file should (in its original state) not be uploaded to GitHub or the IU website. This should only
# be done after removing the access keys.

aws_access_key = "PLACEHOLDER"
aws_secret_key = "PLACEHOLDER"

# Keys manually created in AWS Console.
key_names = {
  "us-east-1"    = "PLACEHOLDER"
  "eu-central-1" = "PLACEHOLDER"
}

# Instnce IDs needed for the ASGs to create instances. I chose Ubuntu for the simple reason that the 
# online tutorials I did also used them. Since the use of the servers (presenting a 'Hello world' website)
# I saw no reason to select a specific type of web server.
ami_ids = {
  "us-east-1"    = "ami-04a81a99f5ec58529" # North-Virginia, t2.micro free tier Ubuntu server
  "eu-central-1" = "ami-0e872aee57663ae2d" # Frankfurt, t2.micro free tier Ubuntu server
}

# Free tier instance.
instance_type  = "t2.micro"

# This is the script that gets installed and runs on the web servers. It installs apache2 and enables some SSL
# modules which solved bugs I had before. It displays a welcome message, including the region and AZ the server
# is in.

user_data_script = <<EOF
#!/bin/bash

# Update package list and install Apache
sudo apt update -y
sudo apt install apache2 -y

echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/servername.conf
sudo a2enconf servername

sudo a2enmod ssl
echo "SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1" | sudo tee -a /etc/apache2/mods-available/ssl.conf
sudo a2ensite default-ssl.conf

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") # Needed for script to get access to the region/AZ meta data.
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/region)
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone) 

# The simple web page displayed, including the region and AZ.
echo "Hello World!" | sudo tee /var/www/html/index.html
echo "Region: $REGION" | sudo tee -a /var/www/html/index.html
echo "Availability Zone: $AVAILABILITY_ZONE" | sudo tee -a /var/www/html/index.html

# Restart Apache to apply the changes and enable apache2 to start on boot.
sudo systemctl restart apache2
sudo systemctl enable apache2

# Install, configure and start SSM
if ! command -v amazon-ssm-agent &> /dev/null
then
    sudo snap install amazon-ssm-agent --classic
fi

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

EOF



arn_lb_us_east_1 = "PLACEHOLDER"
arn_lb_eu_central_1 = "PLACEHOLDER"

# ARNs necessary at various locations in the code. Retrieved manually from AWS console.
certificate_arn_us_east_1 = "PLACEHOLDER"
certificate_arn_eu_central_1 = "PLACEHOLDER"

client_certificate_arn_root = "PLACEHOLDER"