output "aws_public_ip"{
  value = contains(var.cloud_platform ,"aws") ? aws_instance.demo_instance[0].public_ip : ""
}