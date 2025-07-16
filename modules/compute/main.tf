# Compute Module - EC2 Instance and IAM Resources

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get latest Red Hat Enterprise Linux AMI if not provided
data "aws_ami" "redhat_linux" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["309956199498"] # Red Hat's official AWS account ID

  filter {
    name   = "name"
    values = ["RHEL-9.*-x86_64-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Validate AMI is Red Hat only
data "aws_ami" "ami_validation" {
  count = var.ami_id != null ? 1 : 0

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }

  filter {
    name   = "owner-id"
    values = ["309956199498"] # Red Hat's official AWS account ID
  }
}

# Locals
locals {
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.redhat_linux[0].id

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    aap_admin_secret_arn  = var.aap_admin_secret_arn
    db_secret_arn         = var.db_password_secret_arn
    db_endpoint           = var.db_endpoint
    db_name               = var.db_name
    s3_bucket             = var.s3_bucket_name
    s3_key                = var.s3_object_key
    region                = data.aws_region.current.region
    cloudwatch_log_group  = var.cloudwatch_log_group_name
    aap_admin_username    = var.aap_admin_username
    aap_organization      = var.aap_organization
    redhat_org            = var.redhat_org
    redhat_activation_key = var.redhat_activation_key
    enable_ssm            = var.enable_ssm
  })
}

# IAM Role for EC2
resource "aws_iam_role" "aap_controller" {
  name_prefix = "${var.name}-aap-controller-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for EC2
resource "aws_iam_policy" "aap_controller" {
  name_prefix = "${var.name}-aap-controller-"
  description = "Policy for AAP controller EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          var.aap_admin_secret_arn,
          var.db_password_secret_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/${var.s3_object_key}"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = var.enable_cloudwatch_logs ? "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/${var.name}*" : ""
      }
    ]
  })

  tags = var.tags
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "aap_controller" {
  role       = aws_iam_role.aap_controller.name
  policy_arn = aws_iam_policy.aap_controller.arn
}

# Attach SSM managed policy for Session Manager
resource "aws_iam_role_policy_attachment" "aap_controller_ssm" {
  role       = aws_iam_role.aap_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "aap_controller" {
  name_prefix = "${var.name}-aap-controller-"
  role        = aws_iam_role.aap_controller.name

  tags = var.tags
}

# EC2 Instance
resource "aws_instance" "aap_controller" {
  ami           = local.ami_id
  instance_type = var.instance_type

  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [var.aap_controller_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.aap_controller.name

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "${var.name}-aap-controller"
  })

  depends_on = [data.aws_ami.ami_validation]
}
