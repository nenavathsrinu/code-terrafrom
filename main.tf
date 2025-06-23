resource "aws_vpc" "posvpc" {
  instance_tenancy     = "default"
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { Name = "pos-vpc" })
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.posvpc.id
  count                   = length(var.publicsubnet)
  cidr_block              = element(var.publicsubnet, count.index)
  availability_zone       = element(var.aws_availibity_zones, count.index)
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "puluic-subnet" })
}

resource "aws_subnet" "privatesubnet" {
  vpc_id            = aws_vpc.posvpc.id
  count             = length(var.privatesubnet)
  cidr_block        = element(var.privatesubnet, count.index)
  availability_zone = element(var.aws_availibity_zones, count.index)
  tags              = merge(var.tags, { Name = "private-subnet" })

}

resource "aws_internet_gateway" "posigw" {
  vpc_id = aws_vpc.posvpc.id
  tags   = merge(var.tags, { Name = "pos-igw" })
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.posvpc.id
  tags   = merge(var.tags, { Name = "pulic-rtb" })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.posigw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.publicsubnet)
  subnet_id      = element(aws_subnet.publicsubnet[*].id, count.index)
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_eip" "nat-eip" {
  tags = merge(var.tags, { Name = "pos-nat-eip" })
}

resource "aws_nat_gateway" "pos-nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.publicsubnet[0].id
  tags          = merge(var.tags, { Name = "pos-private-rtb" })
}

resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.posvpc.id
  tags   = merge(var.tags, { Name = "pos-private-rtb" })
}

resource "aws_route" "private-route" {
  route_table_id         = aws_route_table.private-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.pos-nat.id
}

resource "aws_route_table_association" "private-assocate" {
  count          = length(aws_subnet.privatesubnet)
  subnet_id      = element(aws_subnet.privatesubnet[*].id, count.index)
  route_table_id = aws_route_table.private-rtb.id
}