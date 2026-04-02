param location string
param vnet object

resource vnetResource 'Microsoft.Network/virtualNetworks@2023-09-01' = {
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

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnetResource
  name: vnet.subnet.name
  properties: {
    addressPrefix: vnet.subnet.prefix
  }
}

output vnetId string = vnetResource.id
output subnetId string = subnet.id
