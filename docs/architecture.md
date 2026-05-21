# Architecture

## Overview

The Azure Data Landing Zone is designed as an enterprise-grade data platform following Microsoft's Cloud Adoption Framework (CAF) and Azure Landing Zone architecture patterns.

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                        Azure Subscription                        │
│                                                                  │
│  ┌─────────────────────┐     ┌─────────────────────────────────┐│
│  │     Hub VNet         │     │     Spoke VNet (Data LZ)       ││
│  │   (10.0.0.0/16)     │     │     (10.1.0.0/16)              ││
│  │                     │     │                                 ││
│  │  ┌──────────────┐  │VNet │  ┌──────────────────────────┐  ││
│  │  │ Gateway      │  │Peer │  │ Data Subnet              │  ││
│  │  │ Subnet       │◄─┼─────┼─►│ - PostgreSQL (delegated) │  ││
│  │  └──────────────┘  │     │  │ - VMs                     │  ││
│  │                     │     │  └──────────────────────────┘  ││
│  │  ┌──────────────┐  │     │                                 ││
│  │  │ Azure        │  │     │  ┌──────────────────────────┐  ││
│  │  │ Firewall     │  │     │  │ Databricks Subnets       │  ││
│  │  └──────────────┘  │     │  │ - Public (host)          │  ││
│  │                     │     │  │ - Private (container)    │  ││
│  │  ┌──────────────┐  │     │  └──────────────────────────┘  ││
│  │  │ Shared       │  │     │                                 ││
│  │  │ Services     │  │     │  ┌──────────────────────────┐  ││
│  │  │ (Monitoring) │  │     │  │ Private Endpoints        │  ││
│  │  └──────────────┘  │     │  │ - Storage, KV, Cosmos DB │  ││
│  │                     │     │  └──────────────────────────┘  ││
│  └─────────────────────┘     └─────────────────────────────────┘│
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                     Azure PaaS Services                      ││
│  │                                                               ││
│  │  ┌─────────────┐  ┌──────────┐  ┌─────────┐  ┌───────────┐ ││
│  │  │ PostgreSQL  │  │Databricks│  │Data Lake │  │ Cosmos DB │ ││
│  │  │ Flex Server │  │Workspace │  │Storage   │  │ (NoSQL)   │ ││
│  │  │ (HA)        │  │(Premium) │  │Gen2      │  │           │ ││
│  │  └─────────────┘  └──────────┘  └─────────┘  └───────────┘ ││
│  │                                                               ││
│  │  ┌─────────────┐  ┌──────────┐  ┌───────────────────────┐  ││
│  │  │ Key Vault   │  │   Log    │  │ Azure Monitor         │  ││
│  │  │ (Secrets)   │  │Analytics │  │ (Alerts & Dashboards) │  ││
│  │  └─────────────┘  └──────────┘  └───────────────────────┘  ││
│  └─────────────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────────────┘
```

## Design Decisions

### 1. Hub-Spoke Network Topology
- **Why:** Centralized network management, shared services, and security controls
- **Hub:** Gateway, Firewall, shared monitoring
- **Spoke:** Isolated data workloads with controlled egress

### 2. Private Endpoints
- **Why:** All PaaS services accessed over private network only
- **Impact:** No public internet exposure for databases or storage
- **Compliance:** Required for HIPAA

### 3. Modular Terraform
- **Why:** Reusable, testable, environment-agnostic modules
- **Pattern:** Each Azure service is a self-contained module
- **Environments:** Dev and Prod share modules but differ in sizing and HA

### 4. Zone-Redundant PostgreSQL
- **Why:** Healthcare data requires high availability
- **RTO:** < 10 minutes for intra-region failover
- **RPO:** Near-zero data loss

### 5. Data Lake Zones
- **Raw:** Unprocessed data as ingested
- **Curated:** Cleaned and standardized data
- **Enriched:** Analytics-ready datasets
- **Archive:** Long-term retention


## Data Flow
Raw data ingested into ADLS raw zone, processed through Databricks.
