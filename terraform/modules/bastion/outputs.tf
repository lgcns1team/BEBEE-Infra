output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  description = "Bastion Host Security Group ID"
  value       = aws_security_group.bastion_sg.id
}

output "private_key_path" {
  description = "접속용 Private Key 파일 경로"
  value       = local_file.private_key_file.filename
}

output "key_pair_name" {
  description = "SSH Key Pair 이름"
  value       = aws_key_pair.bastion_key.key_name
}
