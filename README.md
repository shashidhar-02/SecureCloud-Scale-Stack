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

## Continuous Integration

Pull requests and pushes to `main` run Terraform formatting and validation,
TFLint, Checkov, GitHub's default CodeQL code-scanning setup, and SonarCloud
analysis. The repository uses GitHub's default CodeQL setup; do not enable a
second advanced CodeQL workflow for the same repository. Terraform validation
initializes each root with the backend disabled, so CI does not need AWS
credentials or access to a remote state backend.

To enable SonarCloud, import this repository into SonarCloud and add the following GitHub configuration under **Settings → Secrets and variables → Actions**:

* Repository variables: `SONAR_ORGANIZATION` and `SONAR_PROJECT_KEY`
* Repository secret: `SONAR_TOKEN`

SonarCloud analysis waits for the quality gate and fails the workflow when the gate fails. SonarCloud is skipped for pull requests from forks because GitHub does not expose repository secrets to those workflows. Configure the Terraform CI and SonarCloud checks as required status checks in branch protection after their first successful run.

## 🛠️ Step-by-Step Implementation Guide

Follow these commands to configure, test, and deploy this infrastructure.

### Prerequisites

* AWS CLI configured with active credentials (`aws configure`)
* Note: All other prerequisites (Terraform, TFLint, Checkov) can be automatically installed via our Makefile!

### Step 1: Install Tools
Run the setup script via Makefile to install all required tooling automatically:
```bash
make setup
```

### Step 2: Bootstrap the Backend (One-Time Setup)
Terraform uses an S3 bucket and DynamoDB table to store and lock state. The
bootstrap command creates stable, account-specific names; rerunning it is safe.

```bash
make bootstrap ENV=dev
make init ENV=dev
```

The backend configuration is supplied to Terraform by `make init`; do not edit
the partial S3 backend block in `environments/dev/backend.tf`. `make plan`,
`make apply`, and `make destroy` initialize the selected environment
automatically. Set `AWS_REGION` if you want to use a region other than
`us-east-1`.

### Step 3: Set Variables & Secure Access
Create `environments/dev/terraform.tfvars` with values for the required
environment variables declared in `environments/dev/variables.tf`.
**Crucial Steps for Execution:**
1. Provide a valid `certificate_arn` for your ALB HTTPS listener.
2. Set `public_access_cidrs` to only your corporate VPN/office IP address
   (e.g., `["203.0.113.50/32"]`). This variable has no permissive default.

### Step 4: Initialize & Run DevSecOps Quality Gates
Run our pre-configured static analysis to catch misconfigurations and security vulnerabilities:

```bash
# Initialize Terraform
make init ENV=dev

# Run formatting and linting (TFLint)
make lint

# Run Checkov for comprehensive security scanning
make scan
```

### Step 5: Plan and Deploy

```bash
# Generate and review the execution plan
make plan ENV=dev

# Apply the validated plan
make apply ENV=dev
```

### Step 6: Retrieve Database Credentials
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
make destroy ENV=dev
```

---
