# Test installation script for manual execution
resource "local_file" "test_aap_install" {
  filename = "test_aap_install.sh"
  content = templatefile("${path.module}/modules/compute/templates/user_data.sh.tpl", {
    aap_admin_secret_arn  = module.secrets.aap_admin_secret_arn
    db_secret_arn         = module.secrets.db_password_secret_arn
    db_endpoint           = module.database.endpoint
    db_name               = module.database.name
    s3_bucket             = module.storage.s3_bucket_name
    s3_key                = module.storage.s3_object_key
    region                = data.aws_region.current.region
    cloudwatch_log_group  = ""
    aap_admin_username    = module.secrets.aap_admin_username
    aap_organization      = var.aap_organization
    redhat_org            = var.redhat_org
    redhat_activation_key = var.redhat_activation_key
    enable_ssm            = var.enable_ssm
  })
}
