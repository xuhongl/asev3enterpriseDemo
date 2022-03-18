param aseName string
param hubVnetId string
param spokeVnetId string
param vnetNameSpoke string
param vnetNameHub string
param asePrivateIp string
param privateIpRunner string
param runnerVmName string
param privateIpJumpbox string
param jumpboxName

resource privateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: '${aseName}.appserviceenvironment.net'
  location: 'global'  
}

resource networkLinkSpoke 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateZone.name}/${vnetNameSpoke}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: spokeVnetId
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

resource aRecordJumpbox 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${privateZone.name}/${jumpboxName}'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateIpJumpbox
      }
    ]
  }
}

resource aRecordAseAll 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${privateZone.name}/*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: asePrivateIp
      }
    ]
  }
}

resource aRecordAseSCM 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${privateZone.name}/*.scm'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: asePrivateIp
      }
    ]
  }
}

resource aRecordAse 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${privateZone.name}/@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: asePrivateIp
      }
    ]
  }
}
