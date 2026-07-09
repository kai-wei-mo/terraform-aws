data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "kwm-terraform-state"
    key    = "vpc/jenkins"
    region = "us-east-1"
  }
}

# Smoke test for SSH and Tailscale. Not intended for running builds.
data "aws_ami" "connectivity_test" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}
