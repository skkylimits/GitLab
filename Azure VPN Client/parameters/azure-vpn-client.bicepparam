using '../platform.bicep'

param location = 'westeurope'

param rg = {
  name: 'RG-VPN'
  tags: {
    environment: 'VPN'
    workload: 'vpn'
  }
}

param network = {
  vnet: {
    name: 'VNET-VPN'
    addressPrefix: '10.10.0.0/16'
    gatewaySubnet: {
      name: 'GatewaySubnet'
      prefix: '10.10.255.0/27'
    }
  }
  vpn: {
    publicIp: {
      name: 'PIP-VPN'
      sku: {
        name: 'Standard'
      }
      publicIPAllocationMethod: 'Static'
    }
    gateway: {
      name: 'VNG-VPN'
      generation: 'Generation1'
      ipConfigurations: [
        {
          name: 'default'
          properties: {
            privateIPAllocationMethod: 'Dynamic'
          }
        }
      ]
      gatewayType: 'Vpn'
      vpnType: 'RouteBased'
      enableBgp: false
      activeActive: false
      sku: {
        name: 'VpnGw1'
        tier: 'VpnGw1'
      }
      vpnClientConfiguration: {
        vpnClientAddressPool: {
          addressPrefixes: [
            '172.20.201.0/24'
          ]
        }
        vpnClientProtocols: [
          'OpenVPN'
        ]
        vpnAuthenticationTypes: [
          'AAD'
        ]
        aad: {
          tenant: 'https://login.microsoftonline.com/2f438d12-c249-4887-8808-48a81dd811e4/'
          audience: '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
          issuer: 'https://sts.windows.net/2f438d12-c249-4887-8808-48a81dd811e4/'
        }
        radiusServers: []
        vpnClientRevokedCertificates: []
        vpnClientRootCertificates: []
      }
    }
  }
}
