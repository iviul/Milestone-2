# output "jenkins_instance_public_ip" {
#   description = "The public IP of the Jenkins instance"
#   value       = google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip
# }

output "jenkins_name" {
  value = helm_release.jenkins.name
}
