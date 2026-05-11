plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.28.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Azurerm rules — installed but NOT enforced yet. Enablement deferred to Phase 4.
# Individual rule enables go here after Phase 1 4.x migration is complete.
