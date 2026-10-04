.PHONY: help setup bootstrap init fmt-check lint scan plan apply destroy

ENV ?= dev
AWS_REGION ?= us-east-1
PATH := $(HOME)/.local/bin:$(PATH)

ifneq ($(filter bootstrap init plan apply destroy,$(MAKECMDGOALS)),)
ifeq ($(ENV),dev)
ENVIRONMENT := dev
else ifeq ($(ENV),staging)
ENVIRONMENT := staging
else ifeq ($(ENV),prod)
ENVIRONMENT := prod
else
$(error ENV must be one of: dev, staging, prod)
endif
endif

help:
	@echo "=========================================================="
	@echo "SecureCloud-Scale-Stack DevSecOps Makefile"
	@echo "=========================================================="
	@echo "Usage: make [target] ENV=[environment]"
	@echo ""
	@echo "Targets:"
	@echo "  setup      Install all necessary prerequisites (Terraform, TFLint, Checkov)"
	@echo "  bootstrap  Create the S3 state bucket and DynamoDB lock table for ENV"
	@echo "  init       Initialize Terraform for ENV (requires AWS credentials)"
	@echo "  fmt-check  Check Terraform formatting without changing files"
	@echo "  lint       Run Terraform fmt and TFLint across the codebase"
	@echo "  scan       Run Checkov security scan"
	@echo "  plan       Generate a Terraform plan for the given ENV"
	@echo "  apply      Apply the Terraform plan for the given ENV"
	@echo "  destroy    Destroy the infrastructure for the given ENV"
	@echo ""

setup:
	@./scripts/setup-prerequisites.sh

bootstrap:
	@bash scripts/bootstrap-backend.sh "$(ENVIRONMENT)" "$(AWS_REGION)"

init:
	@set -e; \
	account_id="$$(aws sts get-caller-identity --query Account --output text)"; \
	terraform -chdir="environments/$(ENVIRONMENT)" init -input=false \
		-backend-config="bucket=securecloud-terraform-state-$${account_id}-$(ENVIRONMENT)" \
		-backend-config="key=$(ENVIRONMENT)/terraform.tfstate" \
		-backend-config="region=$(AWS_REGION)" \
		-backend-config="encrypt=true" \
		-backend-config="dynamodb_table=securecloud-terraform-locks-$(ENVIRONMENT)"

fmt-check:
	@terraform fmt -check -recursive

lint:
	@echo "Running terraform fmt..."
	@terraform fmt -recursive
	@echo "Running tflint..."
	@tflint --init
	@tflint --recursive

scan:
	@echo "Running Checkov security scan..."
	@checkov --directory . --config-file .checkov.yml

plan: init
	@terraform -chdir="environments/$(ENVIRONMENT)" plan -input=false -out=tfplan

apply: init
	@terraform -chdir="environments/$(ENVIRONMENT)" apply -input=false tfplan

destroy: init
	@terraform -chdir="environments/$(ENVIRONMENT)" destroy -auto-approve -input=false
