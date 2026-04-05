using '../main.bicep'

param location = 'westeurope'

param hub = {
  resourceGroupName: 'RG-VPN'
  vnetName: 'VNET-VPN'
  peeringName: 'peer-vnet-vpn-to-vnet-gitlab'
}

param spoke = {
  resourceGroupName: 'RG-GitLab'
  vnetName: 'VNET-GitLab'
  peeringName: 'peer-vnet-gitlab-to-vnet-vpn'
}
