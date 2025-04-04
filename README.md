1️⃣ Install Terraform on Windows & Set Up Path Variables
The first step was to install Terraform on my Windows machine and configure it correctly.

Downloaded Terraform from the official website.

Installed it by extracting the ZIP file.

Added the Terraform binary path (C:\Program Files\Terraform) to System Environment Variables so that I could run terraform commands from anywhere in the terminal.

To verify the installation, I ran: terraform -version

✅ Terraform version displayed, confirming the installation.

2️⃣ Install AWS CLI & Configure Path Variables
To interact with AWS, I needed the AWS CLI installed.

Downloaded and installed AWS CLI from the official site.

Added the AWS CLI path to System Environment Variables (C:\Program Files\Amazon\AWSCLI\bin).

To verify the installation, I ran: aws --version
✅ AWS CLI version displayed successfully.

3️⃣ Create a Terraform Configuration File (.tf file)

Terraform configurations are written in .tf files.
I created a file named main.tf using VS Code.
This file contains all the Terraform infrastructure definitions.

4️⃣ Create a Directory & Save the main.tf File
Before running Terraform, I needed a dedicated directory for my project.

Used PowerShell to create a folder and navigate to it:

mkdir Terraform_Project
cd Terraform_Project
Saved my main.tf file inside this folder.

Ensured my terminal was in the correct directory before running any Terraform commands.

5️⃣ Write Terraform Configuration in main.tf
Inside main.tf, I added the Terraform script to launch an EC2 instance and create an S3 bucket.

provider "aws" {
  region = "us-east-2"  # I set the region I wanted
}

resource "aws_instance" "example" {
  ami           = "ami-00a929b66ed6e0de6"  # Updated AMI based on my region
  instance_type = "t2.micro"
  key_name      = "my-keypair"

  tags = {
    Name = "My-Terraform-Instance"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-bucket-unique-name"
  acl    = "private"

  tags = {
    Name        = "TerraformS3"
    Environment = "Development"
  }
}
✅ This script defines an EC2 instance and an S3 bucket.

6️⃣ Run Terraform Commands
After setting up main.tf, I executed the following Terraform commands:

1️⃣ Initialize Terraform

terraform init
✅ This downloaded all necessary AWS provider plugins.

2️⃣ Check the execution plan
terraform plan
✅ This showed what resources Terraform would create.

3️⃣ Apply and deploy resources

terraform apply -auto-approve
✅ My EC2 instance and S3 bucket were successfully created!

7️⃣ Verify the Created Resources in AWS
I logged into the AWS Console and checked:
✅ EC2 Dashboard → My instance was running.
✅ S3 Console → My bucket was successfully created.

8️⃣ Destroy Resources (Cleanup)
To delete all resources, I used:
terraform destroy -auto-approve
✅ This removed all instances and S3 buckets created by Terraform.
Alternatively, resources can also be deleted manually from the AWS Console.

Key Learnings from This Project
✅ Terraform automation made resource provisioning quick and efficient.
✅ Changing regions requires updating the AMI ID to match the new region.
✅ Keeping files organized in a dedicated Terraform project folder is essential.
✅ Using terraform plan before applying helps avoid unexpected issues.

