
# VPC

resource "aws_vpc" "VPC-B-NewYork-Test" {
   
    cidr_block = "10.21.0.0/16"
  

  tags = {
    Name = "VPC-B-NewYork-Test"
    Service = "application1"
    Owner = "Frodo"
    Planet = "Arda"
  }
}


#------------------------------------------------------------#
# Subnets
# New York VPC Public IP space.

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.VPC-B-NewYork-Test.id
  cidr_block              = "10.21.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
 

  tags = {
    Name    = "public-us-east-1a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id                  = aws_vpc.VPC-B-NewYork-Test.id
  cidr_block              = "10.21.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
 

  tags = {
    Name    = "public-us-east-1b"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

# New York Private IP space.

resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.VPC-B-NewYork-Test.id
  cidr_block        = "10.21.11.0/24"
  availability_zone = "us-east-1a"
 

  tags = {
    Name    = "private-us-east-1a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.VPC-B-NewYork-Test.id
  cidr_block        = "10.21.12.0/24"
  availability_zone = "us-east-1b"
 

  tags = {
    Name    = "private-us-east-1b"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

#---------------------------------------------------------#
# IGW

resource "aws_internet_gateway" "igw_NY" {
  vpc_id = aws_vpc.VPC-B-NewYork-Test.id

  tags = {
    Name    = "application_NY_IGW"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}


#-----------------------------------------------#
# NAT

resource "aws_eip" "eip_NY" {
  vpc = true
 

  tags = {
    Name = "eip_NY"
  }
}


resource "aws_nat_gateway" "nat_NY" {
  allocation_id = aws_eip.eip_NY.id
  subnet_id     = aws_subnet.public-us-east-1a.id
 

  tags = {
    Name = "nat_NY"
  }

  depends_on = [aws_internet_gateway.igw_NY]
}



#---------------------------------------------------------------#
# Routes

resource "aws_route_table" "private_NY" {
  vpc_id = aws_vpc.VPC-B-NewYork-Test.id  
  route  {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat_NY.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      #instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }

  tags = {
    Name = "private_NY"
  }

}

resource "aws_route_table" "public_NY" {
  vpc_id = aws_vpc.VPC-B-NewYork-Test.id

  route   {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw_NY.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      #instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
    tags = {
    Name = "public_NY"
  }
}

#-----------------------------------------------#
#
# These are for the private subnets.

resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.private_NY.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id      = aws_subnet.private-us-east-1b.id
  route_table_id = aws_route_table.private_NY.id
}

#-----------------------------------------------#
#
# These are for the public subnets.

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.public_NY.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id      = aws_subnet.public-us-east-1b.id
  route_table_id = aws_route_table.public_NY.id
}



#----------------------------------------------------#
# Security Groups

# Security group for Load Balancer

resource "aws_security_group" "ASG01-SG01-NY-LB01" {
    name = "ASG01-SG01-NY-LB01"
    description = "Allow HTTP inbound traffic to Load Balancer."
    vpc_id = aws_vpc.VPC-B-NewYork-Test.id
   

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

   egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "ASG01-SG01-NY-LB01"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security Group for Automatic Scaling Group
resource "aws_security_group" "ASG01-SG02-NY-TG80" {
    name = "ASG01-SG02-NY-TG80"
    description = "allow traffic to ASG"
    vpc_id = aws_vpc.VPC-B-NewYork-Test.id
   

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }

      tags = {
        Name = "ASG01-SG02-NY-TG80"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security group for EC2 Virtual Machines
resource "aws_security_group" "ASG01-SG03-NY-servers" {
    name = "ASG01-SG03-NY-servers"
    description = "Allow SSH and HTTP traffic to production servers"
    vpc_id = aws_vpc.VPC-B-NewYork-Test.id
   

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
         cidr_blocks = ["10.0.0.0/8"]
    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "ASG01-SG03-NY-servers"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}











