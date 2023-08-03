# Add security group to target SG, create NACL entries for target and source, etc

# locals {
# target_sg       = "sg-112233445566"     # datadev - TARGET sg
# vpc_cidr        = "172.32.0.0/16"             # datadev
# target_sn1      = "subnet-112233445566" # datadev TARGET sn
# target_endpoint = "rdsendpointname.cfqq19fdisv2.us-east-1.rds.amazonaws.com"
# target_port     = 443 # 443
# }

# data "aws_network_acls" "foo" {
#   vpc_id = local.vpc_id

#   filter {
#     name   = "association.subnet-id"
#     values = [local.subnet_id]
#   }
# }

# data "aws_network_acls" "target" {
#   vpc_id = local.vpc_id

#   filter {
#     name   = "association.subnet-id"
#     values = [local.target_sn1]
#   }
# }

# resource "aws_security_group_rule" "foo" {
#   security_group_id        = local.target_sg
#   type                     = "ingress"
#   protocol                 = "tcp"
#   from_port                = local.target_port
#   to_port                  = local.target_port
#   source_security_group_id = aws_security_group.foo.id
#   description              = "tcp/${local.target_port} from ${local.name}"
# }

# resource "random_integer" "target_out" {
#   min = 16000
#   max = 32000
# }

# resource "random_integer" "target_in" {
#   min = 16000
#   max = 32000
# }

# resource "random_integer" "out" {
#   min = 16000
#   max = 32000
# }

# resource "random_integer" "in" {
#   min = 16000
#   max = 32000
# }

# resource "aws_network_acl_rule" "target_in" {
#   network_acl_id = data.aws_network_acls.target.ids[0]
#   rule_number    = random_integer.target_in.id
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.vpc_cidr
#   from_port      = local.target_port
#   to_port        = local.target_port
# }

# resource "aws_network_acl_rule" "target_out" {
#   network_acl_id = data.aws_network_acls.target.ids[0]
#   rule_number    = random_integer.target_out.id
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.vpc_cidr
#   from_port      = 1024
#   to_port        = 65535
# }

# resource "aws_network_acl_rule" "in" {
#   network_acl_id = data.aws_network_acls.foo.ids[0]
#   rule_number    = random_integer.in.id
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.vpc_cidr
#   from_port      = 1024
#   to_port        = 65535
# }

# resource "aws_network_acl_rule" "out" {
#   network_acl_id = data.aws_network_acls.foo.ids[0]
#   rule_number    = random_integer.out.id
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = local.vpc_cidr
#   from_port      = local.target_port
#   to_port        = local.target_port
# }
