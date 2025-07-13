# Terraform AWS Ansible Automation Platform (AAP) Module

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623ce4.svg)](https://terraform.io)

A comprehensive Terraform module for deploying **Red Hat Ansible Automation Platform (AAP)** on AWS with enterprise-grade security, monitoring, and automation features.

## 🏗️ **Modular Architecture**

This module is organized into logical submodules for better maintainability, testing, and reusability:

```plaintext
terraform-aws-ansible-aap/
├── main.tf                    # Root module orchestrating submodules
├── variables.tf               # Root module input variables
├── outputs.tf                 # Root module outputs
├── versions.tf                # Root module provider requirements
├── modules/
│   ├── networking/            # VPC, subnets, security groups
│   ├── storage/               # S3 bucket and objects
│   ├── secrets/               # Secrets Manager resources
│   ├── database/              # RDS PostgreSQL
│   ├── compute/               # EC2, IAM, user data script
│   └── monitoring/            # CloudWatch, SSM associations
└── examples/
    └── complete/              # Example usage
```

### **Submodule Benefits**

- **🔍 Isolation**: Each component can be tested independently
- **♻️ Reusability**: Submodules can be used in other projects
- **🛠️ Maintainability**: Easier to find and fix issues
- **🧪 Testing**: Each submodule can have its own tests
- **📦 Dependency Management**: Clear dependency chain

## ✨ **Key Features**

### **🔐 Security First**

- **Red Hat Only**: Validates AMI is from official Red Hat account
- **Secrets Management**: AWS Secrets Manager for all sensitive data
- **Encryption**: S3, RDS, and EBS encryption at rest
- **Network Security**: VPC isolation with security groups
- **IAM**: Least-privilege access policies

### **📊 Enterprise Monitoring**

- **CloudWatch Dashboard**: Real-time metrics for EC2 and RDS
- **Log Aggregation**: Centralized logging with retention policies
- **SSM Integration**: Session Manager, Patch Manager, Inventory
- **Health Checks**: Automated monitoring and alerting

### **🚀 Flexible Deployment**

- **Two Package Modes**: Upload local installer or use existing S3 package
- **VPC Options**: Create new VPC or use existing infrastructure
- **Idempotent Installation**: Safe to re-run and handles failures gracefully
- **Production Ready**: Defaults optimized for production workloads

## 📋 **Prerequisites**

- **Terraform**: >= 1.5
- **AWS Provider**: >= 5.0
- **AAP Installer**: Downloaded from Red Hat Customer Portal
- **AWS Permissions**: IAM permissions for EC2, RDS, S3, Secrets Manager, CloudWatch, SSM

## 🚀 **Quick Start**

### **1. Upload Mode (Upload Local Installer)**

```hcl
module "ansible_aap" {
  source = "terraform-aws-ansible-aap"

  # Basic Configuration
  name        = "my-aap"
  environment = "production"

  # AAP Package - Upload local installer
  aap_package_mode   = "upload"
  aap_installer_path = "./ansible-automation-platform-setup-bundle-2.4-1.tar.gz"

  # Network Configuration - Create new VPC
  create_vpc = true

  # Instance Configuration
  instance_type     = "t3.large"
  db_instance_class = "db.t3.micro"

  # Security
  allowed_cidr_blocks = ["10.0.0.0/8"]

  tags = {
    Owner   = "DevOps Team"
    Project = "Automation Platform"
  }
}
```

### **2. Existing Mode (Use Existing S3 Package)**

```hcl
module "ansible_aap" {
  source = "terraform-aws-ansible-aap"

  # Basic Configuration
  name        = "my-aap"
  environment = "production"

  # AAP Package - Use existing S3 package
  aap_package_mode        = "existing"
  aap_installer_s3_bucket = "my-existing-bucket"
  aap_installer_s3_key    = "installers/aap-2.4.tar.gz"

  # Network Configuration - Use existing VPC
  create_vpc = false
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345", "subnet-67890"]

  tags = {
    Environment = "production"
  }
}
```

## 📚 **Submodule Usage**

You can also use individual submodules for specific components:

### **Networking Submodule**

```hcl
module "aap_networking" {
  source = "./modules/networking"

  name                    = "my-aap"
  create_vpc              = true
  allowed_cidr_blocks     = ["10.0.0.0/8"]
  allowed_ssh_cidr_blocks = ["10.0.0.0/8"]
}
```

### **Database Submodule**

```hcl
module "aap_database" {
  source = "./modules/database"

  name                        = "my-aap"
  subnet_ids                  = module.aap_networking.subnet_ids
  rds_security_group_id       = module.aap_networking.rds_security_group_id
  db_instance_class           = "db.t3.micro"
  db_username                 = "ansible"
  db_password                 = "secure-password"
}
```

## 🔧 **Module Inputs**

### **Core Configuration**

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `name` | Name prefix for all resources | `string` | n/a | ✅ |
| `environment` | Environment name | `string` | `"dev"` | ❌ |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | ❌ |

### **AAP Package Configuration**

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `aap_package_mode` | Package mode: `upload` or `existing` | `string` | `"upload"` | ❌ |
| `aap_installer_path` | Local path to AAP installer (upload mode) | `string` | `null` | ✅* |
| `aap_installer_s3_bucket` | S3 bucket name (existing mode) | `string` | `null` | ✅* |
| `aap_installer_s3_key` | S3 object key (existing mode) | `string` | `null` | ✅* |

*Required based on selected mode

### **Infrastructure Configuration**

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `create_vpc` | Create new VPC or use existing | `bool` | `true` | ❌ |
| `vpc_id` | Existing VPC ID | `string` | `null` | ✅* |
| `subnet_ids` | Existing subnet IDs | `list(string)` | `[]` | ✅* |
| `availability_zones` | List of AZs (optional). Must contain **2 or more** to satisfy RDS requirements. Leave empty for automatic selection | `list(string)` | `[]` | ❌ |
| `instance_type` | EC2 instance type | `string` | `"t3.large"` | ❌ |
| `db_instance_class` | RDS instance class | `string` | `"db.t3.micro"` | ❌ |
| `db_engine_version` | PostgreSQL engine version | `string` | `"15.5"` | ❌ |

*Required when `create_vpc = false`

**Note**: AWS RDS subnet groups require at least two Availability Zones.  If you leave `availability_zones` empty the module automatically picks the first two AZs in the region.  Provide your own list (≥2) if you need specific AZ placement.

## 📤 **Module Outputs**

### **Networking**

- `vpc_id` - VPC ID
- `subnet_ids` - List of subnet IDs
- `aap_controller_security_group_id` - AAP controller security group ID

### **Access Information**

- `aap_web_url` - AAP web interface URL
- `aap_admin_secret_arn` - ARN of admin password secret
- `cloudwatch_dashboard_url` - CloudWatch monitoring dashboard URL

### **Infrastructure Details**

- `aap_controller_instance_id` - EC2 instance ID
- `rds_endpoint` - Database endpoint
- `s3_bucket_name` - S3 bucket name

## 🏥 **Health Checks & Monitoring**

### **Built-in Monitoring**

- **CloudWatch Dashboard**: EC2 and RDS metrics visualization
- **Log Aggregation**: Application and system logs in CloudWatch
- **SSM Patch Manager**: Automated security patching
- **SSM Inventory**: System inventory tracking

### **Health Check Script**

```bash
# Check AAP service status
systemctl status automation-controller

# Verify database connectivity
curl -k https://localhost/api/v2/ping/

# Check CloudWatch agent
systemctl status amazon-cloudwatch-agent
```

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. AAP Installation Failed**

```bash
# Check installation logs
tail -f /var/log/aap-install.log

# Check system status
sudo systemctl status automation-controller
```

#### **2. Database Connection Issues**

- Verify RDS security group allows access from AAP controller
- Check secrets in AWS Secrets Manager
- Validate RDS endpoint connectivity

#### **3. S3 Access Issues**

- Verify IAM role has S3 GetObject permissions
- Check S3 bucket policy and public access settings

### **Debugging Tools**

#### **Access Instance via SSM**

```bash
aws ssm start-session --target i-1234567890abcdef0
```

#### **View Installation Status**

```bash
ls -la /opt/aap-install-status/
cat /opt/aap-install-status/*
```

## 💰 **Cost Optimization**

### **Development Environment**

```hcl
# Optimized for dev/test
instance_type               = "t3.medium"      # ~$30/month
db_instance_class          = "db.t3.micro"     # ~$15/month
enable_cloudwatch_dashboard = false            # Save dashboard costs
force_destroy              = true             # Allow easy cleanup
skip_final_snapshot        = true             # Skip RDS snapshot
```

### **Production Environment**

```hcl
# Optimized for production
instance_type               = "t3.large"       # ~$60/month
db_instance_class          = "db.t3.small"     # ~$25/month
db_backup_retention_period = 7                # 7-day backups
enable_cloudwatch_dashboard = true            # Full monitoring
```

**Estimated Monthly Costs:**

- **Development**: ~$50-75/month
- **Production**: ~$100-150/month

## 🤝 **Contributing**

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes with the example configurations
4. **Commit** your changes (`git commit -m 'Add amazing feature'`)
5. **Push** to the branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 **Support**

- 📖 **Documentation**: [examples/complete/README.md](examples/complete/README.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-org/terraform-aws-ansible-aap/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-org/terraform-aws-ansible-aap/discussions)

---

## **Made with ❤️ for the DevOps Community**
