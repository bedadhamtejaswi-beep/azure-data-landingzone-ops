# Onboarding Guide

Welcome to the Data Platform Operations team! This guide will help you get started.

## Prerequisites

1. **Azure Access:** Request access to the Azure subscription via ServiceNow
2. **GitHub Access:** Get added to the `data-platform-ops` GitHub team
3. **Tools to Install:**
   - [Terraform](https://www.terraform.io/downloads) >= 1.5.0
   - [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.15
   - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.50
   - [Liquibase](https://www.liquibase.org/download) >= 4.25
   - [Git](https://git-scm.com/)
   - PostgreSQL client tools
   - Python 3.11+

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/bedadhamtejaswi-beep/azure-data-landingzone-ops.git
cd azure-data-landingzone-ops
```

### 2. Authenticate with Azure
```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
```

### 3. Initialize Terraform (Dev)
```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
```

### 4. Run Health Check
```bash
./scripts/az_health_check.sh dev
```

## Team Processes

### Agile/Scrum
- **Sprint Length:** 2 weeks
- **Stand-up:** Daily at 9:30 AM CT
- **Sprint Planning:** First Monday of sprint
- **Sprint Retro:** Last Friday of sprint
- **Board:** Azure DevOps / GitHub Projects

### Change Management
1. Create feature branch from `main`
2. Make changes and push
3. Open Pull Request — triggers Terraform Plan + security scan
4. Get 1 approval from team member
5. Merge — triggers Terraform Apply to dev
6. After validation, prod apply requires environment approval

### On-Call Rotation
- Rotation: Weekly, Monday 8 AM to Monday 8 AM
- Escalation path: On-call → Team Lead → Manager
- Runbooks: `monitoring/runbooks/`
- Alerting: PagerDuty integration via Azure Monitor action groups

## Key Contacts

| Role | Name | Contact |
|------|------|---------|
| Team Lead | Platform Ops Lead | Teams/Slack |
| Azure Admin | Cloud Infrastructure | ServiceNow |
| Security | IS&T Security | security@example.com |
| DBA | Database Team | dba-team@example.com |


## FAQ
See troubleshooting.md for common issues.
