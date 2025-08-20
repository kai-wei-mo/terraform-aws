# Photography

S3 buckets for large camera photo albums (offloaded from Apple Photos).

## Setup

Bucket names are not stored in git. Copy the example and add your albums locally:

```bash
cp bucket_names.auto.tfvars.example bucket_names.auto.tfvars
# edit bucket_names.auto.tfvars
```

## Usage

```bash
terraform init
terraform apply
```
