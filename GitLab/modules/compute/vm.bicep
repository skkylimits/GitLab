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
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vm.size
    }
    osProfile: {
      computerName: vm.name
      adminUsername: identity.adminUsername

      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${identity.adminUsername}/.ssh/authorized_keys'
              keyData: identity.sshPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
      name: vm.disks.os.name
      createOption: 'FromImage'
      diskSizeGB: vm.disks.os.sizeGB
      managedDisk: {
        storageAccountType: 'StandardSSD_LRS'
      }
      deleteOption: 'Delete' // zo wordt OS-disk ook verwijderd bij stack delete
    }
    dataDisks: [
  {
    lun: 0
        createOption: 'Attach'
        managedDisk: {
          id: dataDisk.id
        }
        caching: 'ReadWrite'
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

resource AADSSHLoginForLinux 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: 'AADSSHLoginForLinux'
  parent: VirtualMachine
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADSSHLoginForLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

output vmId string = VirtualMachine.id
output dataDiskId string = dataDisk.id
