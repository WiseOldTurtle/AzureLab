provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-policy-wotlab01" {
  name     = "rg-policy-wotlab01"
  location = "UK South"
}

resource "azurerm_resource_group" "rg-vmpool-wotlab01" {
  name     = "rg-vmpool-wotlab01"
  location = "UK South"
}


resource "azurerm_policy_definition" "vm_size_policy" {
  name         = "Restrict VM Sizes"
  display_name = "Restrict VM Sizes"
  description  = "Restrict virtual machine sizes in the specified resource groups"
  policy_type  = "Custom"
  mode         = "All"


  policy_rule = <<POLICY_RULE
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Compute/virtualMachines"
      },
      {
        "not": {
          "field": "Microsoft.Compute/virtualMachines/sku.name",
          "in": [
            "Standard_B1ls",
            "Standard_B1s",
            "Standard_B1ms"
          ]
        }
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
POLICY_RULE
}

resource "azurerm_resource_group_policy_assignment" "platform_vm_size_policy" {
  name                 = "platform-vm-size-policy"
  resource_group_id    = azurerm_resource_group.rg-policy-wotlab01.id
  policy_definition_id = azurerm_policy_definition.vm_size_policy.id
}
