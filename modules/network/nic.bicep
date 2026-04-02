param location string
param nic object
param subnetId string
param nsgId string

resource nicResource 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nic.name
  location: location
  properties: {
    networkSecurityGroup: {
      id: nsgId
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

output nicId string = nicResource.id
