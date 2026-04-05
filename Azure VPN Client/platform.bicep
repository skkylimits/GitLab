targetScope = 'subscription'

param location string
param rg object
param network object

resource ResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rg.name
  location: location
  tags: rg.tags
}

// 🚀 Deploy jouw bestaande main.bicep
module AzureVpnClient './main.bicep' = {
  scope: ResourceGroup
  params: {
    location: location
    network: network
  }
}

output resourceGroupName string = ResourceGroup.name
output vnetId string = AzureVpnClient.outputs.vnetId
output gatewaySubnetId string = AzureVpnClient.outputs.gatewaySubnetId
output vpnGatewayId string = AzureVpnClient.outputs.vpnGatewayId
output vpnGatewayPublicIp string = AzureVpnClient.outputs.vpnGatewayPublicIp
