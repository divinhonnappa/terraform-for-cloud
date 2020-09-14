locals {
    is_google = contains(var.cloud_platform ,"google") ? 1 : 0
}

resource "google_compute_firewall" "demo_firewall_ingress" {
  count = local.is_google
  name    = "demo-terraform-firewall-ingress"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = var.google_firewall_port_ingress
  }
  source_ranges = var.google_ip_source_range_ingress
  direction = "INGRESS"
}

resource "google_compute_firewall" "demo_firewall_egress" {
  count = local.is_google
  name    = "demo-terraform-firewall-egress"
  project = var.google_project_id
  network = "default"
  direction   = "EGRESS"
  allow {
    protocol = "tcp"
    ports = var.google_firewall_port_egress
  }
  destination_ranges = var.google_ip_source_range_egress

}

data "google_compute_image" "demo_image" {
  name = "demo-terraform-app"
}

resource "google_compute_instance" "demo_instance" {
  count = local.is_google
  name         = "demo-terraform-instance"
  machine_type = var.google_machine_type
  zone         = var.google_instance_zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.demo_image.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

resource "time_sleep" "aws_wait_60_seconds" {
  count = local.is_google
  depends_on = [google_compute_instance.demo_instance]
  create_duration = "60s"
}


resource "null_resource" "start_google_application" {
  count = local.is_google
  depends_on = [time_sleep.aws_wait_60_seconds]
  connection {
    type  = "ssh"
    host  =  google_compute_instance.demo_instance[0].network_interface.0.access_config.0.nat_ip
    user  = "ubuntu"
    private_key = file(var.google_instance_key_location)
    port  = "22"
  }

  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${google_compute_instance.demo_instance[0].network_interface.0.access_config.0.nat_ip} 'sudo python3 /home/ubuntu/app/demoapp.py google  2>&1 >& output.log &'"
    interpreter = ["bash", "-c"]
  }
}