output "kms_key"{
        value = aws_kms_key.kms_key.key_id
}

output "kms_arn"{
        value = aws_kms_key.kms_key.arn
}
