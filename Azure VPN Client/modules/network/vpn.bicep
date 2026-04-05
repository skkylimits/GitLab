param location string
param vpn object
param gatewaySubnetId string

var aad = vpn.gateway.vpnClientConfiguration.?aad
var vpnClientConfiguration = union(
  {
    vpnClientAddressPool: {
      addressPrefixes: vpn.gateway.vpnClientConfiguration.vpnClientAddressPool.addressPrefixes
    }
    vpnClientProtocols: vpn.gateway.vpnClientConfiguration.?vpnClientProtocols ?? []
    vpnAuthenticationTypes: vpn.gateway.vpnClientConfiguration.?vpnAuthenticationTypes ?? []
    radiusServers: vpn.gateway.vpnClientConfiguration.?radiusServers ?? []
    vpnClientRevokedCertificates: vpn.gateway.vpnClientConfiguration.?vpnClientRevokedCertificates ?? []
    vpnClientRootCertificates: vpn.gateway.vpnClientConfiguration.?vpnClientRootCertificates ?? []
  },
  empty(aad ?? {}) ? {} : {
    aadTenant: aad.tenant
    aadAudience: aad.audience
    aadIssuer: aad.issuer
  }
)

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: vpn.publicIp.name
  location: location
  sku: {
    name: vpn.publicIp.sku.name
  }
  zones: vpn.publicIp.?zones
  properties: {
    publicIPAllocationMethod: vpn.publicIp.publicIPAllocationMethod
  }
}

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = {
  name: vpn.gateway.name
  location: location
  properties: {
    ipConfigurations: [
      for ipConfiguration in vpn.gateway.ipConfigurations: {
        name: ipConfiguration.name
        properties: {
          privateIPAllocationMethod: ipConfiguration.properties.privateIPAllocationMethod
          subnet: {
            id: gatewaySubnetId
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    gatewayType: vpn.gateway.gatewayType
    vpnType: vpn.gateway.vpnType
    enableBgp: vpn.gateway.enableBgp
    activeActive: vpn.gateway.activeActive
    vpnGatewayGeneration: vpn.gateway.?generation ?? 'Generation1'
    sku: {
      name: vpn.gateway.sku.name
      tier: vpn.gateway.sku.tier
    }
    vpnClientConfiguration: vpnClientConfiguration
  }
}

output vngId string = virtualNetworkGateway.id
output vngPip string = publicIp.properties.ipAddress
