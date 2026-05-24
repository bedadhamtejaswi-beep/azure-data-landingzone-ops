# Azure Data Landing Zone - Operations Platform

![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-%230072C6.svg?style=flat&logo=microsoftazure&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-%231A1918.svg?style=flat&logo=ansible&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-%232671E5.svg?style=flat&logo=githubactions&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-%23316192.svg?style=flat&logo=postgresql&logoColor=white)
![Databricks](https://img.shields.io/badge/Databricks-%23FF3621.svg?style=flat&logo=databricks&logoColor=white)

An enterprise-grade **Infrastructure as Code** platform for deploying, monitoring, and maintaining an Azure-based Data Landing Zone. Built to support **HIPAA-compliant healthcare analytics** with high availability, disaster recovery, and comprehensive observability.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     Azure Data Landing Zone                      │
│                                                                  │
│   Hub VNet (Shared Services)          Spoke VNet (Data LZ)      │
│   ┌───────────────────────┐          ┌─────────────────────┐    │
│   │ • Gateway Subnet      │  VNet    │ • Data Subnet       │    │
│   │ • Azure Firewall      │◄─Peer──►│ • Databricks (VNet) │    │
│   │ • Monitoring          │          │ • Private Endpoints  │    │
│   └───────────────────────┘          └─────────────────────┘    │
│                                                                  │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │
│   │PostgreSQL│ │Databricks│ │Data Lake │ │   Cosmos DB      │  │
│   │Flex (HA) │ │ Premium  │ │ Gen2     │ │   (NoSQL)        │  │
│   └──────────┘ └──────────┘ └──────────┘ └──────────────────┘  │
│                                                                  │
│   ┌──────────┐ ┌──────────┐ ┌──────────────────────────────┐   │
│   │Key Vault │ │   Log    │ │  Azure Monitor (Alerts/Dash) │   │
│   └──────────┘ │Analytics │ └──────────────────────────────┘   │
│                └──────────┘                                      │
└─────────────────────────────────────────────────────────────────┘
```

## 📋 Features

| Category | Details |
|----------|---------|
| **Infrastructure** | Modular Terraform with environment separation (dev/prod) |
| **Networking** | Hub-spoke topology, VNet peering, NSGs, Private Endpoints, Private DNS |
| **Data Services** | PostgreSQL Flex (HA), Databricks (VNet-injected), ADLS Gen2, Cosmos DB |
| **Security** | HIPAA-compliant, Key Vault with RBAC, TLS 1.2, no public endpoints |
| **CI/CD** | GitHub Actions — plan on PR, apply on merge, security scanning |
| **Monitoring** | Azure Monitor, Log Analytics, custom alerts, dashboards |
| **DB Migrations** | Liquibase-managed schema versioning with rollback support |
| **Config Mgmt** | Ansible playbooks for VM hardening, monitoring agent, PostgreSQL |
| **DR** | Cross-region DR with automated failover playbooks, quarterly testing |
| **Ops Scripts** | Azure CLI scripts for health checks, capacity forecasting, backup validation |

## 📁 Project Structure

```
├── terraform/                    # Infrastructure as Code
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── networking/           #   Hub-spoke VNet, NSGs, DNS, peering
│   │   ├── databricks/           #   Databricks workspace (VNet-injected)
│   │   ├── postgresql/           #   PostgreSQL Flexible Server (HA)
│   │   ├── cosmosdb/             #   Cosmos DB (NoSQL, multi-region)
│   │   ├── monitoring/           #   Log Analytics, alerts, App Insights
│   │   ├── keyvault/             #   Key Vault (RBAC, purge protection)
│   │   └── storage/              #   Data Lake Storage Gen2
│   └── environments/
│       ├── dev/                  #   Development configuration
│       └── prod/                 #   Production configuration (HA + GRS)
│
├── ansible/                      # Configuration Management
│   ├── playbooks/
│   │   ├── configure_vm.yml      #   CIS-hardened VM baseline
│   │   ├── install_monitoring_agent.yml
│   │   ├── configure_postgresql.yml
│   │   └── disaster_recovery.yml #   Automated DR failover
│   └── inventory/
│
├── .github/workflows/            # CI/CD Pipelines
│   ├── terraform-plan.yml        #   PR → plan + security scan
│   ├── terraform-apply.yml       #   Merge → apply (dev → prod)
│   ├── ansible-lint.yml          #   Ansible validation
│   ├── liquibase-migrate.yml     #   Database migrations
│   └── dr-validation.yml         #   Weekly DR readiness check
│
├── liquibase/                    # Database Schema Migrations
│   └── changelog/                #   Versioned migration files
│
├── scripts/                      # Operational Scripts (Azure CLI)
│   ├── az_health_check.sh        #   Platform health assessment
│   ├── az_capacity_forecast.sh   #   Capacity trend analysis
│   ├── az_backup_validate.sh     #   Backup configuration check
│   └── az_network_diagnostics.sh #   Network troubleshooting
│
├── monitoring/                   # Observability
│   ├── dashboards/               #   Azure Dashboard templates
│   └── runbooks/                 #   Incident response & capacity planning
│
├── disaster-recovery/            # DR Documentation
│   ├── dr_plan.md                #   Full DR strategy
│   ├── rto_rpo_matrix.md         #   Recovery objectives matrix
│   └── dr_test_checklist.md      #   Quarterly test procedure
│
└── docs/                         # Technical Documentation
    ├── architecture.md           #   Architecture & design decisions
    ├── networking.md             #   Network topology reference
    ├── hipaa_compliance.md       #   HIPAA controls checklist
    ├── onboarding.md             #   New team member guide
    └── troubleshooting.md        #   Common issues & resolutions
```

## 🚀 Quick Start

### Prerequisites
- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.15
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.50
- [Liquibase](https://www.liquibase.org/download) >= 4.25
- Azure subscription with Contributor access

### Deploy to Development

```bash
# 1. Clone the repository
git clone https://github.com/bedadhamtejaswi-beep/azure-data-landingzone-ops.git
cd azure-data-landingzone-ops

# 2. Authenticate with Azure
az login
az account set --subscription <YOUR_SUBSCRIPTION_ID>

# 3. Initialize and deploy dev environment
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply

# 4. Configure VMs (after provisioning)
cd ../../../ansible
ansible-playbook playbooks/configure_vm.yml -i inventory/dev.ini

# 5. Run database migrations
cd ../liquibase
liquibase --changeLogFile=changelog/db.changelog-master.xml update

# 6. Verify deployment
cd ../scripts
./az_health_check.sh dev
```

## 🔄 CI/CD Pipeline

```
┌──────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Commit  │────►│  PR Created  │────►│  Plan + Scan │────►│   Review     │
└──────────┘     └──────────────┘     └──────────────┘     └──────┬───────┘
                                                                   │
                 ┌──────────────┐     ┌──────────────┐     ┌──────▼───────┐
                 │  Prod Apply  │◄────│  Dev Apply   │◄────│   Merge      │
                 │  (approval)  │     │  (auto)      │     └──────────────┘
                 └──────────────┘     └──────────────┘
```

- **Pull Request:** Triggers `terraform plan`, `tfsec`, `checkov`, `ansible-lint`
- **Merge to main:** Auto-applies to dev, then prod (with environment approval gate)
- **Scheduled:** Weekly DR validation checks

## 🛡️ Security & Compliance

- **HIPAA Compliant:** All services configured per HIPAA technical safeguards
- **Zero Trust Network:** No public endpoints, all traffic via Private Endpoints
- **Encryption:** TLS 1.2 in transit, AES-256 at rest, Key Vault-managed keys
- **Audit Logging:** Comprehensive audit trail via Azure Monitor + OS-level auditd
- **Access Control:** Azure AD + RBAC, MFA enforced, break-glass procedures

See [docs/hipaa_compliance.md](docs/hipaa_compliance.md) for the full compliance checklist.

## 📊 Monitoring & Alerting

| Alert | Threshold | Severity | Action |
|-------|-----------|----------|--------|
| PostgreSQL CPU | > 80% avg (15min) | SEV-2 | Email to critical group |
| PostgreSQL Storage | > 85% | SEV-2 | Email to critical group |
| Active Connections | > 100 | SEV-3 | Email to warning group |
| Failed Auth Attempts | > 10 in 30min | SEV-2 | Email to critical group |

## 🔧 Technology Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | >= 1.5 | Infrastructure provisioning |
| Ansible | >= 2.15 | Configuration management |
| GitHub Actions | N/A | CI/CD pipelines |
| Azure CLI | >= 2.50 | Operational scripts |
| Liquibase | >= 4.25 | Database schema migrations |
| PostgreSQL | 15 | Relational database |
| Databricks | Premium | Analytics & data processing |
| Cosmos DB | N/A | NoSQL event store |

## 📖 Documentation

- [Architecture & Design Decisions](docs/architecture.md)
- [Network Topology](docs/networking.md)
- [HIPAA Compliance Checklist](docs/hipaa_compliance.md)
- [Onboarding Guide](docs/onboarding.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Disaster Recovery Plan](disaster-recovery/dr_plan.md)
- [Incident Response Runbook](monitoring/runbooks/incident_response.md)
- [Capacity Planning Runbook](monitoring/runbooks/capacity_planning.md)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
