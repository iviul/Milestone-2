variable "monitoring_config" {
  description = "Monitoring configuration object"
  type = object({
    notification_channels = list(object({
      name        = string
      type        = string
      labels      = map(string)
    }))

    log_based_metrics = list(object({
      name             = string
      description      = string
      filter           = string
      metric_kind      = string
      value_type       = string
      unit             = optional(string, "1")
      label_extractors = optional(map(string), {})
    }))

    alert_policies = list(object({
      name       = string
      combiner   = string
      conditions = list(object({
        name          = string
        metric_filter = string
        threshold     = number
        duration      = string
        comparison    = string
        aligner       = string
      }))
    }))
  })
}
