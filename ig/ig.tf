resource "aws_internet_gateway" "internet_gateway" {
vpc_id = var.vpc
 tags= {
    Name = "${var.client}-internet_gateway"
  }
lifecycle {
    ignore_changes = [
      tags
    ]
  }

}




