output "buckets" {
  value = {
    for key, bucket in aws_s3_bucket.this : key => bucket.bucket
  }
}

output "iam_users" {
  value = {
    for key, user in aws_iam_user.backup : key => user.name
  }
}

output "access_keys" {
  description = "Restic credentials. The secret is stored in Terraform state."
  sensitive   = true
  value = {
    for key, access_key in aws_iam_access_key.backup : key => {
      id     = access_key.id
      secret = access_key.secret
    }
  }
}
