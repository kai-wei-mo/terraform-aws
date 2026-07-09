# --- SNS topic for billing / cost alerts --------------------------------------

resource "aws_sns_topic" "billing_alerts" {
  name = "billing-alerts"
}

resource "aws_sns_topic_subscription" "billing_email" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = local.alert_email
}

# SNS topic policy so AWS Budgets and Cost Anomaly Detection can publish.
data "aws_caller_identity" "current" {}

resource "aws_sns_topic_policy" "billing_alerts" {
  arn = aws_sns_topic.billing_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBudgetsPublish"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.billing_alerts.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowCostAnomalyPublish"
        Effect = "Allow"
        Principal = {
          Service = "costalerts.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.billing_alerts.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowCloudWatchPublish"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.billing_alerts.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
    ]
  })
}

# --- Monthly account budget (actual + forecast, staged thresholds) ------------

resource "aws_budgets_budget" "monthly_cost_budget" {
  name         = "monthly-budget"
  budget_type  = "COST"
  limit_amount = local.monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "notification" {
    for_each = [
      { threshold = 25, type = "ACTUAL" },
      { threshold = 50, type = "ACTUAL" },
      { threshold = 100, type = "ACTUAL" },
      { threshold = 80, type = "FORECASTED" },
      { threshold = 100, type = "FORECASTED" },
    ]
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value.threshold
      threshold_type             = "PERCENTAGE"
      notification_type          = notification.value.type
      subscriber_email_addresses = [local.alert_email]
      subscriber_sns_topic_arns  = [aws_sns_topic.billing_alerts.arn]
    }
  }
}

# --- Daily budget: catches sudden spikes within the month ---------------------

resource "aws_budgets_budget" "daily_cost" {
  name         = "daily-total"
  budget_type  = "COST"
  limit_amount = local.daily_budget_usd
  limit_unit   = "USD"
  time_unit    = "DAILY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [local.alert_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.billing_alerts.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [local.alert_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.billing_alerts.arn]
  }
}

# --- Cost Anomaly Detection (ML-based unusual spend per service) --------------

resource "aws_ce_anomaly_monitor" "services" {
  name              = "service-level-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "alerts" {
  name      = "billing-anomaly-alerts"
  frequency = "IMMEDIATE"

  monitor_arn_list = [aws_ce_anomaly_monitor.services.arn]

  # IMMEDIATE allows only one subscriber; email arrives via the SNS topic.
  subscriber {
    type    = "SNS"
    address = aws_sns_topic.billing_alerts.arn
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [local.anomaly_impact_usd]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}

# --- CloudWatch EstimatedCharges (near-real-time MTD signal) ------------------
# Billing metrics are only published in us-east-1. Enable "Receive Billing Alerts"
# in the Billing console (Account preferences) once if not already on.

resource "aws_cloudwatch_metric_alarm" "estimated_charges" {
  for_each = local.estimated_charge_alarms

  alarm_name          = "estimated-charges-${each.key}"
  alarm_description   = format("Month-to-date estimated charges exceeded $%s (%s)", each.value, each.key)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600 # 6 hours
  statistic           = "Maximum"
  threshold           = each.value
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]
  ok_actions    = [aws_sns_topic.billing_alerts.arn]
}
