param peeringName string
param remoteVnetId string

resource hubToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
  name: peeringName
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
  }
}

// resource spokeToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = {
//   name: '${spokeName}/spoke-to-hub'
//   properties: {
//     allowVirtualNetworkAccess: true
//     allowForwardedTraffic: true
//     allowGatewayTransit: false
//     useRemoteGateways: false
//     remoteVirtualNetwork: {
//       id: hubVnetId
//     }
//   }
// }
