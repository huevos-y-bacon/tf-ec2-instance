# EC2 INSTANCE WITH SSM SM AND EC2 ROLE

resource "aws_iam_role" "foo" {
  name_prefix        = local.name_prefix
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
  subnet_id              = local.subnet_id
  iam_instance_profile   = var.attach_instance_profile ? aws_iam_instance_profile.foo[0].name : null
  vpc_security_group_ids = [aws_security_group.foo.id]
  user_data_base64       = base64encode(local.user_data)

  key_name = var.key_name != null ? var.key_name : null # if key_name is not set, do not set key_name

  metadata_options {
    http_tokens = "required" # Enforce IMDSv2; see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
  }

  tags = {
    Name      = local.name
    Terraform = true
  }
}

resource "aws_security_group" "foo" {
  name_prefix = "${local.name}-"
  description = local.name
  vpc_id      = local.vpc_id

  #ts:skip=AC_AWS_0319 play account - home access only
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  #   description = "ssh j home"
  # }

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
