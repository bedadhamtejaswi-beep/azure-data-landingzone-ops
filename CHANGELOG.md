# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.0] - 2026-05-24

### Added
- Comprehensive README with architecture diagrams
- Team onboarding guide
- Troubleshooting documentation
- HIPAA compliance checklist

## [1.1.0] - 2026-05-18

### Added
- Azure Monitor dashboard templates (platform overview, database performance)
- Alert rule ARM templates (CPU, storage, pipeline failure)
- Incident response runbook with severity levels
- Capacity planning runbook
- Disaster recovery plan with RTO/RPO matrix
- DR test checklist for quarterly validation
- Operational scripts (health check, capacity forecast, backup validation, network diagnostics)

## [1.0.0] - 2026-05-14

### Added
- Liquibase database migrations (patients, claims, audit tables)
- GitHub Actions CI/CD pipelines (Terraform plan/apply, Ansible lint, Liquibase migrate, DR validation)
- Ansible playbooks (VM configuration, monitoring agent, PostgreSQL management, DR automation)
- Ansible roles (base, security, monitoring)

## [0.2.0] - 2026-05-09

### Added
- Development environment configuration
- Production environment configuration with HA and geo-redundancy
- Remote backend configuration for production state

## [0.1.0] - 2026-05-07

### Added
- Terraform modules: networking, databricks, postgresql, cosmosdb, storage, keyvault, monitoring
- Hub-spoke VNet architecture with NSGs and private DNS
- PostgreSQL Flexible Server with zone-redundant HA
- VNet-injected Databricks workspace
- Cosmos DB with auto-failover
- ADLS Gen2 with lifecycle policies
- Key Vault with RBAC and purge protection
- Azure Monitor with Log Analytics and alert rules

## [0.0.1] - 2026-05-01

### Added
- Initial project structure
- .gitignore and LICENSE
