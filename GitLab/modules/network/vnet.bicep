param location string
param vnet object

resource VirtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnet.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnet.addressPrefix]
    }
    subnets: [
      {
        name: vnet.subnet.name
        properties: {
          addressPrefix: vnet.subnet.prefix
        }
      }
    ]
  }
}

resource Subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: VirtualNetwork
  name: vnet.subnet.name
  properties: {
    addressPrefix: vnet.subnet.prefix
  }
}

output vnetId string = VirtualNetwork.id
output subnetId string = Subnet.id
