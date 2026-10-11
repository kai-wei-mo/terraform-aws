locals {
  aws_region = "us-east-1"

  buckets = {
    immich = {
      bucket   = "kwm-immich-backup"
      iam_user = "immich-backup"
      instance = "immich"
    }
    immich_private = {
      bucket   = "kwm-immich-private-backup"
      iam_user = "immich-private-backup"
      instance = "immich-private"
    }
  }
}
