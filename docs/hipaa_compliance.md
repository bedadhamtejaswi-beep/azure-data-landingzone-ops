# HIPAA Compliance Checklist

This document tracks HIPAA compliance controls implemented in the Azure Data Landing Zone.

## Technical Safeguards

### Access Control (§164.312(a))

| Control | Status | Implementation |
|---------|--------|----------------|
| Unique user identification | ✅ | Azure AD with MFA |
| Emergency access procedure | ✅ | Break-glass accounts in Key Vault |
| Automatic logoff | ✅ | Session timeout configured |
| Encryption and decryption | ✅ | TLS 1.2+, AES-256 at rest |

### Audit Controls (§164.312(b))

| Control | Status | Implementation |
|---------|--------|----------------|
| Audit logging enabled | ✅ | Azure Monitor + Log Analytics |
| Log retention | ✅ | 90 days in Log Analytics |
| Database audit logging | ✅ | PostgreSQL log_connections/disconnections enabled |
| OS-level audit | ✅ | auditd with HIPAA rules (Ansible) |
| Access monitoring | ✅ | Key Vault audit events |

### Integrity Controls (§164.312(c))

| Control | Status | Implementation |
|---------|--------|----------------|
| Data integrity validation | ✅ | Checksums on data transfer |
| Mechanism to authenticate ePHI | ✅ | HMAC/digital signatures |
| Backup integrity | ✅ | Automated backup validation |

### Transmission Security (§164.312(e))

| Control | Status | Implementation |
|---------|--------|----------------|
| Encryption in transit | ✅ | TLS 1.2 enforced on all connections |
| Network segmentation | ✅ | NSGs, private endpoints, VNet isolation |
| No public endpoints | ✅ | All PaaS services private-only |

## Physical Safeguards (Azure Responsibility)

| Control | Status | Notes |
|---------|--------|-------|
| Facility access controls | ✅ | Azure data center security |
| Workstation security | ✅ | Azure managed infrastructure |
| Device and media controls | ✅ | Azure disk encryption |

## Administrative Safeguards (Operational)

| Control | Status | Implementation |
|---------|--------|----------------|
| Risk analysis | ✅ | Quarterly security review |
| Workforce training | ✅ | Annual HIPAA training |
| Incident procedures | ✅ | Incident response runbook |
| Contingency plan | ✅ | DR plan with quarterly testing |
| Business associate agreements | ✅ | Microsoft BAA signed |

## Azure-Specific HIPAA Controls

- [x] Azure BAA (Business Associate Agreement) executed
- [x] All resources deployed in HIPAA-eligible Azure services
- [x] Customer-managed encryption keys for sensitive data
- [x] Network isolation via Private Endpoints
- [x] NSGs configured with deny-all-internet rules
- [x] Soft delete and purge protection on Key Vault
- [x] Geo-redundant backups enabled
- [x] Azure Policy for compliance enforcement
- [x] Microsoft Defender for Cloud enabled
