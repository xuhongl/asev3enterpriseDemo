param principalId string
param roleGuid string
param vaultName string

resource existingVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing =  {
  name: vaultName
}

resource role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, principalId)
  scope: existingVault
  properties: {
    principalId: principalId
    roleDefinitionId: roleGuid
    principalType: 'ServicePrincipal'
  }
}
