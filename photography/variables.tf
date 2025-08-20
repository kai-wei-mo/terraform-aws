variable "bucket_names" {
  type        = list(string)
  description = "S3 bucket names for photo albums (set in bucket_names.auto.tfvars, not committed)"
}

variable "iam_read_bucket_names" {
  type        = list(string)
  description = "Subset of bucket_names granted read-only access on the mabel IAM policy"
}
