# Terraform 0.12 compliant
terraform {
  required_version = "< 0.12"

provider "aws" {
  region = var.aws_region
}

# EC2 server
resource "aws_instance" "test-ec2-instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.terraform_remote_state.subnet_id.outputs.subnet_id
  vpc_security_group_ids      = [data.terraform_remote_state.vpc_security_group_ids.outputs.id]
  associate_public_ip_address = true

  subnet_id =
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name  = "${var.owner}-demo_env"
    owner = var.owner
    TTL   = var.ttl
    environment = var.env
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.private_key
    host        = "${data.terraform_remote_state.public_ip}"
    timeout     = "30s"
  }
  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/raygj/consul-content",
      "cp consul-content/kubernetes/consul-minikube/terraform/aws/files/bootstrap.sh ~/",
      "chmod +x ~/bootstrap.sh",
      "sudo ./bootstrap.sh"
    ]
  }
}
