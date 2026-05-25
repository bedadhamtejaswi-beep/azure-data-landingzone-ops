# Makefile for Azure Data Landing Zone Operations
# Common commands for development and operations

.PHONY: help init plan apply destroy lint validate format docs clean

SHELL := /bin/bash
ENV ?= dev

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# =============================================================================
# Terraform Commands
# =============================================================================
init: ## Initialize Terraform for the specified environment (ENV=dev|prod)
	cd terraform/environments/$(ENV) && terraform init

plan: ## Run Terraform plan (ENV=dev|prod)
	cd terraform/environments/$(ENV) && terraform plan

apply: ## Run Terraform apply (ENV=dev|prod)
	cd terraform/environments/$(ENV) && terraform apply

destroy: ## Run Terraform destroy (ENV=dev|prod) - USE WITH CAUTION
	cd terraform/environments/$(ENV) && terraform destroy

format: ## Format all Terraform files
	terraform fmt -recursive terraform/

validate: ## Validate all Terraform configurations
	@for dir in terraform/environments/*/; do \
		echo "Validating $$dir..."; \
		cd $$dir && terraform init -backend=false > /dev/null 2>&1 && terraform validate && cd -; \
	done

# =============================================================================
# Ansible Commands
# =============================================================================
ansible-lint: ## Lint all Ansible playbooks
	ansible-lint ansible/playbooks/*.yml

ansible-check: ## Run Ansible playbooks in check mode (ENV=dev|prod)
	ansible-playbook ansible/playbooks/configure_vm.yml -i ansible/inventory/$(ENV).ini --check --diff

ansible-run: ## Run all Ansible playbooks (ENV=dev|prod)
	ansible-playbook ansible/playbooks/configure_vm.yml -i ansible/inventory/$(ENV).ini
	ansible-playbook ansible/playbooks/install_monitoring_agent.yml -i ansible/inventory/$(ENV).ini

# =============================================================================
# Liquibase Commands
# =============================================================================
db-status: ## Check Liquibase migration status
	cd liquibase && liquibase --changeLogFile=changelog/db.changelog-master.xml status

db-migrate: ## Run Liquibase migrations
	cd liquibase && liquibase --changeLogFile=changelog/db.changelog-master.xml update

db-rollback: ## Rollback last Liquibase migration
	cd liquibase && liquibase --changeLogFile=changelog/db.changelog-master.xml rollbackCount 1

db-validate: ## Validate Liquibase changelogs
	cd liquibase && liquibase --changeLogFile=changelog/db.changelog-master.xml validate

# =============================================================================
# Operations Commands
# =============================================================================
health-check: ## Run platform health check (ENV=dev|prod)
	./scripts/az_health_check.sh $(ENV)

capacity: ## Run capacity forecast (ENV=dev|prod)
	./scripts/az_capacity_forecast.sh $(ENV)

backup-check: ## Validate backups (ENV=dev|prod)
	./scripts/az_backup_validate.sh $(ENV)

network-diag: ## Run network diagnostics (ENV=dev|prod)
	./scripts/az_network_diagnostics.sh $(ENV)

# =============================================================================
# Security & Compliance
# =============================================================================
security-scan: ## Run security scan on Terraform code
	tfsec terraform/
	checkov -d terraform/

# =============================================================================
# Cleanup
# =============================================================================
clean: ## Clean up temporary files
	find . -name "*.tfplan" -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "*.retry" -delete
