# =============================================================================
# Terraform Validation Tests
# =============================================================================
# Run with: terraform test (Terraform >= 1.6)
# =============================================================================

run "verify_networking_module_outputs" {
  command = plan

  module {
    source = "../../modules/networking"
  }

  variables {
    project_prefix = "test"
    location       = "centralus"
    tags           = { Environment = "test" }
  }

  assert {
    condition     = output.hub_vnet_id != ""
    error_message = "Hub VNet ID should not be empty"
  }

  assert {
    condition     = output.spoke_vnet_id != ""
    error_message = "Spoke VNet ID should not be empty"
  }
}

run "verify_naming_convention" {
  command = plan

  module {
    source = "../../modules/networking"
  }

  variables {
    project_prefix = "dlz-test"
    location       = "centralus"
    tags           = { Environment = "test" }
  }

  assert {
    condition     = output.hub_vnet_name == "dlz-test-hub-vnet"
    error_message = "Hub VNet name should follow naming convention"
  }

  assert {
    condition     = output.spoke_vnet_name == "dlz-test-spoke-vnet"
    error_message = "Spoke VNet name should follow naming convention"
  }
}
