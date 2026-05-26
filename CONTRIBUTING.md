# Contributing to Azure Data Landing Zone Ops

Thank you for considering contributing to this project!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/<your-username>/azure-data-landingzone-ops.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run validation: `make validate && make ansible-lint`
6. Commit with conventional commit format: `git commit -m "feat(module): description"`
7. Push and open a Pull Request

## Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

Types:
  feat     - New feature
  fix      - Bug fix
  docs     - Documentation changes
  ci       - CI/CD changes
  refactor - Code refactoring
  test     - Adding tests
  chore    - Maintenance tasks
```

## Code Standards

### Terraform
- Use `terraform fmt` before committing
- All modules must have `variables.tf`, `outputs.tf`, and `main.tf`
- Use descriptive variable names with `description` field
- Tag all resources with `var.tags`

### Ansible
- Pass `ansible-lint` checks
- Use YAML format consistently
- Include `name` for all tasks
- Use `become: true` only when necessary

### Documentation
- Update relevant docs when making infrastructure changes
- Keep the README current
- Document any new operational procedures

## Pull Request Process

1. PRs trigger automated Terraform plan and security scanning
2. At least 1 approval required
3. All CI checks must pass
4. Squash merge to keep history clean

## Security

- Never commit secrets, keys, or passwords
- Use Azure Key Vault for sensitive values
- Report security issues privately to the team
