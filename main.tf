data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_instance" "tfvm" {
   ami = "ami-06c5d9a9a4ec13397"
  #  ami = "ami-0feecc3445c841896"

  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [ aws_security_group.websg.id ]
  user_data = <<-EOF
                #!/bin/bash
                echo "MC VM demo" > index.html
                nohup busybox httpd -f -p 80 &
                EOF
    tags = {
      Name = "VM-demo"
    }
}

resource "aws_eip" "tfvm" {
  vpc = true
}

resource "aws_eip_association" "eip_bastion" {
  instance_id = aws_instance.tfvm.id
  allocation_id = aws_eip.tfvm.id
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.client}-vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
vpc_id = aws_vpc.vpc.id
 tags= {
    Name = "${var.client}-internet_gateway"
  }
lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 148)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = var.client
       }
}

resource "aws_route_table" "route_table_public" {
  depends_on = [aws_internet_gateway.internet_gateway]
  vpc_id     = aws_vpc.vpc.id

  tags = {
    Name = "${var.client}-route-table-public"
    }
}

resource "aws_route" "route_table_public" {
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
  depends_on             = [aws_route_table.route_table_public]
}

resource "aws_route_table_association" "route_table_association_zone_1" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_main_route_table_association" "route_table_main" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_security_group" "websg" {
  name = "web-sg01"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

   egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_flow_log" "clove_flowlogs" {
  iam_role_arn    = aws_iam_role.clove_flowlogs.arn
  log_destination = aws_cloudwatch_log_group.clove_flowlogs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}

resource "aws_cloudwatch_log_group" "clove_flowlogs" {
  name = "${var.client}.clove_flowlogs"
}

resource "aws_iam_role" "clove_flowlogs" {
  name = "${var.client}.clove_flowlogs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "clove_flowlogs" {
  name = "${var.client}.clove_flowlogs"
  role = aws_iam_role.clove_flowlogs.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
