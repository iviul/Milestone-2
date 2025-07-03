output "notification_channel_ids" {
  value = [for nc in google_monitoring_notification_channel.channels : nc.id]
}
