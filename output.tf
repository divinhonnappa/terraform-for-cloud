output "aws_application_ip" {
  value = "${module.aws_application.aws_public_ip}"
}

output "google_application_ip" {
  value = "${module.google_application.google_public_ip}"
}