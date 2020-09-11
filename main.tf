provider "aws" {
    region = var.region
}

# 1. Create VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "terraform-vpc"
  }
}
# 2. Create Internet GW
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "terraform-igw"
  }
}
# 3. Create route table

resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "terraform route table"
  }
}

# 4. Create subnet
resource "aws_subnet" "my-subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.my-vpc.id
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "terraform-subnet"
  }
}
# 5. Associate subnet with route table
resource "aws_route_table_association" "my-rt-assoc" {
  subnet_id = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-rt.id
}

# 6. Create security group to all port 22,80,443

resource "aws_security_group" "my-sg" {
  name        = "allow_web_traffice"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffice"
  }
}

# 7. Create a NIC with an IP in the subnet created in step 4

resource "aws_network_interface" "my-nic" {
  subnet_id       = aws_subnet.my-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.my-sg.id]

  attachment {
    instance     = aws_instance.my-ec2.id
    device_index = 1
  }
}

# 8. Assign an elastic IP to the NIC in step 7

# 9. Create Ubuntu server and install/enable apache2

resource "aws_instance" "my-ec2" {
  ami = "ami-06b263d6ceff0b3dd"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  associate_public_ip_address = "true"
#  aws_eip = "true"
  tags = {
    "Name" = "terraform-ec2"
  }
  subnet_id = aws_subnet.my-subnet.id
  key_name = "MyKey"
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c 'echo your first terraform web server > /var/www/html/index.html'
    EOF
}

# get public IP for EC2

resource "aws_eip" "my-ip" {
  vpc      = true
  instance = aws_instance.my-ec2.id
}

#resource "aws_instance" "my-hostname" {
#  instance = aws_instance.my-ec2.hostname

#}
