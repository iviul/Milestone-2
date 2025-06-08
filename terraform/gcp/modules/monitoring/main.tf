resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Channel"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

# Disk usage > 80%
resource "google_monitoring_alert_policy" "disk_usage" {
  display_name = "Disk Usage Alert"

  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]

  conditions {
    display_name = "Disk Utilization > 80%"
    condition_threshold {
      filter          = "metric.type=\"agent.googleapis.com/disk/percent_used\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 80
      duration        = "60s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}

# Memory usage > 80%
resource "google_monitoring_alert_policy" "memory_usage" {
  display_name = "Memory Usage Alert"

  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]

  conditions {
    display_name = "Memory Usage > 80%"
    condition_threshold {
      filter          = "metric.type=\"agent.googleapis.com/memory/percent_used\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 80
      duration        = "60s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}

# Network traffic > 1 GB/min 
resource "google_monitoring_alert_policy" "network_out" {
  display_name = "High Network Outbound Alert"

  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]

  conditions {
    display_name = "Network Outbound > 1GB/min"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/network/sent_bytes_count\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 1073741824
      duration        = "60s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}
