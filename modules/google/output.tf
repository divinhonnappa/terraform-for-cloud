
output "google_public_ip" {
  value = contains(var.cloud_platform ,"google") ? "${google_compute_instance.demo_instance[0].network_interface.0.access_config.0.nat_ip}" : ""
}