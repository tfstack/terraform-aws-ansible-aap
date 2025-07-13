#!/bin/bash

# User data script for AAP controller installation
# This script runs on EC2 instance startup to install and configure Ansible Automation Platform
# Made idempotent to handle restarts and re-runs safely

# Set error handling
set -e

# Variables from Terraform template
AAP_ADMIN_SECRET_ARN="${aap_admin_secret_arn}"
DB_SECRET_ARN="${db_secret_arn}"
DB_ENDPOINT="${db_endpoint}"
DB_NAME="${db_name}"
S3_BUCKET="${s3_bucket}"
S3_KEY="${s3_key}"
REGION="${region}"
CLOUDWATCH_LOG_GROUP="${cloudwatch_log_group}"
AAP_ADMIN_USERNAME="${aap_admin_username}"
AAP_ORGANIZATION="${aap_organization}"

# Installation status files for idempotency
INSTALL_STATUS_DIR="/opt/aap-install-status"
PACKAGES_INSTALLED="$INSTALL_STATUS_DIR/packages-installed"
AAP_DOWNLOADED="$INSTALL_STATUS_DIR/aap-downloaded"
AAP_INSTALLED="$INSTALL_STATUS_DIR/aap-installed"
AAP_CONFIGURED="$INSTALL_STATUS_DIR/aap-configured"

# Create status directory
mkdir -p "$INSTALL_STATUS_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    if [ -n "$CLOUDWATCH_LOG_GROUP" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>/var/log/aap-install.log
    fi
}

log "Starting AAP installation process (idempotent)"

# Update system (idempotent)
if [ ! -f "$PACKAGES_INSTALLED" ]; then
    log "Updating system packages and installing dependencies"
    yum update -y
    yum install -y awscli jq python3 python3-pip unzip nc

    # Install & Start AWS SSM Agent (required for Session Manager)
    if ! systemctl is-active --quiet amazon-ssm-agent; then
        log "Installing and starting AWS SSM Agent"
        yum install -y amazon-ssm-agent
        systemctl enable --now amazon-ssm-agent
    else
        log "AWS SSM Agent already installed and running"
    fi

    # Install CloudWatch agent if logging is enabled
    if [ -n "$CLOUDWATCH_LOG_GROUP" ]; then
        log "Installing and configuring CloudWatch agent"
        yum install -y amazon-cloudwatch-agent

        # Create CloudWatch agent configuration
        cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/aap-install.log",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/aap-install",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "$CLOUDWATCH_LOG_GROUP",
                        "log_stream_name": "{instance_id}/messages",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    }
}
EOF

        # Start CloudWatch agent
        /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
            -a fetch-config \
            -m ec2 \
            -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
            -s
    fi

    touch "$PACKAGES_INSTALLED"
    log "Package installation completed"
else
    log "Packages already installed, skipping"
fi

# Retrieve secrets from AWS Secrets Manager (idempotent)
if [ ! -f "/tmp/aap-credentials" ]; then
    log "Retrieving AAP admin credentials from Secrets Manager"
    AAP_ADMIN_CREDS=$(aws secretsmanager get-secret-value \
        --region "$REGION" \
        --secret-id "$AAP_ADMIN_SECRET_ARN" \
        --query 'SecretString' --output text)

    AAP_ADMIN_PASSWORD=$(echo "$AAP_ADMIN_CREDS" | jq -r '.password')

    log "Retrieving database credentials from Secrets Manager"
    DB_CREDS=$(aws secretsmanager get-secret-value \
        --region "$REGION" \
        --secret-id "$DB_SECRET_ARN" \
        --query 'SecretString' --output text)

    DB_USERNAME=$(echo "$DB_CREDS" | jq -r '.username')
    DB_PASSWORD=$(echo "$DB_CREDS" | jq -r '.password')

    # Store credentials securely for reuse
    cat >/tmp/aap-credentials <<EOF
AAP_ADMIN_PASSWORD='$AAP_ADMIN_PASSWORD'
DB_USERNAME='$DB_USERNAME'
DB_PASSWORD='$DB_PASSWORD'
EOF
    chmod 600 /tmp/aap-credentials
    log "Credentials retrieved and cached"
else
    log "Loading cached credentials"
    source /tmp/aap-credentials
fi

# Download and extract AAP installer (idempotent)
if [ ! -f "$AAP_DOWNLOADED" ]; then
    log "Downloading AAP installer from S3"
    mkdir -p /opt/aap-install
    cd /opt/aap-install

    # Wait for RDS to be available
    log "Waiting for RDS to be available"
    DB_HOST=$(echo "$DB_ENDPOINT" | cut -d: -f1)
    until nc -z "$DB_HOST" 5432; do
        log "Waiting for database connection..."
        sleep 10
    done
    log "Database is available"

    aws s3 cp "s3://$S3_BUCKET/$S3_KEY" ./aap-installer.tar.gz --region "$REGION"

    # Extract installer
    log "Extracting AAP installer"
    tar -xzf aap-installer.tar.gz
    touch "$AAP_DOWNLOADED"
    log "AAP installer downloaded and extracted"
else
    log "AAP installer already downloaded, skipping"
    cd /opt/aap-install/ansible-automation-platform-setup-*
fi

# Install AAP (idempotent)
if [ ! -f "$AAP_INSTALLED" ]; then
    log "Installing AAP"
    cd /opt/aap-install/ansible-automation-platform-setup-*

    # Source credentials
    source /tmp/aap-credentials

    # Create inventory file for AAP installation
    log "Creating AAP inventory file"
    cat >inventory <<EOF
[automationcontroller]
$(hostname -I | awk '{print $1}')

[database]

[all:vars]
admin_password='$AAP_ADMIN_PASSWORD'
pg_host='$DB_ENDPOINT'
pg_port='5432'
pg_database='$DB_NAME'
pg_username='$DB_USERNAME'
pg_password='$DB_PASSWORD'
pg_sslmode='require'

registry_url='registry.redhat.io'
registry_username=''
registry_password=''

# Automation Controller
admin_user='$AAP_ADMIN_USERNAME'
admin_email='admin@example.com'

# Automation Controller clustered configuration
nginx_disable_https=false
nginx_disable_hsts=false
nginx_http_port=80
nginx_https_port=443

# Automation Controller configuration
automation_controller_main_url="https://$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)"

# Organization configuration
create_preload_data=True
EOF

    # Run AAP installation
    log "Starting AAP installation"
    ./setup.sh -e pg_ssl_mode=require

    touch "$AAP_INSTALLED"
    log "AAP installation completed"
else
    log "AAP already installed, skipping installation"
fi

# Configure AAP organization (idempotent)
if [ ! -f "$AAP_CONFIGURED" ]; then
    log "Configuring AAP organization"

    # Source credentials
    source /tmp/aap-credentials

    # Wait for AAP services to be ready
    log "Waiting for AAP services to start"
    sleep 60

    # Create configuration script
    cat >/tmp/configure_aap.py <<'PYTHON_EOF'
#!/usr/bin/env python3
import requests
import json
import sys
import time
import os

# Disable SSL warnings for self-signed certificates
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def wait_for_aap(max_attempts=30):
    """Wait for AAP to be ready"""
    for attempt in range(max_attempts):
        try:
            response = requests.get('https://localhost/api/v2/ping/',
                                  verify=False, timeout=10)
            if response.status_code == 200:
                print("AAP is ready")
                return True
        except Exception as e:
            print(f"Attempt {attempt + 1}: AAP not ready yet - {e}")
            time.sleep(30)
    return False

def get_token(username, password):
    """Get authentication token"""
    auth_data = {
        'username': username,
        'password': password
    }

    response = requests.post('https://localhost/api/v2/tokens/',
                           json=auth_data,
                           verify=False)

    if response.status_code == 201:
        return response.json()['token']
    else:
        print(f"Failed to get token: {response.status_code} - {response.text}")
        return None

def configure_organization(token, org_name):
    """Configure organization (idempotent)"""
    headers = {'Authorization': f'Bearer {token}'}

    # Check if organization exists
    response = requests.get('https://localhost/api/v2/organizations/',
                          headers=headers, verify=False)

    orgs = response.json().get('results', [])
    for org in orgs:
        if org['name'] == org_name:
            print(f"Organization '{org_name}' already exists")
            return org['id']

    # Create organization
    org_data = {
        'name': org_name,
        'description': f'Default organization for {org_name}'
    }

    response = requests.post('https://localhost/api/v2/organizations/',
                           json=org_data,
                           headers=headers,
                           verify=False)

    if response.status_code == 201:
        org_id = response.json()['id']
        print(f"Created organization '{org_name}' with ID {org_id}")
        return org_id
    else:
        print(f"Failed to create organization: {response.status_code} - {response.text}")
        return None

if __name__ == "__main__":
    admin_username = os.environ.get('AAP_ADMIN_USERNAME', 'admin')
    admin_password = os.environ.get('AAP_ADMIN_PASSWORD')
    org_name = os.environ.get('AAP_ORGANIZATION', 'Default')

    if not admin_password:
        print("AAP_ADMIN_PASSWORD environment variable is required")
        sys.exit(1)

    print("Waiting for AAP to be ready...")
    if not wait_for_aap():
        print("AAP failed to start within expected time")
        sys.exit(1)

    print("Getting authentication token...")
    token = get_token(admin_username, admin_password)
    if not token:
        print("Failed to get authentication token")
        sys.exit(1)

    print("Configuring organization...")
    org_id = configure_organization(token, org_name)
    if org_id:
        print("AAP configuration completed successfully")
    else:
        print("Failed to configure organization")
        sys.exit(1)
PYTHON_EOF

    chmod +x /tmp/configure_aap.py

    # Set environment variables and run configuration
    export AAP_ADMIN_USERNAME="$AAP_ADMIN_USERNAME"
    export AAP_ADMIN_PASSWORD="$AAP_ADMIN_PASSWORD"
    export AAP_ORGANIZATION="$AAP_ORGANIZATION"

    python3 /tmp/configure_aap.py

    touch "$AAP_CONFIGURED"
    log "AAP configuration completed"
else
    log "AAP already configured, skipping configuration"
fi

# Final status
log "AAP installation process completed successfully"
echo "AAP installation completed at $(date)" >/tmp/aap-install-complete

# Clean up sensitive files
rm -f /tmp/aap-credentials /tmp/configure_aap.py

log "AAP installation process finished (idempotent)"
