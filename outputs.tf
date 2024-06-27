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
  value = local.ami
}

output "ami_arch" {
  value = local.arch
}

output "private_ip" {
  value = aws_instance.foo.private_ip
}

output "public_eip" {
  value = var.attach_eip ? aws_eip.foo[0].public_ip : null
}
