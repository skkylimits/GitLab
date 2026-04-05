param location string
param vnet object

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnet.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet.addressPrefix
      ]
    }
    subnets: [
      {
        name: vnet.gatewaySubnet.name
        properties: {
          addressPrefix: vnet.gatewaySubnet.prefix
        }
      }
    ]
  }
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: virtualNetwork
  name: vnet.gatewaySubnet.name
  properties: {
    addressPrefix: vnet.gatewaySubnet.prefix
  }
}

output vnetId string = virtualNetwork.id
output gatewaySubnetId string = gatewaySubnet.id
