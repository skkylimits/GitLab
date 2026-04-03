targetScope = 'subscription'

param location string
param rg object

param network object
param compute object
param identity object

// 📦 Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rg.name
  location: location
  tags: rg.tags
}

// 🚀 Deploy jouw bestaande main.bicep
module app './main.bicep' = {
  name: 'app-deployment'
  scope: resourceGroup
  params: {
    location: location
    network: network
    compute: compute
    identity: identity
  }
}
