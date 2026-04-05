// targetScope = 'subscription'

// extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:0.1.9-preview'


// @description('De display name voor de groep.')
// param displayName string = 'TestAdminGroup'

// @description('Unieke naam / alternate key voor de groep.')
// param uniqueName string = 'test-admin-group'

// @description('Mail alias (niet nodig voor security group).')
// param mailNickname string = 'testadmingroup'

// @description('Role Definition ID voor role assignment.')
// param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' // voorbeeld: Contributor

// // Microsoft 365 Security Group aanmaken
// resource securityGroup 'Microsoft.Graph/groups@v1.0' = {
//   displayName: displayName
//   uniqueName: uniqueName
//   mailEnabled: false
//   mailNickname: mailNickname
//   securityEnabled: true
// }

// // Voorbeeld: role assignment op subscription level
// var roleAssignmentName = guid(uniqueName, roleDefinitionId, subscription().id)
// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: roleAssignmentName
//   scope: subscription()
//   properties: {
//     principalId: securityGroup.id
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
//     principalType: 'Group'
//   }
// }

// // Outputs
// output groupId string = securityGroup.id
// output groupDisplayName string = securityGroup.displayName
