# vpc

Reusable VPC layouts. Each subdirectory is a **standalone root module** with its
own remote state under `vpc/<name>`.

## Layout

```
vpc/
  modules/network/     # shared: VPC + public/private subnets + NAT
  jenkins-agents/      # first VPC instance (Jenkins EC2 agents)
  <future-vpc>/        # copy jenkins-agents/, set CIDRs + backend key
```

## Add a new VPC

1. Copy `jenkins-agents/` to `vpc/<name>/`.
2. Set `locals` (CIDRs, AZ, name) and the S3 backend `key` in `versions.tf`
   (`vpc/<name>`).
3. `terraform init && terraform apply` from the new directory.

Consumers read outputs via `terraform_remote_state` using the matching state key.

## jenkins-agents

Apply before [`jenkins/`](../jenkins/):

```bash
cd vpc/jenkins-agents
eval "$(aws configure export-credentials --format env)"   # if using aws login
terraform init
terraform apply
```

## Migrate from jenkins or flat `vpc` state

If VPC resources already exist in another state, move them into
`vpc/jenkins-agents` instead of recreating. After pulling both state files, remap
addresses into the module (example for VPC):

```bash
terraform state mv \
  -state=/tmp/jenkins.tfstate \
  -state-out=/tmp/vpc-jenkins-agents.tfstate \
  aws_vpc.agent module.network.aws_vpc.this
```

Repeat for each resource (`aws_internet_gateway.agent` →
`module.network.aws_internet_gateway.this`, etc.). See
[`jenkins-agents/README.md`](jenkins-agents/README.md) for the full list.

If you previously used backend key `vpc` (flat root), re-init with
`-migrate-state` into `vpc/jenkins-agents` or move the S3 object to
`vpc/jenkins-agents`.
