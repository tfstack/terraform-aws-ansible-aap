#!/bin/bash
exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
set -o nounset -o pipefail -o errexit

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2; }
trap 'log_error "Script failed at line $LINENO"' ERR

log "Starting AAP installation..."

# Get AWS region
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" --max-time 10)
AWS_REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/region --max-time 10)
log "AWS Region: $AWS_REGION"

# Variables
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
REDHAT_ORG="${redhat_org}"
REDHAT_ACTIVATION_KEY="${redhat_activation_key}"
ENABLE_SSM="${enable_ssm}"

# Status files
INSTALL_STATUS_DIR="/opt/aap-install-status"
PACKAGES_INSTALLED="$INSTALL_STATUS_DIR/packages-installed"
AAP_DOWNLOADED="$INSTALL_STATUS_DIR/aap-downloaded"
AAP_INSTALLED="$INSTALL_STATUS_DIR/aap-installed"
AAP_CONFIGURED="$INSTALL_STATUS_DIR/aap-configured"

mkdir -p "$INSTALL_STATUS_DIR"

# Package installation
if [ ! -f "$PACKAGES_INSTALLED" ]; then
    log "Installing packages following AAP best practices..."
    yum update -y && yum install -y awscli jq python3 python3-pip unzip nc openssh-server openssh-clients

    # Configure and start SSH service
    log "Configuring SSH service..."
    systemctl enable sshd
    systemctl start sshd

    # Configure SSH for passwordless authentication
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config
    systemctl reload sshd

    # System tuning for AAP (following Red Hat best practices)
    log "Applying system tuning for AAP..."

    # Increase file descriptors
    echo "* soft nofile 65536" >>/etc/security/limits.conf
    echo "* hard nofile 65536" >>/etc/security/limits.conf
    echo "root soft nofile 65536" >>/etc/security/limits.conf
    echo "root hard nofile 65536" >>/etc/security/limits.conf

    # Increase process limits
    echo "* soft nproc 65536" >>/etc/security/limits.conf
    echo "* hard nproc 65536" >>/etc/security/limits.conf

    # Configure kernel parameters
    cat >>/etc/sysctl.conf <<EOF
# AAP performance tuning
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF

    # Apply sysctl changes
    sysctl -p

    # SSM Agent
    if [ "$ENABLE_SSM" = "true" ]; then
        log "Installing SSM Agent..."
        mkdir -p /tmp/ssm && cd /tmp/ssm
        curl -O "https://s3.$AWS_REGION.amazonaws.com/amazon-ssm-$AWS_REGION/latest/linux_amd64/amazon-ssm-agent.rpm"
        dnf install -y amazon-ssm-agent.rpm
        systemctl enable --now amazon-ssm-agent
        for i in {1..30}; do
            systemctl is-active --quiet amazon-ssm-agent && break
            sleep 2
        done
        cd /
    fi

    # Red Hat registration
    if [ -n "$REDHAT_ORG" ] && [ -n "$REDHAT_ACTIVATION_KEY" ]; then
        log "Registering with Red Hat..."
        subscription-manager register --org="$REDHAT_ORG" --activationkey="$REDHAT_ACTIVATION_KEY"
        subscription-manager repos --enable=rhel-9-for-x86_64-baseos-rpms
        subscription-manager repos --enable=rhel-9-for-x86_64-appstream-rpms
    fi

    # CloudWatch agent
    if [ -n "$CLOUDWATCH_LOG_GROUP" ]; then
        yum install -y amazon-cloudwatch-agent
        cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{"logs":{"logs_collected":{"files":{"collect_list":[{"file_path":"/var/log/aap-install.log","log_group_name":"$CLOUDWATCH_LOG_GROUP","log_stream_name":"{instance_id}/aap-install","timezone":"UTC"},{"file_path":"/var/log/messages","log_group_name":"$CLOUDWATCH_LOG_GROUP","log_stream_name":"{instance_id}/messages","timezone":"UTC"}]}}}}}
EOF
        /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
    fi

    touch "$PACKAGES_INSTALLED"
    log "Packages installed"
else
    log "Packages already installed"
fi

# Get secrets
if [ ! -f "/tmp/aap-credentials" ]; then
    log "Getting secrets..."
    AAP_ADMIN_CREDS=$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "$AAP_ADMIN_SECRET_ARN" --query 'SecretString' --output text)
    AAP_ADMIN_PASSWORD=$(echo "$AAP_ADMIN_CREDS" | jq -r '.password')
    DB_CREDS=$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "$DB_SECRET_ARN" --query 'SecretString' --output text)
    DB_USERNAME=$(echo "$DB_CREDS" | jq -r '.username')
    DB_PASSWORD=$(echo "$DB_CREDS" | jq -r '.password')
    cat >/tmp/aap-credentials <<EOF
AAP_ADMIN_PASSWORD='$AAP_ADMIN_PASSWORD'
DB_USERNAME='$DB_USERNAME'
DB_PASSWORD='$DB_PASSWORD'
EOF
    chmod 600 /tmp/aap-credentials
    log "Secrets retrieved"
else
    source /tmp/aap-credentials
fi

# Download AAP
if [ ! -f "$AAP_DOWNLOADED" ]; then
    log "Downloading AAP..."
    mkdir -p /opt/aap-install && cd /opt/aap-install
    DB_HOST=$(echo "$DB_ENDPOINT" | cut -d: -f1)
    until nc -z "$DB_HOST" 5432; do sleep 10; done
    aws s3 cp "s3://$S3_BUCKET/$S3_KEY" ./aap-installer.tar.gz --region "$REGION"
    tar -xzf aap-installer.tar.gz
    touch "$AAP_DOWNLOADED"
    log "AAP downloaded"
else
    cd /opt/aap-install/ansible-automation-platform-setup-*
fi

# Install AAP
if [ ! -f "$AAP_INSTALLED" ]; then
    log "Installing AAP..."
    cd /opt/aap-install/ansible-automation-platform-setup-*
    source /tmp/aap-credentials

    # Get the correct IP address using token
    INSTANCE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
    log "Instance IP: $INSTANCE_IP"

    # Create inventory following AAP best practices
    cat >inventory <<EOF
[automationcontroller]
$INSTANCE_IP ansible_connection=local

[automationgateway]
$INSTANCE_IP ansible_connection=local

[database]

[all:vars]
# Database configuration
admin_password='$AAP_ADMIN_PASSWORD'
pg_host='$DB_ENDPOINT'
pg_port='5432'
pg_database='$DB_NAME'
pg_username='$DB_USERNAME'
pg_password='$DB_PASSWORD'
pg_sslmode='require'

# Registry configuration
registry_url='registry.redhat.io'
registry_username=''
registry_password=''

# Controller configuration
admin_user='$AAP_ADMIN_USERNAME'
admin_email='admin@example.com'

# Security configuration
nginx_disable_https=false
nginx_disable_hsts=false
nginx_http_port=80
nginx_https_port=443

# Network configuration
automation_controller_main_url="https://$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-hostname)"

# Installation options
create_preload_data=True
install_awx_isolated=false
install_automationhub=false
install_automationedacontroller=false
install_automationgateway=false
install_execution_nodes=false

# Performance tuning
pg_max_connections=100
pg_shared_buffers=256MB
pg_effective_cache_size=1GB
pg_maintenance_work_mem=64MB
pg_checkpoint_completion_target=0.9
pg_wal_buffers=16MB
pg_default_statistics_target=100
pg_random_page_cost=1.1
pg_effective_io_concurrency=200
pg_work_mem=4MB
pg_min_wal_size=1GB
pg_max_wal_size=4GB

# System tuning
nginx_worker_processes=auto
nginx_worker_connections=1024
nginx_keepalive_timeout=65
nginx_keepalive_requests=100
nginx_client_max_body_size=250m
nginx_proxy_read_timeout=120
nginx_proxy_connect_timeout=60
nginx_proxy_send_timeout=120

# Logging configuration
log_level=INFO
log_aggregator_level=INFO
log_aggregator_max_tmp_file_size_mb=100
log_aggregator_max_tmp_file_rotation=5
EOF

    # Configure SSH for localhost connections
    log "Configuring SSH for localhost..."
    mkdir -p ~/.ssh
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >>~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    chmod 700 ~/.ssh

    # Add localhost to known_hosts
    ssh-keyscan -H localhost >>~/.ssh/known_hosts 2>/dev/null || true
    ssh-keyscan -H 127.0.0.1 >>~/.ssh/known_hosts 2>/dev/null || true
    ssh-keyscan -H $INSTANCE_IP >>~/.ssh/known_hosts 2>/dev/null || true

    # Test SSH connectivity
    log "Testing SSH connectivity..."
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null localhost "echo 'SSH test successful'" || log "SSH test failed, continuing anyway"

    # Debug: Show current directory and files
    log "Current directory: $(pwd)"
    log "Files in current directory:"
    ls -la || true

    # Debug: Check if setup.sh exists and is executable
    if [ -f "./setup.sh" ]; then
        log "setup.sh exists and is executable"
        ls -la setup.sh
    else
        log_error "setup.sh not found in current directory"
        exit 1
    fi

    # Run AAP installation
    log "Starting AAP installation..."
    ./setup.sh -e pg_ssl_mode=require -e install_awx_isolated=false -e install_automationhub=false || {
        log_error "AAP installation failed. Check setup.log for details."
        cat setup.log || true
        exit 1
    }

    # Verify installation
    log "Verifying AAP installation..."
    if [ -f "/etc/tower/SETUP_COMPLETE" ]; then
        log "AAP installation verified successfully"
    else
        log_error "AAP installation verification failed"
        cat setup.log || true
        exit 1
    fi

    touch "$AAP_INSTALLED"
    log "AAP installed following best practices"
else
    log "AAP already installed"
fi

# Configure AAP
if [ ! -f "$AAP_CONFIGURED" ]; then
    log "Configuring AAP..."
    source /tmp/aap-credentials
    sleep 60
    cat >/tmp/configure_aap.py <<'PYTHON_EOF'
#!/usr/bin/env python3
import requests,json,sys,time,os,urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
def wait_for_aap(max_attempts=30):
    for attempt in range(max_attempts):
        try:
            response = requests.get('https://localhost/api/v2/ping/',verify=False,timeout=10)
            if response.status_code == 200: return True
        except: pass
        time.sleep(30)
    return False
def get_token(username,password):
    auth_data = {'username': username,'password': password}
    response = requests.post('https://localhost/api/v2/tokens/',json=auth_data,verify=False)
    return response.json()['token'] if response.status_code == 201 else None
def configure_organization(token,org_name):
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get('https://localhost/api/v2/organizations/',headers=headers,verify=False)
    orgs = response.json().get('results',[])
    for org in orgs:
        if org['name'] == org_name: return org['id']
    org_data = {'name': org_name,'description': f'Default organization for {org_name}'}
    response = requests.post('https://localhost/api/v2/organizations/',json=org_data,headers=headers,verify=False)
    return response.json()['id'] if response.status_code == 201 else None
if __name__ == "__main__":
    admin_username = os.environ.get('AAP_ADMIN_USERNAME','admin')
    admin_password = os.environ.get('AAP_ADMIN_PASSWORD')
    org_name = os.environ.get('AAP_ORGANIZATION','Default')
    if not admin_password: sys.exit(1)
    if not wait_for_aap(): sys.exit(1)
    token = get_token(admin_username,admin_password)
    if not token: sys.exit(1)
    org_id = configure_organization(token,org_name)
    if not org_id: sys.exit(1)
PYTHON_EOF
    chmod +x /tmp/configure_aap.py
    export AAP_ADMIN_USERNAME="$AAP_ADMIN_USERNAME"
    export AAP_ADMIN_PASSWORD="$AAP_ADMIN_PASSWORD"
    export AAP_ORGANIZATION="$AAP_ORGANIZATION"
    python3 /tmp/configure_aap.py
    touch "$AAP_CONFIGURED"
    log "AAP configured"
else
    log "AAP already configured"
fi

log "AAP installation completed"
rm -f /tmp/aap-credentials /tmp/configure_aap.py
