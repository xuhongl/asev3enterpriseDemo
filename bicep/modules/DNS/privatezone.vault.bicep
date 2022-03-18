param location string
param hubVnetName string
param spokeVnetName string
param keyVaultId string
param hubVnetid string
param peSubnetId string
param spokeVnetid string

resource privateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'  
}

resource networkLinkHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateZone.name}/${hubVnetName}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: hubVnetid
    }
    registrationEnabled: true
  }
}

resource networkLinkSpoke 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateZone.name}/${spokeVnetName}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: spokeVnetid
    }
    registrationEnabled: false
  }
}

resource privateEndpointVault 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'pe-vault'
  location: location
  properties: {
    subnet: {
      id: peSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-vault'
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointVault.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-vaultcore-azure-net'
        properties: {
          privateDnsZoneId: privateZone.id
        }
      }
    ]
  }
}
