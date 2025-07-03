resource "google_monitoring_notification_channel" "channels" {
  for_each     = { for nc in var.notification_channels : nc.name => nc }
  display_name = each.value.name
  type         = each.value.type
  labels       = each.value.labels
}

resource "google_logging_metric" "log_metrics" {
  for_each    = { for m in var.log_based_metrics : m.name => m }
  name        = each.value.name
  description = each.value.description
  filter      = each.value.filter
  metric_descriptor {
    metric_kind = each.value.metric_kind
    value_type  = each.value.value_type
    unit        = each.value.unit
  }
}

resource "google_monitoring_alert_policy" "custom" {
  for_each = { for ap in var.alert_policies : ap.name => ap }
  display_name          = each.value.name
  combiner              = each.value.combiner
  notification_channels = [for nc in google_monitoring_notification_channel.channels : nc.id]

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.name
      condition_threshold {
        filter          = conditions.value.metric_filter
        comparison      = conditions.value.comparison
        threshold_value = conditions.value.threshold
        duration        = conditions.value.duration
        aggregations {
          alignment_period   = "60s"
          per_series_aligner = conditions.value.aligner
        }
      }
    }
  }
}
