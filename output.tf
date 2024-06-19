output "instance_ips" {
  value = aws_eip.tfvm.public_ip
}