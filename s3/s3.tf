resource "aws_s3_bucket" "multicloud_s3_bucket" {
    bucket        = "multicloud.${var.client}.devops"
    acl           = "private"
    force_destroy = true

    versioning {
        enabled = true
   }

    tags= {
        Name     = "${var.client}_${var.region}_bucket"
        customer = var.client
    }
    
    server_side_encryption_configuration {
       rule {
         apply_server_side_encryption_by_default {
            sse_algorithm     = "aws:kms"
             }
           }
      }
}
