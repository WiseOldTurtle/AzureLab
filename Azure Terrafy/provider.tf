provider "azurerm" {
  features {
  }
  subscription_id            = "d9d2ecd3-56a0-4f15-bae9-04b37c0d4335"
  environment                = "public"
  use_msi                    = false
  use_cli                    = true
  use_oidc                   = false
  skip_provider_registration = true
}
