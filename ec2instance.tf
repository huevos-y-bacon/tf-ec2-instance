# EC2 INSTANCE WITH SSM SM AND EC2 ROLE
locals {
  # DONT ADD VPC INFO HERE - run bin/prep.sh to set these values:
  # included in terraform.tfvars: var.name_prefix var.vpc_id, var.subnet_id, var.name_prefix, var.vpc_id

  name = var.purpose == null ? "${var.name_prefix}-${random_string.foo.id}" : "${var.name_prefix}-${var.purpose}-${random_string.foo.id}"
  arch = var.graviton ? "arm64" : "x86_64"
  ami  = var.linux_version == "al2023" ? data.aws_ami.al2023.id : var.linux_version == "al2" ? data.aws_ami.al2.id : data.aws_ami.ubuntu22.id

  instance_type = var.graviton ? "t4g.${var.size}" : "t3.${var.size}"

  user_data = var.linux_version == "al2023" || var.linux_version == "al2" ? file("${path.module}/user_data.sh") : file("${path.module}/user_data_apt.sh")

}

# Random string to ensure unique names without using the name_prefix
resource "random_string" "foo" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_iam_role" "foo" {
  name               = local.name
  path               = "/"
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Sid": ""
        }
      ]
    }
    EOF
  tags = {
    Name      = local.name
    Terraform = true
  }
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  count      = var.attach_ssm_instance_core_access ? 1 : 0
  role       = aws_iam_role.foo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ReadOnlyAccess" {
  count      = var.attach_read_only_access ? 1 : 0
  role       = aws_iam_role.foo.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforSSM" {
  count      = var.attach_ec2_role_for_ssm_access ? 1 : 0
  role       = aws_iam_role.foo.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "s3full" {
  count      = var.attach_s3_full_access ? 1 : 0
  role       = aws_iam_role.foo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "foo" {
  count       = var.attach_instance_profile ? 1 : 0
  name_prefix = "${local.name}-"
  role        = aws_iam_role.foo.name
}

resource "aws_instance" "foo" {
  ami                    = local.ami
  instance_type          = local.instance_type
  subnet_id              = var.subnet_id
  iam_instance_profile   = var.attach_instance_profile ? aws_iam_instance_profile.foo[0].name : null
  vpc_security_group_ids = [aws_security_group.foo.id]
  user_data_base64       = base64encode(local.user_data)

  key_name = var.key_name != null ? var.key_name : null # if key_name is not set, do not set key_name

  root_block_device {
    volume_size = var.root_vol.size
    volume_type = var.root_vol.type
    encrypted   = false # for now
  }

  # THIS REQUIRES FURTHER WORK 
  # - E.G. MOUNTING, FORMATTING, ETC. 
  # - Create as separate resource to avoid for recreate, i.e. can be created after instance is created?
  dynamic "ebs_block_device" {
    for_each = var.ebs_vol.size > 0 ? [var.ebs_vol] : []
    content {
      device_name = ebs_block_device.value.device_name
      volume_size = ebs_block_device.value.size
      volume_type = ebs_block_device.value.type
      encrypted   = false # for now
    }
  }

  metadata_options {
    http_tokens = "required" # Enforce IMDSv2; see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
  }

  tags = {
    Name      = local.name
    Terraform = true
  }

  lifecycle { ignore_changes = [ami] }
}

resource "aws_security_group" "foo" {
  name        = local.name
  description = local.name
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = local.name
    Terraform = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh_from_my_ip" {
  count = var.ssh_from_my_ip ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
  description       = "ssh from my ip"
  security_group_id = aws_security_group.foo.id
}

resource "aws_eip" "foo" {
  count    = var.attach_eip ? 1 : 0
  instance = aws_instance.foo.id
  domain   = "vpc"

  tags = {
    Name = local.name
  }
}
