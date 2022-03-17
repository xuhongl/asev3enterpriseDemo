param location string
param suffix string

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: 'vault-${suffix}'
  location: location
  properties: {
    accessPolicies: [
    ]
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        
      ]
      virtualNetworkRules: [
        
      ]
    }  
    enableRbacAuthorization: true
    enableSoftDelete: false
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
  }
}

output vaultName string = vault.name
output vaultId string = vault.id
