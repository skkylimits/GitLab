targetScope = 'subscription'

type peeringVnetConfig = {
  resourceGroupName: string
  vnetName: string
  peeringName: string
}

param location string
param hub peeringVnetConfig
param spoke peeringVnetConfig

resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: hub.resourceGroupName
}

resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: spoke.resourceGroupName
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  scope: hubResourceGroup
  name: hub.vnetName
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  scope: spokeResourceGroup
  name: spoke.vnetName
}

module hubToSpoke './modules/network/vnet-peering.bicep' = {
  scope: hubResourceGroup
  params: {
    localVnetName: hub.vnetName
    peeringName: hub.peeringName
    remoteVnetId: spokeVnet.id
    allowGatewayTransit: true
    allowForwardedTraffic: true
  }
}

module spokeToHub './modules/network/vnet-peering.bicep' = {
  scope: spokeResourceGroup
  params: {
    localVnetName: spoke.vnetName
    peeringName: spoke.peeringName
    remoteVnetId: hubVnet.id
    allowForwardedTraffic: true
    useRemoteGateways: true
  }
}

output hubPeeringId string = hubToSpoke.outputs.peeringId
output spokePeeringId string = spokeToHub.outputs.peeringId
