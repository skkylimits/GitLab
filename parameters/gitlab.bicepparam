using '../bootstrap.bicep'

param location = 'westeurope'

param rg = {
  name: 'RG-GitLab'
  tags: {
    environment: 'gitlab'
  }
}

param network = {
  vnet: {
    name: 'VNET-GitLab'
    addressPrefix: '10.0.0.0/16'
  }
  subnet: {
    name: 'SUBNET-GitLab'
    prefix: '10.0.0.0/24'
  }
  nsg: {
    name: 'NSG-GitLab'
  }
  nic: {
    name: 'NIC-GitLab'
  }
}

param compute = {
  vm: {
    name: 'VM-GitLab'
    size: 'Standard_B2s'
  }
}

param identity = {
  adminUsername: 'aazsp3'
}

param secrets = {
  adminPassword: 'Pa$$w0rd123!'
}
