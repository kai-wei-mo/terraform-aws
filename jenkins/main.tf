# --- Provisioner IAM (Jenkins EC2 plugin) ---

resource "aws_iam_user" "provisioner" {
  name = "${local.name}-provisioner"
}

resource "aws_iam_user_policy" "provisioner" {
  name = "${local.name}-provisioner"
  user = aws_iam_user.provisioner.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2AgentLifecycle"
        Effect = "Allow"
        Action = [
          "ec2:DescribeSpotInstanceRequests",
          "ec2:CancelSpotInstanceRequests",
          "ec2:GetConsoleOutput",
          "ec2:RequestSpotInstances",
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeRegions",
          "ec2:DescribeImages",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:GetPasswordData",
          "iam:ListInstanceProfilesForRole",
          "iam:ListInstanceProfiles",
        ]
        Resource = "*"
      },
      {
        Sid      = "PassAgentRole"
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = [aws_iam_role.agent.arn]
      },
    ]
  })
}

resource "aws_iam_access_key" "provisioner" {
  user = aws_iam_user.provisioner.name
}

# --- Agent instance profile (attached to launched EC2 agents) ---

resource "aws_iam_role" "agent" {
  name = "${local.name}-agent"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "agent" {
  name = "${local.name}-agent"
  role = aws_iam_role.agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DescribeSelf"
      Effect   = "Allow"
      Action   = ["ec2:DescribeInstances", "ec2:DescribeTags"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "agent" {
  name = "${local.name}-agent"
  role = aws_iam_role.agent.name
}

# --- SSH key for Jenkins → agent ---

resource "tls_private_key" "agent" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "agent" {
  key_name   = "${local.name}-agent"
  public_key = tls_private_key.agent.public_key_openssh
}

resource "aws_security_group" "agent" {
  name        = "${local.name}-agent"
  description = "Jenkins EC2 agents: SSH from Tailscale, egress all"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "SSH from Tailscale (Jenkins controller SSHs via advertised VPC routes)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["100.64.0.0/10"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-agent"
  }
}
