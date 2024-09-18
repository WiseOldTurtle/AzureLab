provider "azurerm" {
  features {}
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
  resource_group_id    = azurerm_resource_group.platform_management_rg.id
  policy_definition_id = azurerm_policy_definition.vm_size_policy.id
}

resource "azurerm_resource_group_policy_assignment" "application_vm_size_policy" {
  name                 = "application-vm-size-policy"
  resource_group_id    = azurerm_resource_group.application_rg.id
  policy_definition_id = azurerm_policy_definition.vm_size_policy.id
}
