module "s3_buckets" {
  source = "./modules/s3_bucket"

  for_each = toset(var.bucket_names)

  bucket_name = each.value
}
