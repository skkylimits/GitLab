param location string
param vm object
param identity object
param nicId string
param dataDiskName string

var cloudInit = loadTextContent('../../iac/cloud-init.yaml')

resource dataDisk 'Microsoft.Compute/disks@2023-04-02' existing = {
  name: dataDiskName
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
      customData: base64(cloudInit)

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
        deleteOption: 'Detach'
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
