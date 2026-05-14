# Liquibase Database Migrations

This directory contains database schema migrations managed by [Liquibase](https://www.liquibase.org/).

## Structure

```
liquibase/
├── changelog/
│   ├── db.changelog-master.xml    # Master changelog (entry point)
│   ├── v1.0/                      # Version 1.0 migrations
│   │   ├── create_patients_table.xml
│   │   └── create_claims_table.xml
│   └── v1.1/                      # Version 1.1 migrations
│       └── add_audit_columns.xml
└── README.md
```

## Usage

### Validate Changelogs
```bash
liquibase --changeLogFile=changelog/db.changelog-master.xml validate
```

### Run Migrations
```bash
liquibase --changeLogFile=changelog/db.changelog-master.xml update
```

### Check Status
```bash
liquibase --changeLogFile=changelog/db.changelog-master.xml status
```

### Rollback Last Change
```bash
liquibase --changeLogFile=changelog/db.changelog-master.xml rollbackCount 1
```

## CI/CD Integration

Migrations are automatically applied via the `liquibase-migrate.yml` GitHub Actions workflow on merge to `main`.
