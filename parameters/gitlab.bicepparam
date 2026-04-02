using '../bootstrap.bicep'

param location = 'westeurope'

param rg = {
  name: 'RG-GitLab'
  tags: {
    environment: 'GitLab'
  }
}

param compute = {
  vm: {
    name: 'gitlab-vm'
    size: 'Standard_DS2_v2'
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
  }
  subnet: {
    module: 'MOD-vnet' 
    name: 'SUBNET-GitLab'
    prefix: '10.0.0.0/24'
  }
  nsg: {
    module: 'MOD-vnet' 
    name: 'NSG-GitLab'
  }
  nic: {
    module: 'MOD-nic'
    name: 'NIC-GitLab'
  }
}
