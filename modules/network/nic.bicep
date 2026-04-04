param location string
param nic object
param subnetId string  // krijgt waarde van module vnet.outputs.subnetId
param nsgId string     // krijgt waarde van module nsg.outputs.nsgId

// Let op: deze IDs komen niet rechtstreeks uit gitlab.bicepparam.
// Ze zijn runtime IDs die uit de eerder deployde resources (vnet/nsg) worden doorgegeven.
resource NetworkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nic.name
  location: location
  properties: {
    networkSecurityGroup: {
      id: nsgId
    }
    ipConfigurations: [
      for ipConfiguration in nic.ipConfigurations: {
        name: ipConfiguration.name
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: ipConfiguration.privateIPAllocationMethod
        }
      }
    ]
  }
}

output nicId string = NetworkInterface.id
