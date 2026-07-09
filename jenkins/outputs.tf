output "access_key_id" {
  description = "IAM access key ID for the Jenkins EC2 plugin (seal into jenkins-aws)"
  value       = aws_iam_access_key.provisioner.id
}

output "secret_access_key" {
  description = "IAM secret access key for the Jenkins EC2 plugin (seal into jenkins-aws)"
  value       = aws_iam_access_key.provisioner.secret
  sensitive   = true
}

output "ssh_private_key" {
  description = "SSH private key for connecting to agents (seal into jenkins-ec2-ssh)"
  value       = tls_private_key.agent.private_key_openssh
  sensitive   = true
}

output "key_name" {
  description = "EC2 key pair name"
  value       = aws_key_pair.agent.key_name
}

output "vpc_id" {
  description = "Dedicated agent VPC ID (from vpc stack)"
  value       = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "security_group_id" {
  description = "Security group ID for agents (use in JCasC securityGroups)"
  value       = aws_security_group.agent.id
}

output "subnet_id" {
  description = "Private subnet for agents (use in JCasC subnetId)"
  value       = data.terraform_remote_state.vpc.outputs.private_subnet_id
}

output "instance_profile_arn" {
  description = "Instance profile ARN for agents (use in JCasC iamInstanceProfile)"
  value       = aws_iam_instance_profile.agent.arn
}

output "instance_profile_name" {
  description = "Instance profile name"
  value       = aws_iam_instance_profile.agent.name
}

# --- Smoke test ---

output "connectivity_test_ami_id" {
  description = "Stock Ubuntu 24.04 AMI for the litmus EC2 template only — smoke-test connectivity, not build workloads"
  value       = data.aws_ami.connectivity_test.id
}
