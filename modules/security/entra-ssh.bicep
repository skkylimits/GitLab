// extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:0.1.9-preview'


// param vmName string
// param entra object

// var adminGroup = entra.ssh.adminGroup

// resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' existing = {
//   name: vmName
// }

// resource SecurityGroup 'Microsoft.Graph/groups@v1.0' = {
//   displayName: adminGroup.displayName
//   uniqueName: adminGroup.uniqueName
//   mailEnabled: false
//   mailNickname: adminGroup.mailNickname
//   securityEnabled: true
//   members: adminGroup.members
// }

// resource sshAdminLoginAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(vmName, adminGroup.uniqueName, adminGroup.roleDefinitionId)
//   scope: virtualMachine
//   properties: {
//     principalId: SecurityGroup.id
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', adminGroup.roleDefinitionId)
//     principalType: 'Group'
//   }
// }

// output groupId string = SecurityGroup.id
// output groupDisplayName string = SecurityGroup.displayName
