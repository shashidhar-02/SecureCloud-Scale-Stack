# SecureCloud-Scale-Stack

## 🚀 Overview

**SecureCloud-Scale-Stack** is a production-grade Infrastructure as Code (IaC) framework built with **Terraform**. It is engineered to provide a secure, highly available, and scalable AWS environment. By leveraging a modular architecture, this project ensures strict separation of concerns, enabling rapid, reliable, and testable infrastructure deployments.

## 🏗️ Architectural Philosophy & DevSecOps Best Practices

This project adheres strictly to the core principles of Senior DevOps engineering:

* **Modularity & Reusability**: Infrastructure is broken into discrete, versioned modules (VPC, EKS, RDS, etc.). Every module explicitly defines its required provider version (`versions.tf`), eliminating runtime breaking changes.
* **Maintainability & Zero-Hassle Execution**: We balance security with developer experience. EKS endpoints are public but strictly firewalled via CIDR whitelisting, allowing DevOps engineers to seamlessly run `kubectl` without complex VPN/Bastion setups. EKS nodes utilize `AmazonSSMManagedInstanceCore` to replace legacy SSH access with secure Session Manager.
* **Automated Secrets Management**: No passwords are passed via variables. RDS credentials are automatically generated via the `random` provider and securely pushed to AWS Secrets Manager.
* **High Availability Parity**: In `dev`, a single NAT Gateway is used for cost savings. In `prod`, dynamic looping ensures exactly **one NAT Gateway per Availability Zone**, eliminating single points of failure.
* **Reliability & Testability**: Every deployment is validated by static analysis and linting, ensuring code quality before provisioning.
* **Security Guardrails**: Integrated static analysis scans (Checkov/Tflint). Known/intended deviations (like ALB public ingress) are explicitly marked with `# checkov:skip` inline annotations to prevent "noisy" CI/CD pipeline failures.

## 📂 Project Structure

```text
SecureCloud-Scale-Stack/
├── modules/               # Core infrastructure building blocks
│   ├── alb/               # Application Load Balancer
│   ├── eks/               # Elastic Kubernetes Service (SSM-enabled)
│   ├── rds/               # PostgreSQL (Secrets Manager Auth)
│   ├── security/          # KMS Keys and Security Groups
│   └── vpc/               # Dynamic NAT Routing & Flow Logs
├── environments/          # Environment-specific entry points
│   ├── dev/
│   ├── staging/
│   └── prod/
├── scripts/               # Automation & bootstrap utilities
├── .tflint.hcl            # Cloud-native linting rules
├── .checkov.yml           # Security & compliance policy engine
└── .gitignore             # Strict exclusion of state files & sensitive data
```

## 🛠️ Step-by-Step Implementation Guide

Follow these commands to configure, test, and deploy this infrastructure.

### Prerequisites

* Terraform (v1.5+)
* AWS CLI configured with active credentials (`aws configure`)
* `tflint` and `checkov` installed locally.

### Step 1: Bootstrap the Backend (One-Time Setup)
Terraform uses S3 and DynamoDB to store and lock state files securely.

```bash
chmod +x scripts/bootstrap-backend.sh
./scripts/bootstrap-backend.sh dev
```
*Note: Open `environments/dev/backend.tf` and update the `bucket` and `dynamodb_table` fields with the output from this script.*

### Step 2: Set Variables & Secure Access
Navigate to the desired environment (e.g., `dev`):
```bash
cd environments/dev
```

In the `terraform.tfvars` file, ensure your variables are set. 
**Crucial Steps for Execution:**
1. Provide a valid `certificate_arn` for your ALB HTTPS listener.
2. The `public_access_cidrs` in `main.tf` defaults to `0.0.0.0/0` for initial setup. Before applying to production, change this list to contain *only* your corporate VPN/office IP address (e.g., `["203.0.113.50/32"]`).

### Step 3: Run DevSecOps Quality Gates
Run our pre-configured static analysis to catch misconfigurations and security vulnerabilities:

```bash
# Initialize Terraform and download locked provider versions
terraform init

# Ensure code is formatted correctly
terraform fmt -check -recursive ../../

# Run TFLint to check for AWS provider best practices
tflint --recursive

# Run Checkov for comprehensive security scanning
checkov -d ../../
```

### Step 4: Plan and Deploy

```bash
# Generate and review the execution plan
terraform plan -out=tfplan

# Apply the validated plan
terraform apply "tfplan"
```

### Step 5: Retrieve Database Credentials
Because passwords are no longer managed manually, retrieve your RDS password securely via the AWS CLI:
```bash
aws secretsmanager get-secret-value \
  --secret-id dev-rds-password-secret \
  --query SecretString \
  --output text
```

## 🧹 Cleanup
To avoid ongoing AWS charges, destroy the infrastructure when finished:
```bash
terraform destroy -auto-approve
```

---

