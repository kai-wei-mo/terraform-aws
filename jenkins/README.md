# jenkins

IAM + agent security for Jenkins EC2 agents launched from the homelab controller.

Creates:

- IAM user + access key for the Jenkins EC2 plugin
- IAM role + instance profile attached to launched agents
- SSH key pair (Terraform-generated) for controller → agent SSH
- Security group (SSH :22 from Tailscale `100.64.0.0/10`, egress all)

Networking (VPC, subnets, NAT) lives in [`../vpc/jenkins-agents/`](../vpc/jenkins-agents/).
Apply **vpc/jenkins-agents** first.

Tailscale auth keys are **not** managed here — seal them in `homelab-core-infra/jenkins/`.

## Connectivity-test AMI (not for builds)

`data.aws_ami.connectivity_test` looks up the latest **stock Canonical Ubuntu 24.04**
image and exposes it as `connectivity_test_ami_id`. That ID is wired into the Jenkins
**`litmus`** EC2 template so you can smoke-test:

- EC2 launch + private subnet + NAT
- Tailscale join and VPC route advertisement
- Controller → agent SSH over the tailnet
- Agent remoting to `jenkins.home.chaewon.io`

It is **not** a build image — no Docker, JDK, or other CI tooling. For real pipelines,
add a separate AMI or EC2 template (Packer, custom userdata, etc.) and leave `litmus`
as the cheap connectivity check.

## Apply

```bash
cd ../vpc/jenkins-agents
eval "$(aws configure export-credentials --format env)"   # if using aws login
terraform init
terraform apply

cd ../../jenkins
terraform init
terraform apply
```

If VPC resources were previously in this stack, see [`../vpc/README.md`](../vpc/README.md)
for one-time state migration before applying.

## Seal outputs into homelab Jenkins

From `homelab-core-infra/jenkins/` after apply (do not commit plaintext):

```bash
# AWS provisioner keys
AK=$(terraform -chdir=../../terraform-aws/jenkins output -raw access_key_id)
SK=$(terraform -chdir=../../terraform-aws/jenkins output -raw secret_access_key)
kubectl create secret generic jenkins-aws -n jenkins \
  --from-literal=access-key-id="$AK" \
  --from-literal=secret-access-key="$SK" \
  --dry-run=client -o yaml | kubeseal -o yaml > sealed-jenkins-aws.yaml
unset AK SK

# SSH private key
terraform -chdir=../../terraform-aws/jenkins output -raw ssh_private_key \
  > /tmp/jenkins-ec2-ssh.pem
chmod 600 /tmp/jenkins-ec2-ssh.pem
kubectl create secret generic jenkins-ec2-ssh -n jenkins \
  --from-file=ssh-private-key=/tmp/jenkins-ec2-ssh.pem \
  --dry-run=client -o yaml | kubeseal -o yaml > sealed-jenkins-ec2-ssh.yaml
rm -f /tmp/jenkins-ec2-ssh.pem
```

Then fill these into `values-custom.yaml` JCasC placeholders and regen `install.yaml`:

```bash
terraform -chdir=../../terraform-aws/jenkins output -raw connectivity_test_ami_id
terraform -chdir=../../terraform-aws/jenkins output -raw security_group_id
terraform -chdir=../../terraform-aws/jenkins output -raw subnet_id
terraform -chdir=../../terraform-aws/jenkins output -raw instance_profile_arn
```

See `homelab-core-infra/jenkins/README.md` for the full Jenkins wiring.
