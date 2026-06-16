#!/bin/bash

# Define the root structure
PROJECT_NAME="SecureCloud-Scale-Stack"
DIRS=(
    "modules/vpc" "modules/eks" "modules/rds" "modules/alb" "modules/security"
    "environments/dev" "environments/staging" "environments/prod"
    "scripts"
)

echo "Creating project structure for $PROJECT_NAME..."

# Create Directories
for dir in "${DIRS[@]}"; do
    mkdir -p "$dir"
    touch "$dir/main.tf" "$dir/variables.tf" "$dir/outputs.tf"
done

# Create root files
touch .tflint.hcl .checkov.yml .gitignore README.md

# Initialize essential files
cat <<EOF > .gitignore
# Terraform state files
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
*.tfvars
.env
EOF

cat <<EOF > README.md
# $PROJECT_NAME
Description: Modular, production-ready AWS infrastructure with DevSecOps guardrails.

## Directory Structure
- **modules/**: Reusable IaC building blocks.
- **environments/**: Environment-specific configurations (dev, staging, prod).
- **scripts/**: Automation for deployment.

## Security
- **Checkov**: Run 'checkov -d .' to scan for misconfigurations.
- **TFLint**: Run 'tflint' to lint HCL code.
EOF

echo "Project structure created successfully!"