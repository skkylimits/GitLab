using '../platform.bicep'

param location = 'westeurope'

param rg = {
  name: 'RG-GitLab'
  tags: {
    environment: 'GitLab'
  }
}

param compute = {
  vm: {
    module: 'MOD-vm'
    name: 'VM-GitLab'
    size: 'Standard_D2s_v5'
    disks: {
      os: {
        name: 'OSDISK-GitLab'
        sizeGB: 30
      }
      data: [
        {
          name: 'DATA-GitLab'
          sizeGB: 128
          sku: 'Premium_LRS'
        }
      ]
    }
  }
}

param identity = {
  adminUsername: 'ubuntu'
  adminPassword: 'Pa$$w0rd123!'
}

param network = {
  vnet: {
    module: 'MOD-vnet' 
    name: 'VNET-GitLab'
    addressPrefix: '10.0.0.0/16'
    subnet: {
      name: 'SUBNET-GitLab'
      prefix: '10.0.0.0/24'
    }
  }
  nsg: {
    module: 'MOD-nsg' 
    name: 'NSG-GitLab'
    securityRules: [
      {
        name: 'Allow-SSH-22'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-HTTP-80'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-HTTPS-443'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
  nic: {
    module: 'MOD-nic'
    name: 'NIC-GitLab'
  }
}
