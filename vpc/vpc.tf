resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr_block

  tags = merge(var.tags, {
    Name = "${local.Name}-myvpc"
  })

}

locals {
  Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}"
}



resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet_cidr[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${local.Name}-public-subnet1"
  })
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet_cidr[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${local.Name}-public-subnet2"
  })
}


resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.subnet_cidr[2]
  availability_zone = var.availability_zones[0]

  tags = merge(var.tags, {
    Name = "${local.Name}-private-subnet1"
  })
}


resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.subnet_cidr[3]
  availability_zone = var.availability_zones[1]

  tags = merge(var.tags, {
    Name = "${local.Name}-private-subnet2"
  })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = merge(var.tags, {
    Name = "${local.Name}-igw"
  })


}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(var.tags, {
    Name = "${local.Name}-public-rt"
  })
}


resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_eip" "eip" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${local.Name}-eip"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = merge(var.tags, {
    Name = "${local.Name}-nat-gw"
  })


  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip, aws_subnet.public_subnet1]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = merge(var.tags, {
    Name = "${local.Name}-private-rt"
  })
}

resource "aws_route_table_association" "private_subnet1_association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet2_association" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}
