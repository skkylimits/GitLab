param location string
param vpn object
param gatewaySubnetId string

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: vpn.publicIp.name
  location: location
  sku: {
    name: vpn.publicIp.sku.name
  }
  properties: {
    publicIPAllocationMethod: vpn.publicIp.publicIPAllocationMethod
  }
}

resource VirtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: vpn.gateway.name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: vpn.gateway.ipConfigurations[0].name
        properties: {
          privateIPAllocationMethod: vpn.gateway.ipConfigurations[0].properties.privateIPAllocationMethod
          subnet: {
            id: gatewaySubnetId
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    gatewayType: vpn.gateway.gatewayType
    vpnType: vpn.gateway.vpnType
    enableBgp: vpn.gateway.enableBgp
    activeActive: vpn.gateway.activeActive
    sku: {
      name: vpn.gateway.sku.name
      tier: vpn.gateway.sku.tier
    }
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          for addressPrefix in vpn.gateway.vpnClientConfiguration.vpnClientAddressPool.addressPrefixes: addressPrefix
        ]
      }
      vpnClientProtocols: vpn.gateway.vpnClientConfiguration.vpnClientProtocols
      radiusServers: vpn.gateway.vpnClientConfiguration.radiusServers
      vpnClientRevokedCertificates: vpn.gateway.vpnClientConfiguration.vpnClientRevokedCertificates
      vpnClientRootCertificates: vpn.gateway.vpnClientConfiguration.vpnClientRootCertificates
    }
  }
}

output vngId string = VirtualNetworkGateway.id
output vngPIP string = publicIP.properties.ipAddress
