#Creating a new vpc
resource "aws_vpc" "Sample_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Sample_VPC"
  }
}

# adding public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.Sample_vpc.id}"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name = "Public Subnet"
  }
}

# adding private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.Sample_vpc.id}"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Private Subnet"
  }
}

# adding internet gateway for external communication
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.Sample_vpc.id}"

  tags = {
    Name = "Internet Gateway"
  }
}

# adding an elastic IP
resource "aws_eip" "elastic_ip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.internet_gateway"]
}

# creating the NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.elastic_ip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"
  depends_on    = ["aws_internet_gateway.internet_gateway"]
}

# creating custom route table
resource "aws_route_table" "custom_route_table" {
  vpc_id = "${aws_vpc.Sample_vpc.id}"

  tags = {
    Name = "Custom Route table Private Subnet"
  }
}


# adding custom route table to IGW
resource "aws_route" "custom_route" {
  route_table_id         = "${aws_route_table.custom_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

# adding main route table to nat
resource "aws_route" "main_route" {
  route_table_id         = "${aws_vpc.Sample_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

# associate public subnet to custom route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.custom_route_table.id}"

}

# associate private subnet to main route table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_vpc.Sample_vpc.main_route_table_id}"
}


# Creating ec2-instance in public Subnet

resource "aws_instance" "Jump_Server" {
  ami               = "ami-0520e698dd500b1d1"
  instance_type     = "t2.micro"
  availability_zone = "us-east-2a"
  subnet_id         = "${aws_subnet.public_subnet.id}"
  security_groups   = ["${aws_security_group.sample_http_ssh.id}"]
  key_name          = "terra"
  tags = {
    Name = "Ec2 instance in public subnet"
  }
}

# Creating ec2-instance in Private Subnet

resource "aws_instance" "DB_Server" {
  ami               = "ami-0520e698dd500b1d1"
  instance_type     = "t2.micro"
  availability_zone = "us-east-2b"
  subnet_id         = "${aws_subnet.private_subnet.id}"
  security_groups   = ["${aws_security_group.sample_http_ssh.id}"]
  key_name          = "terra"
  tags = {
    Name = "Ec2 instance in public subnet"
  }
}
