param location string
param nsg object

resource nsgResource 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsg.name
  location: location
  properties: {
    securityRules: nsg.securityRules
  }
}

output nsgId string = nsgResource.id
