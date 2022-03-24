param vnetConfiguration object
param location string
param routeTableId string

resource nsgAppGW 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-appgw'
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSL_WEB_443'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          priority: 100
        }
      }
      {
        name: 'GatewayManager_Port'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          priority: 101          
        }
      }
    ]
  }
}

resource nsgAse 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-ase'
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSL_WEB_443'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          priority: 100
        }        
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetConfiguration.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetConfiguration.addressPrefixe
      ]
    }
    subnets: [
      {
        name: vnetConfiguration.subnets[0].name
        properties: {
          addressPrefix: vnetConfiguration.subnets[0].properties.addressPrefix
          delegations: vnetConfiguration.subnets[0].properties.delegations
          privateEndpointNetworkPolicies: vnetConfiguration.subnets[0].properties.privateEndpointNetworkPolicies
          privateLinkServiceNetworkPolicies: vnetConfiguration.subnets[0].properties.privateLinkServiceNetworkPolicies
          networkSecurityGroup: {
            id: nsgAse.id
          }
          routeTable: {
            id: routeTableId
          }
        }
      }
      {
        name: vnetConfiguration.subnets[1].name
        properties: {
          addressPrefix: vnetConfiguration.subnets[1].addressPrefix
          networkSecurityGroup: {
            id: nsgAppGW.id
          }
        }
      }
    ]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output subnets array = vnet.properties.subnets


