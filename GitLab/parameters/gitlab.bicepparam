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
        name: 'OS-GitLab'
        sizeGB: 64
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
  sshPublicKey: 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdV4xTfs05XrPFK41vH4AVr2qInonVCrbxNnFcpnd+p entra-bootstrap'
}

param entra = {
  ssh: {
    module: 'MOD-entra-ssh'
    adminGroup: {
      displayName: '[Azure] - GitLab R00T'
      uniqueName: 'gitlab-r00t'
      mailNickname: 'gitlab-r00t'
      members: []
      roleDefinitionId: '1c0163c0-47e6-4577-8991-ea5c82e286e4'
    }
  }
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
  nic: {
    module: 'MOD-nic'
    name: 'NIC-GitLab'
    ipConfigurations: [
      {
        name: 'primary'
        privateIPAllocationMethod: 'Dynamic'
      }
    ]
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
}
