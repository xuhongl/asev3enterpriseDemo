param location string
param suffix string
param subnetId string

resource pip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pipfw${suffix}'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

resource firewallPolicies 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: 'fwpolicy${suffix}'
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: 'fw${suffix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: ''
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    sku: {
      tier: 'Standard'
    }
    firewallPolicy: {
      id: firewallPolicies.id
    }
  }
}
