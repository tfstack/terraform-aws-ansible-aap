# Complete Example - terraform-aws-ansible-aap

This example demonstrates a full-featured deployment of Ansible Automation Platform (AAP) on AWS with all available options configured.

## Features Demonstrated

- **Automated AAP Installation**: Complete setup with PostgreSQL backend
- **VPC Creation**: New VPC with public/private subnets and NAT Gateway
- **Security**: Secrets Manager for passwords, restrictive security groups
- **Monitoring**: CloudWatch dashboard and logs
- **SSM Integration**: Session Manager, Patch Manager, and Inventory
- **S3 Package Upload**: Automatic upload of AAP installer to S3

## Prerequisites

1. **AAP Installer Package**: Download from Red Hat Customer Portal
   - File: `ansible-automation-platform-setup-bundle-*.tar.gz`
   - Valid Red Hat subscription required

2. **AWS Credentials**: Configured with appropriate permissions

3. **Terraform**: Version >= 1.5

## Usage

### 1. Configure Variables

Create a `terraform.tfvars` file:

```hcl
aws_region         = "ap-southeast-2"
aap_installer_path = "/path/to/your/ansible-automation-platform-setup-bundle-2.4-5-x86_64.tar.gz"
key_pair_name      = "my-ec2-keypair"  # Optional
```

### 2. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply
```

### 3. Access AAP

After deployment completes (15-30 minutes):

```bash
# Get the AAP web URL
terraform output aap_web_url

# Get admin credentials
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw aap_admin_secret_arn) \
  --query 'SecretString' --output text | jq .
```

### 4. Monitor Installation

```bash
# Check installation progress via CloudWatch
terraform output installation_log_command

# Or connect directly via SSM
terraform output ssm_session_command
```

## What Gets Created

### Network Infrastructure

- VPC with CIDR 10.0.0.0/16
- 3 public subnets (10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24)
- 3 private subnets (10.0.100.0/24, 10.0.101.0/24, 10.0.102.0/24)
- Internet Gateway and NAT Gateway
- Route tables for public/private traffic

### Compute & Database

- EC2 instance (t3.large) in private subnet
- RDS PostgreSQL (db.t3.micro) in private subnet
- Security groups with minimal required access

### Storage & Secrets

- S3 bucket for AAP installer (encrypted, versioned)
- AWS Secrets Manager secrets for passwords
- CloudWatch Log Groups for application logs

### Monitoring & Management

- CloudWatch Dashboard for system metrics
- SSM associations for patch management
- IAM roles with least-privilege access

## Security Features

- **Network Isolation**: AAP in private subnet, only necessary ports open
- **Encryption**: All data encrypted at rest and in transit
- **Secrets Management**: No hardcoded passwords, all in Secrets Manager
- **Access Control**: SSM Session Manager for secure shell access
- **Audit Trail**: CloudWatch logs for all activities

## Cost Breakdown (Approximate Monthly)

| Resource | Type | Cost |
|----------|------|------|
| EC2 Instance | t3.large | $60 |
| RDS Instance | db.t3.micro | $15 |
| NAT Gateway | Standard | $45 |
| CloudWatch Logs | 1GB/month | $1 |
| Secrets Manager | 2 secrets | $1 |
| S3 Storage | <1GB | <$1 |
| **Total** | | **~$122/month** |

## Customization

### For Production

```hcl
# Larger instances
instance_type     = "t3.xlarge"
db_instance_class = "db.r6g.large"

# Enhanced backup/retention
db_backup_retention_period = 30
log_retention_days = 90

# Security
force_destroy       = false
skip_final_snapshot = false
```

### For Development

```hcl
# Smaller instances
instance_type     = "t3.medium"
db_instance_class = "db.t3.micro"

# Quick cleanup
force_destroy       = true
skip_final_snapshot = true
log_retention_days  = 7
```

## Troubleshooting

### Installation Issues

1. **Check CloudWatch Logs**:

   ```bash
   aws logs describe-log-streams \
     --log-group-name $(terraform output -raw cloudwatch_log_group_name)
   ```

2. **Connect to Instance**:

   ```bash
   aws ssm start-session --target $(terraform output -raw aap_controller_instance_id)
   ```

3. **Verify RDS Connectivity**:

   ```bash
   # From the EC2 instance
   nc -zv <rds-endpoint> 5432
   ```

### Common Issues

- **AAP installer not found**: Verify `aap_installer_path` points to valid file
- **Permission denied**: Check AWS credentials and IAM permissions
- **Network timeout**: Verify VPC has internet connectivity via NAT Gateway
- **Database connection failed**: Check RDS security group and subnet configuration

## Cleanup

```bash
# Destroy all resources
terraform destroy

# Note: S3 bucket will be retained if force_destroy = false
```

## Next Steps

After successful deployment:

1. **Configure AAP**: Set up projects, inventories, and job templates
2. **SSL Certificate**: Replace self-signed cert with valid SSL certificate
3. **Backup Strategy**: Configure automated backups for RDS and application data
4. **Monitoring**: Set up CloudWatch alarms for critical metrics
5. **Scaling**: Consider Auto Scaling Groups for high availability

## Support

For issues with this example:

- Check the main module [README](../../README.md)
- Review [troubleshooting guide](../../docs/troubleshooting.md)
- Open an issue in the repository
