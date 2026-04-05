targetScope = 'resourceGroup'

param location string
param network object

module vnet './modules/network/vnet.bicep' = {
  params: {
    location: location
    vnet: network.vnet
  }
}

module vpn './modules/network/vpn.bicep' = {
  params: {
    location: location
    vpn: network.vpn
    gatewaySubnetId: vnet.outputs.gatewaySubnetId
  }
}

output vnetId string = vnet.outputs.vnetId
output gatewaySubnetId string = vnet.outputs.gatewaySubnetId
output vpnGatewayId string = vpn.outputs.vngId
output vpnGatewayPublicIp string = vpn.outputs.vngPip
