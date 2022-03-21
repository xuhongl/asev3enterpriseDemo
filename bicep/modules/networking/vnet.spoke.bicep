param vnetConfiguration object
param location string

resource nsgAppGW 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'nsg-appgw'
  location: location
  properties: {
    securityRules: [
      
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
        properties: vnetConfiguration.subnets[0].properties
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


