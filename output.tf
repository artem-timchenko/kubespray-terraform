output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "master_private_ip" {
  value = aws_instance.master.private_ip
}

output "slave_private_ips" {
  value = aws_instance.slave[*].private_ip
}
