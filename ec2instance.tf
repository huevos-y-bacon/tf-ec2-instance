# QUICK EC2 INSTANCE WITH SSM SM AND EC2 ROLE

provider "aws" {
  region = "us-east-1"
}

locals {
  # DONT ADD HERE - run get_vpc_and_subnet.sh to get these values
  # included in vpc_subnet.tf: vpc_id, subnet_id, subnet_name

  name          = "${local.name_prefix}-${local.subnet_name}"
  instance_type = "t3.medium"
  ami           = data.aws_ami.amazon-linux-2.id

  user_data = <<EOF
#!/bin/bash
sudo yum update -y
# sudo yum install docker nc -y
sudo wget https://www.vdberg.org/~richard/tcpping --no-check-certificate
sudo mv tcpping /usr/bin/
sudo chmod 755 /usr/bin/tcpping
sudo wall "user_data script complete. tcping installed"
EOF

}

variable "attach_instance_profile" {
  description = "Set to true to create an IAM Instance profile and attach to EC2"
  type        = bool
  default     = true
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}

resource "aws_iam_role" "foo" {
  name_prefix        = "${local.name}-"
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

resource "aws_iam_role_policy_attachment" "foo" {
  role       = aws_iam_role.foo.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "foo" {
  count       = var.attach_instance_profile ? 1 : 0
  name_prefix = "${local.name}-"
  role        = aws_iam_role.foo.name
}

resource "aws_instance" "foo" {
  ami                    = local.ami
  instance_type          = local.instance_type
  subnet_id              = local.subnet_id
  iam_instance_profile   = var.attach_instance_profile ? aws_iam_instance_profile.foo[0].name : null
  vpc_security_group_ids = [aws_security_group.foo.id]
  user_data_base64       = base64encode(local.user_data)

  metadata_options {
    http_tokens = "required" # Enforce IMDSv2; see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
  }

  tags = {
    Name      = local.name
    Terraform = true
  }

}

output "instance_id" {
  value = aws_instance.foo.id
}

output "instance_name" {
  value = local.name
}

resource "aws_security_group" "foo" {
  name_prefix = "${local.name}-"
  description = local.name
  vpc_id      = local.vpc_id

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
}
