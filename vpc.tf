data "aws_availability_zones" "available"{
    state = "available"
}

#vpc creation
resource "aws_vpc" "own-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames="true"


  tags = {
    Name = "own-vpc"
  }
}
  #internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.own-vpc.id

  tags = {
    Name = "own-igw"
  }
}
# creating subnet
resource "aws_subnet" "public" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.own-vpc.id
  cidr_block = element(var.pub_cidr,count.index)
  map_public_ip_on_launch = "true"
  availability_zone= element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "own-Pub-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.own-vpc.id
  cidr_block = element(var.private_cidr,count.index)
#   map_public_ip_on_launch = "true"
  availability_zone= element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "own-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "data" {
  count=length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.own-vpc.id
  cidr_block = element(var.data_cidr,count.index)
#   map_public_ip_on_launch = "true"
  availability_zone= element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name ="own-data-subnet-${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
  vpc      = true

  tags = {
    Name = "eip_nat"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id



  tags = {
    Name = "gw NAT"
  }
}


#routing tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.own-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  
  tags = {
    Name = "public_routing"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.own-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  
  tags = {
    Name = "private_routing"
  }
}

#route_association

resource "aws_route_table_association" "public" {
  count=length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
count=length(aws_subnet.private[*].id)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}  


resource "aws_route_table_association" "data" { 
 count=length(aws_subnet.data[*].id)
  subnet_id      = element(aws_subnet.data[*].id,count.index)
  route_table_id = aws_route_table.private.id
}