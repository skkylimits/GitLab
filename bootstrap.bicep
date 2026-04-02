targetScope = 'subscription'

param location string
param rg object
param network object
param compute object
param identity object

resource RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rg.name
  location: location
  tags: rg.tags ?? {}
}

module app './main.bicep' = {
  name: 'GitLab'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    network: network
    compute: compute
    identity: identity
  }
}

output vmId string = app.outputs.vmId
output nicId string = app.outputs.nicId
