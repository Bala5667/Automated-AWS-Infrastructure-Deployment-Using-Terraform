provider "aws" {
  region = "us-east-1" # Update with your preferred region
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "my_nat_eip" {
  domain = "vpc"
}

# Create NAT Gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Update if necessary
  map_public_ip_on_launch = true
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a" # Update if necessary
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Add Route to Public Route Table (Internet Gateway)
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Add Route to Private Route Table (NAT Gateway)
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway.id
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create Security Group for Public
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Security Group for Private
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
}

# Create Security Group for DB
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.private_sg.id]
  }
}

# Create EC2 Instance Web (Public)
resource "aws_instance" "web_instance" {
  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello World" > /var/www/html/index.html
              EOF
}


# Create EC2 Instance APP (Private)
resource "aws_instance" "app_instance" {
  ami                    = "ami-0c55b159cbfafe1f0" # Update with your desired AMI ID
  instance_type           = "t2.micro"
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids     = [aws_security_group.private_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              yum install -y python3
              echo "Backend Python App" > /var/www/app/index.py
              EOF
}

# Create RDS Database Instance
resource "aws_db_instance" "my_db" {
  allocated_storage    = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t2.micro"
  # name = "mydb" 
  username            = "admin"
  password            = "password123"
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]
}

output "web_instance_public_ip" {
  value = aws_instance.web_instance.public_ip
}

output "app_instance_private_ip" {
  value = aws_instance.app_instance.private_ip
}

output "rds_endpoint" {
  value = aws_db_instance.my_db.endpoint
}
