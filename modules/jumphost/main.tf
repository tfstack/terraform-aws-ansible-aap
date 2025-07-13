module "jumphost" {
  source = "tfstack/jumphost/aws"

  name      = "${var.name}-jumphost"
  ami_type  = var.ami_type
  subnet_id = var.subnet_id
  vpc_id    = var.vpc_id

  create_security_group = var.create_security_group
  allowed_cidr_blocks   = var.allowed_cidr_blocks
  assign_eip            = var.assign_eip

  enable_instance_connect             = var.enable_instance_connect
  enable_instance_connect_endpoint    = var.enable_instance_connect_endpoint
  instance_connect_endpoint_subnet_id = var.instance_connect_endpoint_subnet_id

  user_data_extra = <<-EOT
    apt-get update -y
    apt-get install -y mtr netcat
  EOT

  tags = var.tags
}
