vnetloop = [
  {
    vnet_name     = "vn-fe-wotlab01"
    address_space = ["10.60.16.0/24"]
    subnets = [
      {
        name    = "AzureBastionSubnet"
        address = "10.60.16.0/27"
      },
      {
        name    = "firewall01"
        address = "10.60.16.32/28"
      },
      {
        name    = "firewall02"
        address = "10.60.16.48/28"
      },
      {
        name    = "management01"
        address = "10.60.16.64/26"
      },
    ]
  },
  {
    vnet_name     = "vn-prod-wotlab01"
    address_space = ["10.60.32.0/24"]
    subnets = [
      {
        name    = "application01"
        address = "10.60.32.0/26"
      },
      {
        name    = "database01"
        address = "10.60.32.64/26"
      },
      {
        name    = "activedirectory"
        address = "10.60.32.128/26"
      },
      {
        name    = "webserver01"
        address = "10.60.32.192/28"
      }
    ]
  },
  {
    vnet_name     = "vn-preprod-wotlab01"
    address_space = ["10.60.64.0/24"]
    subnets = [
      {
        name    = "application01"
        address = "10.60.64.0/26"
      },
      {
        name    = "database01"
        address = "10.60.64.64/26"
      },
      {
        name    = "activedirectory"
        address = "10.60.64.128/26"
      },
      {
        name    = "webserver01"
        address = "10.60.64.192/28"
      }
    ]
  }
]