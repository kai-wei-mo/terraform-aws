# Immich backup

Two private S3 buckets for restic backups of the homelab Immich instances. The CronJobs that write to them live in `homelab-core-infra` (`immich/` and `immich-private/`).

| Bucket | IAM user | Library |
|---|---|---|
| `kwm-immich-backup` | `immich-backup` | `/var/lib/immich` |
| `kwm-immich-private-backup` | `immich-private-backup` | `/var/lib/immich2` and `/mnt/seagate/immich2` |

## Apply

```bash
terraform init
terraform plan
terraform apply
terraform output -json access_keys
```

`access_keys` prints `immich` and `immich_private`, each with `id` (`AWS_ACCESS_KEY_ID`) and `secret` (`AWS_SECRET_ACCESS_KEY`). Put those in the sealed secrets described in the homelab Immich READMEs.

The bucket cannot be restored without `RESTIC_PASSWORD`.
