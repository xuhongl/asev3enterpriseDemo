param cacheId string
param location string
param hubVnetId string
param spokeDbVnetId string
param vnetNameSpokeDB string
param vnetNameHub string
param privateIpRunner string
param runnerVmName string

resource privateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.redis.cache.windows.net'
  location: 'global'  
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'pe-cache'
  location: location
  properties: {
    subnet: {
      id: spokeDbVnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-cache'
        properties: {
          privateLinkServiceId: cacheId
          groupIds: [
            'redisCache'
          ]
        }
      }
    ]
  }
}

resource networkLinkSpokeDB 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateZone.name}/${vnetNameSpokeDB}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: spokeDbVnetId
    }
    registrationEnabled: false
  }
}

resource networkLinkHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateZone.name}/${vnetNameHub}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: hubVnetId
    }
    registrationEnabled: false
  }
}

resource networkLinkSpoke 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateZone.name}/${vnetNameSpokeDB}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: spokeDbVnetId
    }
    registrationEnabled: false
  }
}

resource aRecordRunner 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${privateZone.name}/${runnerVmName}'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateIpRunner
      }
    ]
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateZone.name
        properties: {
          privateDnsZoneId: privateZone.id
        }
      }         
    ]
  }
}
