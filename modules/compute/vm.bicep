param location string
param vm object
param identity object
param nicId string

resource dataDisk 'Microsoft.Compute/disks@2021-12-01' = {
  name: vm.disks.data[0].name
  location: location
  sku: {
    name: vm.disks.data[0].sku
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB:  vm.disks.data[0].sizeGB
  }
}

resource VirtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vm.name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vm.size
    }
    osProfile: {
      computerName: vm.name
      adminUsername: identity.adminUsername
      adminPassword: identity.adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: vm.disks.os.sizeGB
      }
      dataDisks: [
        {
          lun: 0
          createOption: 'Attach'
          managedDisk: {
            id: dataDisk.id
          }
          diskSizeGB: vm.disks.data[0].sizeGB
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicId
        }
      ]
    }
  }
}

output vmId string = VirtualMachine.id
output dataDiskId string = dataDisk.id
