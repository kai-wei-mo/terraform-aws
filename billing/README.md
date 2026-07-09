# Billing

Layered AWS cost alerting (stays within the **2 free AWS Budgets**):

| Layer | What it catches | Cost |
| --- | --- | --- |
| Monthly total budget | Gradual overspend (25/50/100% actual + 80/100% forecast) | Free |
| Daily budget | Sudden same-day spikes | Free |
| Cost Anomaly Detection | Unusual per-service patterns vs baseline (ML, immediate) | Free |
| CloudWatch EstimatedCharges | Near-real-time month-to-date charge thresholds | Free |

Alerts go to email (`kaiweimo5@gmail.com`) and the `billing-alerts` SNS topic.

Extra per-service budgets (EC2/S3/etc.) cost ~$0.10/day each; anomaly detection
covers that surface without the fee. Raise ceilings in `locals.tf`.

## One-time console step

CloudWatch billing metrics require **Receive Billing Alerts** enabled under
Billing → Billing preferences. Without that, the EstimatedCharges alarms stay
quiet.

Confirm the SNS email subscription after the first apply.

```bash
terraform init
terraform plan
terraform apply
```
