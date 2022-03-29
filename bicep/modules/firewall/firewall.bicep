param location string
param suffix string
param subnetId string

param subnetASECIDR string
param subnetSpokeDBCIDR string

resource pip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-fw-${suffix}'
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
  name: 'fw-policy-${suffix}'
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
  }
}

// resource defaultApplicationGroups 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-05-01' = {
//   name: '${firewallPolicies.name}/DefaultApplicationRuleCollectionGroup'
//   properties: {
//     priority: 300
//     ruleCollections: [
//       {
//         ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
//         action: {
//           type: 'Deny'
//         }
//         rules: [
          
//         ]
//         name: 'Deny'
//         priority: 100
//       }
//     ]
//   }
// }

resource ruleCollectionGroups 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-05-01' = {
  name: '${firewallPolicies.name}/DefaultNetworkRuleCollectionGroup'  
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        priority: 100
        rules: [
          {            
            ruleType: 'NetworkRule'
            name: 'toPrivateSpokeDB'            
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              subnetASECIDR
            ]
            sourceIpGroups: [
              
            ]
            destinationAddresses: [
              subnetSpokeDBCIDR
            ]
            destinationIpGroups: [
              
            ]
            destinationFqdns: [
              
            ]
            destinationPorts: [
              '*'
            ]
          }
        ]
      }
    ]
  }

}

resource firewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: 'fw-${suffix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
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

output privateIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output publicIp string = pip.properties.ipAddress
