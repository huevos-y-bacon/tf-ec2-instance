# variables.tf
variable "purpose" {
  description = "name prefix"
  type        = string
  default     = null
}

variable "attach_instance_profile" {
  description = "Set to true to create an IAM Instance profile and attach to EC2"
  type        = bool
  default     = true
}

variable "attach_read_only_access" {
  description = "Set to true to attach ReadOnlyAccess policy to EC2 role"
  type        = bool
  default     = true
}

variable "attach_ssm_instance_core_access" {
  description = "Set to true to attach AmazonSSMManagedInstanceCore policy to EC2 role"
  type        = bool
  default     = true
}

variable "attach_ec2_role_for_ssm_access" {
  description = "Set to true to attach AmazonEC2RoleforSSM policy to EC2 role"
  type        = bool
  default     = false
}

variable "attach_s3_full_access" {
  description = "Set to true to attach AmazonS3FullAccess policy to EC2 role"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "If null, it won't set key_name"
  type        = string
  default     = null
}

variable "graviton" {
  description = "graviton? true or false"
  type        = string
  default     = true
}

variable "size" { # t-shirt size
  description = "nano, micro, small, medium, large, etc"
  type        = string
  default     = "micro" # micro is free tier eligible
}

data "aws_ami" "foo" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = [local.arch]
  }
}

# data "http" "myip" {
#   url = "https://wtfismyip.com/text"
# }
