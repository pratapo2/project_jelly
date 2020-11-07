#Define Our VPC

resource "aws_vpc" "default" {
   cidr_block = "${var.vpc_cidr}"
   enable_dns_hostnames = true
      tags = {
        Name = "production-vpc"
      }
}

# Create A public Subnet-1
resource "aws_subnet" "public-subnet-1" {
   vpc_id = "${aws_vpc.default.id}"
   cidr_block = "${var.public_subnet_1_cidr}"
   availability_zone = "ap-south-1a"
   tags = {
     Name = "public-subnet-1"
   }
}

# Create a public Subnet-2
resource "aws_subnet" "public-subnet-2" {
   vpc_id = "${aws_vpc.default.id}"
   cidr_block = "${var.public_subnet_2_cidr}"
   availability_zone = "ap-south-1b"
   tags = {
     Name = "public-subnet-2"
   }
}

# Create a private Subnet-1
resource "aws_subnet" "private-subnet-1" {
   vpc_id = "${aws_vpc.default.id}"
   cidr_block = "${var.private_subnet_1_cidr}"
   availability_zone = "ap-south-1a"
   tags = {
     Name = "private-subnet-1"
   }
}

# create a private Subnet-2
resource "aws_subnet" "private-subnet-2" {
   vpc_id = "${aws_vpc.default.id}"
   cidr_block = "${var.private_subnet_2_cidr}"
   availability_zone = "ap-south-1b"
   tags = {
     Name = "private-subnet-2"
   }
}

# create a public and private Route Table
resource "aws_route_table" "public-route-table" {
   vpc_id = "${aws_vpc.default.id}"
   tags = {
     Name = "Public-Route-Table"
   }
}

resource "aws_route_table" "private-route-table" {
   vpc_id = "${aws_vpc.default.id}"
   tags = {
     Name = "Private-Route-Table"
   }
}

# Associating Route Tables With Public Subnets
resource "aws_route_table_association" "public-subnet-1-association" {
    route_table_id = "${aws_route_table.public-route-table.id}"
    subnet_id = "${aws_subnet.public-subnet-1.id}"
}

resource "aws_route_table_association" "public-subnet-2-association" {
    route_table_id = "${aws_route_table.public-route-table.id}"
    subnet_id = "${aws_subnet.public-subnet-2.id}"
}

# Associating Route Tables With Private Subnets
resource "aws_route_table_association" "private-subnet-1-association" {
        route_table_id = "${aws_route_table.private-route-table.id}"
        subnet_id = "${aws_subnet.private-subnet-1.id}"
}

resource "aws_route_table_association" "private-subnet-2-association" {
        route_table_id = "${aws_route_table.private-route-table.id}"
        subnet_id = "${aws_subnet.private-subnet-2.id}"
}

# creating a Elastic IP For Nat Gateway
#resource "aws_eip" "elastic-ip-for-nat-gw" {
#  vpc = true
#  tags = {
#    Name = "Production-EIP"
#  }
#}

# creating a Nat-Gateway And Adding to Route Table
#resource "aws_nat_gateway" "nat-gw" {
#  allocation_id = "${aws_eip.elastic-ip-for-nat-gw.id}"
#  subnet_id = "${aws_subnet.public-subnet-1.id}"
#    tags = {
#      Name = "Production-NAT-GW"
#  }
#}

#resource "aws_route" "nat-gw-route" {
#  route_table_id = "${aws_route_table.private-route-table.id}"
#  nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
#  destination_cidr_block = "0.0.0.0/0"
#}

# creating an Internet Gateway(IGW) and adding to Route Table
resource "aws_internet_gateway" "production-igw" {
 vpc_id = "${aws_vpc.default.id}"
 tags = {
   Name = "Production-IGW"
 }
}

resource "aws_route" "public-internet-gw-route" {
  route_table_id = "${aws_route_table.public-route-table.id}"
  gateway_id = "${aws_internet_gateway.production-igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

# Now creating Security Groups

resource "aws_security_group" "sgweb" {
  name = "web-server-sg"
  description = "Allow incoming Http and HTTPS connections & SSH from office ISP Public IP Only"

ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# ssh is allowed only to MY ISP
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["47.30.166.86/32"]
  }

egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

vpc_id="${aws_vpc.default.id}"
  tags = {
    Name = "web-server-sg"
  }
}

# Creating a LB SG
resource "aws_security_group" "lb"{
   name = "load-balancer-security-group"
   description = "Allow traffic from public subnet"

ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

vpc_id = "${aws_vpc.default.id}"
  tags = {
    Name = "lb-sg"
  }
}
