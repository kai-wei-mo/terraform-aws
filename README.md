# terraform-aws

Personal AWS infrastructure managed with Terraform. Each top-level directory is a standalone root module with its own state.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) (1.5+)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with credentials for the target account
- [pre-commit](https://pre-commit.com/) (optional, for formatting hooks)

```bash
brew install terraform pre-commit
pre-commit install   # from repo root
```

## Bootstrap order

Most stacks use **remote state** in S3 with DynamoDB locking. Set that up once before applying anything else.

| Step | Directory | State | Purpose |
|------|-----------|-------|---------|
| 1 | [`terraform-bootstrap/`](terraform-bootstrap/) | Local | Create S3 bucket `kwm-terraform-state` and DynamoDB table `kwm-terraform-state-locks` |
| 2 | Any other stack | Remote (S3) | `terraform init` then `terraform apply` |

```bash
cd terraform-bootstrap
terraform init && terraform apply
```

After bootstrap, stacks configure the backend in `versions.tf` (bucket, key, DynamoDB table, `us-east-1`).

### Disaster recovery (CloudFormation)

Use [`terraform-bootstrap-cf/`](terraform-bootstrap-cf/) to recreate the backend and a recovery controller via CloudFormation. See:

- [`terraform-bootstrap-cf/terraform-backend/`](terraform-bootstrap-cf/terraform-backend/)
- [`terraform-bootstrap-cf/controller/`](terraform-bootstrap-cf/controller/)
