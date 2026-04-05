targetScope = 'resourceGroup'

// 🌍 Object-oriented params
param location string
param network object
param compute object
param identity object
param entra object



// 🏗 MODULES

// VNET module
module vnet './modules/network/vnet.bicep' = {
  name: network.vnet.module
  params: {
    location: location
    vnet: network.vnet
  }
}

// NSG module
module nsg './modules/network/nsg.bicep' = {
  name: network.nsg.module
  params: {
    location: location
    nsg: network.nsg
  }
}

// NIC module
module nic './modules/network/nic.bicep' = {
  name: network.nic.module
  params: {
    location: location
    nic: network.nic
    subnetId: vnet.outputs.subnetId
    nsgId: nsg.outputs.nsgId
  }
}

// VM module
module vm './modules/compute/vm.bicep' = {
  name: compute.vm.module
  params: {
    location: location
    vm: compute.vm
    identity: identity
    nicId: nic.outputs.nicId
  }
}

// module ssh './modules/security/entra-ssh.bicep' = {
//   name: entra.ssh.module
//   params: {
//     vmName: compute.vm.name
//     entra: entra
//   }
// }

// 🌐 OUTPUTS
output vmId string = vm.outputs.vmId
output nicId string = nic.outputs.nicId
