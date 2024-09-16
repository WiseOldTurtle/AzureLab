provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "no_public_ip" {
  name         = "deny-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IP Creation"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Network/publicIPAddresses"
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY
}

resource "azurerm_policy_assignment" "no_public_ip_assignment" {
  name                 = "no-public-ip-assignment"
  policy_definition_id = azurerm_policy_definition.no_public_ip.id
  scope                = "/subscriptions/${var.subscription_id}"
}

resource "azurerm_policy_definition" "vm_sku_policy" {
  name         = "limit-vm-skus"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Limit VM SKUs to Small Sizes"

  policy_rule = <<POLICY
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Compute/virtualMachines"
        },
        {
          "field": "Microsoft.Compute/virtualMachines/sku.name",
          "notIn": [
            "Standard_B1ls",
            "Standard_B1s",
            "Standard_B2s"
          ]
        }
      ]
    },
    "then": {
      "effect": "Deny"
    }
  }
  POLICY
}

resource "azurerm_policy_assignment" "vm_sku_policy_assignment" {
  name                 = "vm-sku-assignment"
  policy_definition_id = azurerm_policy_definition.vm_sku_policy.id
  scope                = "/subscriptions/${var.subscription_id}"
}
