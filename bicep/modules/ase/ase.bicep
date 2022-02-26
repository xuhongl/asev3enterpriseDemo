param location string
param suffix string
param subnetId string

resource ase 'Microsoft.Web/hostingEnvironments@2021-03-01' = {
  name: 'ase-${suffix}'
  location: location
  kind: 'ASEV3'
  properties: {
    virtualNetwork: {
      id: subnetId
    } 
    internalLoadBalancingMode: 'None'
    dedicatedHostCount: 0
    zoneRedundant: false   
  }
}

output aseId string = ase.id
output asePublicIp string = ase.properties.networkingConfiguration.externalInboundIpAddresses[0]
