data "http" "my_public_ip" {
  url = "http://ifconfig.me/ip"
}

module "ansible_aap" {
  source = "../../"

  # Basic Configuration
  #   name        = "ansible-aap"
  name        = "test"
  environment = "dev"

  # AAP Package Configuration - Upload mode (upload local installer)
  aap_package_mode   = "upload"
  aap_installer_path = var.aap_installer_path

  # Or use existing S3 package mode:
  # aap_package_mode        = "existing"
  # aap_installer_s3_bucket = "my-existing-bucket"
  # aap_installer_s3_key    = "/tmp/ansible-automation-platform-setup-bundle-2.5-1-x86_64.tar.gz"

  # Network Configuration
  availability_zones   = ["ap-southeast-2a", "ap-southeast-2b"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Jumphost Configuration
  create_security_group            = true
  ami_type                         = "amazonlinux2"
  instance_type                    = "t3.micro"
  assign_eip                       = false
  enable_instance_connect          = true
  enable_instance_connect_endpoint = true

  user_data_extra = <<-EOT
    apt-get update -y
    apt-get install -y mtr netcat
  EOT

  # RDS Configuration
  db_instance_class          = "db.t3.micro"
  db_engine_version          = "15.13"
  db_allocated_storage       = 20
  storage_encrypted          = false
  db_backup_retention_period = 7

  # Security Configuration
  vpc_cidr                             = "10.0.0.0/16"
  allowed_cidr_blocks                  = ["10.0.0.0/16", "${data.http.my_public_ip.response_body}/32"]
  allowed_ssh_cidr_blocks              = ["10.0.0.0/16"]
  allowed_instance_connect_cidr_blocks = ["10.0.0.0/16", "${data.http.my_public_ip.response_body}/32"]

  # Monitoring and Logging
  enable_cloudwatch_dashboard = true
  enable_cloudwatch_logs      = true
  log_retention_days          = 30

  # AAP Configuration
  aap_admin_username = "admin"
  aap_organization   = "Default"

  # Resource Management
  db_backup_window              = "03:00-06:00"
  db_enable_deletion_protection = false # For dev/test environments
  force_destroy                 = true
  skip_final_snapshot           = true # For dev/test environments

  # tags = {
  #   Project = "MyProject"
  #   Owner   = "DevOps Team"
  # }
}
