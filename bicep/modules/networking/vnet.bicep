param vnetConfiguration object
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetConfiguration.vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetConfiguration.addressPrefixe
      ]
    }
    subnets: vnetConfiguration.subnets
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
