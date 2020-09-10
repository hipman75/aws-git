provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "my-ec2" {
  ami = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  tags = {
    "Name" = "terraform-ec2"
  }
  subnet_id = aws_subnet.my-subnet.id
  vpc_security_group_ids = ["sg-0dd7fb01b7295c9b6","sg-0412309b76be8b3b7"]
  key_name = "MyKey"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "terraform-vpc"
  }
}

resource "aws_subnet" "my-subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    "Name" = "terraform-subnet"
  }
}