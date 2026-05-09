# Production backend - Azure Storage Account for remote state
# Requires pre-created storage account for state management
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "dlztfstateprod"
    container_name       = "tfstate"
    key                  = "prod/data-landingzone.tfstate"
  }
}

# State file is encrypted at rest via Azure Storage SSE
