@description('Azure region')
param LOCATION string

@description('Subnet ID for the VM')
param SUBNET_ID string

@description('Local admin username (required by Azure)')
param ADMIN_USERNAME string

@description('SSH public key (required by Azure, not for daily use)')
@secure()
param SSH_PUBLIC_KEY string

@description('Virtual machine size')
param VM_SIZE string = 'Standard_D2s_v5'

//
// Resource names
//
var VM_NAME = 'VM-ANGARD-DEV-UBUNTU01'
var NIC_NAME = 'NIC-ANGARD-DEV-UBUNTU01'
var PIP_NAME = 'PIP-ANGARD-DEV-UBUNTU01'

//
// Public IP
//
resource pip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: PIP_NAME
  location: LOCATION
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//
// Network Interface
//
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: NIC_NAME
  location: LOCATION
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-01'
        properties: {
          subnet: {
            id: SUBNET_ID
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

//
// Virtual Machine
//
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: VM_NAME
  location: LOCATION

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    hardwareProfile: {
      vmSize: VM_SIZE
    }

    osProfile: {
      computerName: VM_NAME
      adminUsername: ADMIN_USERNAME

      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${ADMIN_USERNAME}/.ssh/authorized_keys'
              keyData: SSH_PUBLIC_KEY
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
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

//
// Entra ID (AAD) SSH Login Extension
//
resource aadSsh 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: 'AADSSHLoginForLinux'
  parent: vm
  location: LOCATION
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADSSHLoginForLinux'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

//
// Outputs
//
output VM_NAME_OUT string = vm.name
output VM_PUBLIC_IP string = pip.properties.ipAddress
