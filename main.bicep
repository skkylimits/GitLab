targetScope = 'resourceGroup'

// 🌍 Object-oriented params
param location string
param network object
param compute object
param identity object
@secure()
param secrets object


// 🏗 MODULES

// VNET module
module vnet './modules/network/vnet.bicep' = {
  name: 'vnetDeploy'
  params: {
    location: location
    name: network.vnet.name
    addressPrefix: network.vnet.addressPrefix
    subnetPrefix: network.subnet.prefix
  }
}

// NSG module
module nsg './modules/network/nsg.bicep' = {
  name: 'nsgDeploy'
  params: {
    location: location
    name: network.nsg.name
  }
}

// NIC module
module nic './modules/network/nic.bicep' = {
  name: 'nicDeploy'
  params: {
    location: location
    nicName: network.nic.name
    subnetId: vnet.outputs.subnetId
    nsgId: nsg.outputs.nsgId
  }
}

// VM module
module vm './modules/compute/vm.bicep' = {
  name: 'vmDeploy'
  params: {
    location: location
    vmName: compute.vm.name
    adminUsername: identity.adminUsername
    adminPassword: secrets.adminPassword
    nicId: nic.outputs.nicId
  }
}

// 🌐 OUTPUTS
output publicIp string = nic.outputs.publicIp
