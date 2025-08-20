output "bucket_arns" {
  value = {
    for bucket_name, mod in module.s3_buckets :
    bucket_name => mod.bucket_arn
  }
}

output "bucket_ids" {
  value = {
    for bucket_name, mod in module.s3_buckets :
    bucket_name => mod.bucket_id
  }
}
