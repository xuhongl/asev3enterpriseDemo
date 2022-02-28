param location string
param suffix string
param subnetId string
param externalAse bool

var internalLoadBalancingMode = externalAse ? 'None' : 'Web, Publishing'

resource ase 'Microsoft.Web/hostingEnvironments@2021-03-01' = {
  name: 'ase-${suffix}'
  location: location
  kind: 'ASEV3'
  properties: {
    virtualNetwork: {
      id: subnetId
    } 
    internalLoadBalancingMode: internalLoadBalancingMode
    dedicatedHostCount: 0
    zoneRedundant: false   
  }
}

output aseId string = ase.id
output aseName string = ase.name
output asePrivateIp string = externalAse ? '' : reference('${ase.id}/configurations/networking', '2019-08-01').internalInboundIpAddresses[0]
