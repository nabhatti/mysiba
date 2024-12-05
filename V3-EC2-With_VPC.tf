provider "aws" {
    region = "us-east-1" 
}

resource "aws_instance" "demo-server" {
    ami = "ami-012967cc5a8c9f891"
    instance_type = "t2.micro"
    key_name = "dpp"
    //security_groups = ["demo-sg1"]
    vpc_security_group_ids = [aws_security_group.demo-sg1.id]
    subnet_id = aws_subnet.dpw-public_subnet_01.id
    }


resource "aws_security_group" "demo-sg1" {
  name        = "demo-sg1"
  description = "SSH access"
  vpc_id = aws_vpc.dpw-vpc.id
  ingress {
    description = "SSH Access"
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
    Name = "ssh-port"
  }
}

resource "aws_vpc" "dpw-vpc" {
       cidr_block = "10.1.0.0/16"
       tags = {
        Name = "dpw-vpc"
     }
   }

//Create a Subnet 
resource "aws_subnet" "dpw-public_subnet_01" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "dpw-public_subnet_01"
    }
}
//Create a Subnet 02 
resource "aws_subnet" "dpw-public_subnet_02" {
    vpc_id = aws_vpc.dpw-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
    tags = {
      Name = "dpw-public_subnet_02"
    }
}
//Creating an Internet Gateway 
resource "aws_internet_gateway" "dpw-igw" {
    vpc_id = aws_vpc.dpw-vpc.id
    tags = {
      Name = "dpw-igw"
    }
}
// Create a route table 
resource "aws_route_table" "dpw-public-rt" {
    vpc_id = aws_vpc.dpw-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpw-igw.id
    }
    tags = {
      Name = "dpw-public-rt"
    }
}
// Associate subnet with route table

resource "aws_route_table_association" "dpw-rta-public-subnet-1" {
    subnet_id = aws_subnet.dpw-public_subnet_01.id
    route_table_id = aws_route_table.dpw-public-rt.id
}
resource "aws_route_table_association" "dpw-rta-public-subnet-2" {
    subnet_id = aws_subnet.dpw-public_subnet_02.id
    route_table_id = aws_route_table.dpw-public-rt.id
}