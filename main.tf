provider "aws" {
  region = "us-east-1"

}

#----------------------------------------------------------------#
# 
# Virtual Private Cloud and Network Setup

# Create a Virtual Private Cloud. 
resource "aws_vpc" "myapp-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name : "demo-vpc"
  }
}

# Create a subnet within the Virtual Private Cloud. 

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = "10.0.34.0/24"
  availability_zone = "us-east-1f"
  tags = {
    Name : "demo-subnet-1"
  }
}

# Add an internet gateway to the VPC. 

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name : "demo-igw"
  }
}


# Setup default route table within the VPC environment. 

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name : "demo-main-rtb"
  }
}

#----------------------------------------------------------------#
#
# Security Groups

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"] // This should be set to your local workstation IP address!!
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name : "demo-default-sg"
  }
}

#----------------------------------------------------------------#
# 
# Create an AWS EC2 Virtual Machine Instance. 

# Retrieve the latest AMI

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]

  }
}

output "aws-ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2-public_ip" {
  value = aws_instance.myapp-server.public_ip
}

# Identify VPC, network and security group for Linux virtual machine.



resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = "t2.medium"

  subnet_id              = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone      = "us-east-1f"

  key_name = "server-key-pair"

  associate_public_ip_address = true

  # Identify the name of the SSH key pair to be associated with your linux VM
  # NOTE: This SSH key requires a public and private key pair that you have access to.
  #
  # You must provide the full path to the public and private key pair you intend to use.
  # For example a user named joe on a linux system would typically be /home/joe/.ssh/id_rsa.pub 
  # for their public key and /home/joe/.ssh/id_rsa for the private key. 
  // key_name = aws_key_pair.ssh-key.key_name

  #----------------------------------------------------------------#
  # Install software on the Amazon EC2 Instance.

  user_data = file("entry-script.sh")

  user_data_replace_on_change = true



  tags = {
    Name : "demo-server"
  }
}





