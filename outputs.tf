# outputs.tf
output "instance_id" {
  value = aws_instance.foo.id
}

output "instance_name" {
  value = local.name
}

output "instance_type" {
  value = local.instance_type
}

output "ami" {
  value = aws_instance.foo.ami
}

output "ami_arch" {
  value = local.arch
}

output "private_ip" {
  value = aws_instance.foo.private_ip
}

output "public_ip" {
  value = var.attach_eip ? aws_eip.foo[0].public_ip : aws_instance.foo.public_ip
}

output "public_ip_is_eip" {
  value = var.attach_eip
}

output "ssh_from_my_ip" {
  value = var.ssh_from_my_ip ? var.ssh_from_my_ip : null
}

output "my_ip" {
  value = var.ssh_from_my_ip ? chomp(data.http.myip.response_body) : null
}

output "key_name" {
  value = var.key_name != "" ? var.key_name : null
}
