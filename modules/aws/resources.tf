locals {
    is_aws = contains(var.cloud_platform ,"aws") ? 1 : 0
}

resource "aws_vpc" "demo_vpc" {
  count = local.is_aws
  cidr_block = var.aws_vpc_cidr
}

resource "aws_internet_gateway" "demo_igw" {
  count = local.is_aws
  vpc_id = aws_vpc.demo_vpc[0].id
}

resource "aws_route_table" "demo_routetable" {
    count = local.is_aws
    vpc_id = aws_vpc.demo_vpc[0].id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo_igw[0].id
    }
    route {
        ipv6_cidr_block        = "::/0"
        gateway_id = aws_internet_gateway.demo_igw[0].id
    }
}

resource "aws_subnet" "demo_subnet"{
  count = local.is_aws
  vpc_id = aws_vpc.demo_vpc[0].id
  cidr_block = var.aws_subnet_cidr
}

resource "aws_route_table_association" "demo_rta" {
  count = local.is_aws
  subnet_id      = aws_subnet.demo_subnet[0].id
  route_table_id = aws_route_table.demo_routetable[0].id
}

resource "aws_security_group" "demo_sg" {
  count = local.is_aws
  name        = "demo_sg"
  description = "All web traffic"
  vpc_id = aws_vpc.demo_vpc[0].id

  dynamic ingress {
    for_each = var.configure_ingress
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "tcp"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "demo_ni" {
  count = local.is_aws
  subnet_id       = aws_subnet.demo_subnet.0.id
  security_groups = [aws_security_group.demo_sg.0.id]
}

resource "aws_eip" "demo_eip" {
  depends_on = [aws_internet_gateway.demo_igw]
  count = local.is_aws
  vpc                       = true
  network_interface         = aws_network_interface.demo_ni[0].id
  associate_with_private_ip = aws_network_interface.demo_ni[0].private_ip
}


resource "aws_instance" "demo_instance"{
    depends_on = [aws_subnet.demo_subnet, aws_vpc.demo_vpc, aws_eip.demo_eip]
    count = local.is_aws
    ami = var.aws_instances_ami
    instance_type = var.aws_instance_type
    key_name          = "awsmain"
    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.demo_ni[0].id
    }
}

resource "time_sleep" "google_wait_30_seconds" {
  count = local.is_aws
  depends_on = [aws_instance.demo_instance]
  create_duration = "30s"
}

resource "null_resource" "start_aws_application" {
  depends_on = [time_sleep.google_wait_30_seconds]
  count = local.is_aws

  connection {
    type  = "ssh"
    host  =  aws_instance.demo_instance[0].public_ip
    user  = "ubuntu"
    private_key = file(var.aws_instance_key_location)
    port  = "22"
  }

  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.demo_instance[0].public_ip} 'sudo python3 /home/ubuntu/app/demoapp.py aws  2>&1 >& output.log &'"
  }
}