locals {
  aws_region  = "us-east-1"
  alert_email = "kaiweimo5@gmail.com"

  # Two budgets stay in the AWS Budgets free tier
  # Additional budgets cost ~$0.10/day each.
  monthly_budget_usd = "25"
  daily_budget_usd   = "3"

  # CloudWatch EstimatedCharges thresholds (USD, month-to-date).
  estimated_charge_alarms = {
    warning  = 15
    critical = 25
  }

  # Cost Anomaly Detection: alert when absolute impact exceeds this (USD).
  # Service-dimensional monitor covers EC2/S3/transfer/etc. without paid budgets.
  anomaly_impact_usd = "5"
}
