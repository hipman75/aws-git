provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "my-terraform-ec2" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  tags = {
    "key" = "EC2 terraform"
  }
}