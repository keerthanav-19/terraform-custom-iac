
 resource "aws_subnet" "subnet_private1" {
  availability_zone = "${var.region}${var.availability_zone_one}"
  cidr_block  = cidrsubnet(var.vpc_cidr_block, 2, 0)
  vpc_id            = var.vpc
  tags = {
     Name = "${var.client}-private_subnet_1"
  }
}

 resource "aws_subnet" "subnet_private2"{
  availability_zone = "${var.region}${var.availability_zone_two}"
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 2, 1)
  vpc_id            = var.vpc
  tags = {
     Name = "${var.client}-private_subnet_2"
  }
}

resource "aws_subnet" "subnet_public1" {
  availability_zone = "${var.region}${var.availability_zone_one}"
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 2, 2)
  vpc_id            = var.vpc
  tags = {
     Name = "${var.client}-public_subnet_1"
  
  }
}

resource "aws_subnet" "subnet_public2" {
  availability_zone = "${var.region}${var.availability_zone_two}"
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 2, 3)
  vpc_id            = var.vpc
  tags = {
     Name = "${var.client}-public_subnet_2"
  
  }
}


#enabling flow logs
resource "aws_flow_log" "clove_flowlogs" {
  iam_role_arn    = aws_iam_role.clove_flowlogs.arn
  log_destination = aws_cloudwatch_log_group.clove_flowlogs.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc
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
