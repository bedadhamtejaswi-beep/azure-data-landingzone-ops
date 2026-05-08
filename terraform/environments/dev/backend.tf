# Dev environment - use local state for development
# For production, configure remote backend (see prod/backend.tf)
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# TODO: Migrate dev to remote backend before production deployment
