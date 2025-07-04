#!/bin/bash

# FPL Assistant Infrastructure Deployment Script
# This script deploys the basic infrastructure using CloudFormation

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="fpl-assistant"
ENVIRONMENT="dev"
REGION="us-east-1"  # Change to your preferred region
STACK_NAME="${PROJECT_NAME}-${ENVIRONMENT}-infrastructure"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials are not configured. Please run 'aws configure' first."
    exit 1
fi

# Function to check if key pair exists
check_key_pair() {
    local key_name=$1
    if aws ec2 describe-key-pairs --key-names "$key_name" --region "$REGION" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to create key pair
create_key_pair() {
    local key_name=$1
    print_status "Creating EC2 Key Pair: $key_name"
    
    aws ec2 create-key-pair \
        --key-name "$key_name" \
        --region "$REGION" \
        --query 'KeyMaterial' \
        --output text > "${key_name}.pem"
    
    chmod 400 "${key_name}.pem"
    print_status "Key pair created and saved as ${key_name}.pem"
}

# Function to get user's IP address
get_user_ip() {
    local ip=$(curl -s https://checkip.amazonaws.com)
    echo "${ip}/32"
}

# Main deployment function
deploy_infrastructure() {
    print_status "Starting infrastructure deployment..."
    
    # Get user's IP for SSH access
    local user_ip=$(get_user_ip)
    print_status "Detected your IP address: $user_ip"
    
    # Check/create key pair
    local key_name="${PROJECT_NAME}-${ENVIRONMENT}-key"
    if ! check_key_pair "$key_name"; then
        create_key_pair "$key_name"
    else
        print_status "Key pair $key_name already exists"
    fi
    
    # Deploy CloudFormation stack
    print_status "Deploying CloudFormation stack: $STACK_NAME"
    
    aws cloudformation deploy \
        --template-file infrastructure.yaml \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --capabilities CAPABILITY_NAMED_IAM \
        --parameter-overrides \
            ProjectName="$PROJECT_NAME" \
            Environment="$ENVIRONMENT" \
            KeyPairName="$key_name" \
            AllowedSSHCIDR="$user_ip" \
        --tags \
            Project="$PROJECT_NAME" \
            Environment="$ENVIRONMENT" \
            Owner="$(aws sts get-caller-identity --query 'Arn' --output text)"
    
    if [ $? -eq 0 ]; then
        print_status "Infrastructure deployment completed successfully!"
        
        # Get stack outputs
        print_status "Retrieving stack outputs..."
        
        local web_server_ip=$(aws cloudformation describe-stacks \
            --stack-name "$STACK_NAME" \
            --region "$REGION" \
            --query 'Stacks[0].Outputs[?OutputKey==`WebServerPublicIP`].OutputValue' \
            --output text)
        
        local data_bucket=$(aws cloudformation describe-stacks \
            --stack-name "$STACK_NAME" \
            --region "$REGION" \
            --query 'Stacks[0].Outputs[?OutputKey==`DataBucketName`].OutputValue' \
            --output text)
        
        # Display connection information
        echo ""
        echo "========================================================================================"
        echo "DEPLOYMENT COMPLETE!"
        echo "========================================================================================"
        echo ""
        echo "Web Server Details:"
        echo "  Public IP: $web_server_ip"
        echo "  SSH Command: ssh -i ${key_name}.pem ec2-user@$web_server_ip"
        echo ""
        echo "AWS Resources Created:"
        echo "  Data Bucket: $data_bucket"
        echo "  DynamoDB Tables: ${PROJECT_NAME}-${ENVIRONMENT}-players, ${PROJECT_NAME}-${ENVIRONMENT}-fixtures, ${PROJECT_NAME}-${ENVIRONMENT}-teams"
        echo ""
        echo "Next Steps:"
        echo "  1. SSH into your EC2 instance using the command above"
        echo "  2. Clone your project repository"
        echo "  3. Start setting up your data collection scripts"
        echo ""
        echo "========================================================================================"
        
    else
        print_error "Infrastructure deployment failed!"
        exit 1
    fi
}

# Function to cleanup resources
cleanup_infrastructure() {
    print_warning "This will delete all resources created by this script."
    read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deleting CloudFormation stack: $STACK_NAME"
        
        aws cloudformation delete-stack \
            --stack-name "$STACK_NAME" \
            --region "$REGION"
        
        print_status "Stack deletion initiated. This may take a few minutes."
        
        # Wait for stack deletion to complete
        print_status "Waiting for stack deletion to complete..."
        aws cloudformation wait stack-delete-complete \
            --stack-name "$STACK_NAME" \
            --region "$REGION"
        
        print_status "Stack deleted successfully!"
        
        # Optionally delete the key pair
        local key_name="${PROJECT_NAME}-${ENVIRONMENT}-key"
        read -p "Do you want to delete the key pair ${key_name}? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            aws ec2 delete-key-pair --key-name "$key_name" --region "$REGION"
            rm -f "${key_name}.pem"
            print_status "Key pair deleted."
        fi
    else
        print_status "Cleanup cancelled."
    fi
}

# Function to show stack status
show_status() {
    print_status "Checking stack status..."
    
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --query 'Stacks[0].{StackName:StackName,StackStatus:StackStatus,CreationTime:CreationTime}' \
        --output table
}

# Main script logic
case "${1:-deploy}" in
    deploy)
        deploy_infrastructure
        ;;
    cleanup)
        cleanup_infrastructure
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: $0 {deploy|cleanup|status}"
        echo ""
        echo "  deploy  - Deploy the infrastructure"
        echo "  cleanup - Delete all resources"
        echo "  status  - Show current stack status"
        exit 1
        ;;
esac
