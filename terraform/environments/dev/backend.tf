# Dev environment - use local state for development
# For production, configure remote backend (see prod/backend.tf)
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
