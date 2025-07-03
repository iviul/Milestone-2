variable "notification_channels" {
  description = "List of notification channels"
  type = list(object({
    name   = string
    type   = string
    labels = map(string)
  }))
  default = []
}

variable "log_based_metrics" {
  description = "List of log-based metrics"
  type = list(object({
    name        = string
    description = string
    filter      = string
    metric_kind = string
    value_type  = string
    unit        = string
  }))
  default = []
}

variable "alert_policies" {
  description = "List of alert policies"
  type = list(object({
    name     = string
    combiner = string
    conditions = list(object({
      name          = string
      metric_filter = string
      threshold     = number
      duration      = string
      comparison    = string
      aligner       = string
    }))
  }))
  default = []
}
