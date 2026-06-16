.PHONY: help setup lint plan apply destroy

ENV ?= dev

help:
	@echo "=========================================================="
	@echo "SecureCloud-Scale-Stack DevSecOps Makefile"
	@echo "=========================================================="
	@echo "Usage: make [target] ENV=[environment]"
	@echo ""
	@echo "Targets:"
	@echo "  setup      Install all necessary prerequisites (Terraform, TFLint, Checkov)"
	@echo "  bootstrap  Run the backend bootstrap script for the given ENV (e.g. make bootstrap ENV=dev)"
	@echo "  init       Initialize Terraform for the given ENV"
	@echo "  lint       Run Terraform fmt and TFLint across the codebase"
	@echo "  scan       Run Checkov security scan"
	@echo "  plan       Generate a Terraform plan for the given ENV"
	@echo "  apply      Apply the Terraform plan for the given ENV"
	@echo "  destroy    Destroy the infrastructure for the given ENV"
	@echo ""

setup:
	@./scripts/setup-prerequisites.sh

bootstrap:
	@./scripts/bootstrap-backend.sh $(ENV)

init:
	@cd environments/$(ENV) && terraform init

lint:
	@echo "Running terraform fmt..."
	@terraform fmt -recursive
	@echo "Running tflint..."
	@tflint --recursive

scan:
	@echo "Running Checkov security scan..."
	@checkov -d .

plan:
	@cd environments/$(ENV) && terraform plan -out=tfplan

apply:
	@cd environments/$(ENV) && terraform apply "tfplan"

destroy:
	@cd environments/$(ENV) && terraform destroy -auto-approve
