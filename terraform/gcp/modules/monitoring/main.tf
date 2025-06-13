resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Channel"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

# Disk usage
resource "google_monitoring_alert_policy" "disk_usage" {
  display_name = "Disk Usage Alert"
  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]
  conditions {
    display_name = "Disk Utilization > disk_usage_threshold%"
    condition_threshold {
      filter          = "metric.type=\"agent.googleapis.com/disk/percent_used\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.disk_usage_threshold
      duration        = "60s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}

# Memory usage
resource "google_monitoring_alert_policy" "memory_usage" {
  display_name = "Memory Usage Alert"
  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]
  conditions {
    display_name = "Memory Usage > memory_usage_threshold%"
    condition_threshold {
      filter          = "metric.type=\"agent.googleapis.com/memory/percent_used\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.memory_usage_threshold
      duration        = "60s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}

# Network outbound
resource "google_monitoring_alert_policy" "network_out" {
  display_name = "High Network Outbound Alert"
  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]
  conditions {
    display_name = "Network Outbound > network_outbound_threshold bytes/min"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/network/sent_bytes_count\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.network_outbound_threshold
      duration        = "60s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}

# CPU usage
resource "google_monitoring_alert_policy" "cpu_usage" {
  display_name = "High CPU Usage Alert"
  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]
  conditions {
    display_name = "CPU Usage > cpu_usage_threshold%"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.cpu_usage_threshold / 100
      duration        = "60s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}

# Swap usage
# resource "google_monitoring_alert_policy" "swap_usage" {
#   display_name = "Swap Usage Alert"
#   combiner               = "OR"
#   notification_channels  = [google_monitoring_notification_channel.email.id]
#   conditions {
#     display_name = "Swap Usage > swap_usage_threshold%"
#     condition_threshold {
#       filter          = "metric.type=\"agent.googleapis.com/memory/swap_percent_used\" AND resource.type=\"gce_instance\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = var.swap_usage_threshold
#       duration        = "60s"
#       aggregations {
#         alignment_period     = "60s"
#         per_series_aligner   = "ALIGN_MEAN"
#         cross_series_reducer = "REDUCE_NONE"
#       }
#     }
#   }
# }

# Processes count
# resource "google_monitoring_alert_policy" "processes" {
#   display_name = "Processes Count Alert"
#   combiner               = "OR"
#   notification_channels  = [google_monitoring_notification_channel.email.id]
#   conditions {
#     display_name = "Processes > processes_threshold"
#     condition_threshold {
#       filter          = "metric.type=\"agent.googleapis.com/processes/process_count\" AND resource.type=\"gce_instance\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = var.processes_threshold
#       duration        = "60s"
#       aggregations {
#         alignment_period     = "60s"
#         per_series_aligner   = "ALIGN_MEAN"
#         cross_series_reducer = "REDUCE_NONE"
#       }
#     }
#   }
# }

# Agent self metrics (example: agent CPU usage)
resource "google_monitoring_alert_policy" "agent_self" {
  display_name = "Agent Self Metric Alert"
  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]
  conditions {
    display_name = "Agent CPU Usage > agent_self_threshold%"
    condition_threshold {
      filter          = "metric.type=\"agent.googleapis.com/agent/cpu_percent\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.agent_self_threshold
      duration        = "60s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}

# GPU usage
resource "google_monitoring_alert_policy" "gpu_usage" {
  display_name = "GPU Usage Alert"
  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]
  conditions {
    display_name = "GPU Usage > gpu_usage_threshold%"
    condition_threshold {
      filter          = "metric.type=\"agent.googleapis.com/gpu/utilization\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.gpu_usage_threshold
      duration        = "60s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}

# Network interface usage
resource "google_monitoring_alert_policy" "network_interface_usage" {
  display_name = "Network Interface Usage Alert"
  combiner               = "OR"
  notification_channels  = [google_monitoring_notification_channel.email.id]
  conditions {
    display_name = "Network Interface Usage > network_interface_usage_threshold bytes/min"
    condition_threshold {
      filter          = "metric.type=\"agent.googleapis.com/interface/bytes_sent\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.network_interface_usage_threshold
      duration        = "60s"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
}
