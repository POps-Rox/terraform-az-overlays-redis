plugin "azurerm" {
  enabled = true
  version = "0.28.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Azure resource validation — fail CI on invalid azurerm config values we just
# migrated to in the 3.x → 4.x cutover. Names that did not exist in
# tflint-ruleset-azurerm v0.28.0 (e.g. *_invalid_account_tier,
# *_invalid_account_replication_type) are tracked as TODO so we can revisit
# when the upstream ruleset adds them.
rule "azurerm_storage_account_invalid_access_tier" {
  enabled = true
}
rule "azurerm_storage_account_invalid_account_kind" {
  enabled = true
}
rule "azurerm_resource_missing_tags" {
  enabled = false # TODO: flip to true after fleet-wide tag policy is defined
}

# Standard terraform plugin rules
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_required_version" {
  enabled = true
}
rule "terraform_required_providers" {
  enabled = true
}
rule "terraform_documented_variables" {
  enabled = false # TODO: too noisy for module surfaces; revisit per repo
}
rule "terraform_documented_outputs" {
  enabled = false # TODO: too noisy; revisit per repo
}
