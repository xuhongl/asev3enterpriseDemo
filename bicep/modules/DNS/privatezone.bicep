param aseName string
param vnetId string
param vnetNameSpoke string
// param asePrivateIp string

resource privateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: '${aseName}.appserviceenvironment.net'
  location: 'global'  
}

resource networkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateZone.name}/${vnetNameSpoke}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

// resource aRecordAseAll 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   name: '${privateZone}/*'
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: asePrivateIp
//       }
//     ]
//   }
// }

// resource aRecordAseSCM 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   name: '${privateZone}/*.scm'
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: asePrivateIp
//       }
//     ]
//   }
// }

// resource aRecordAse 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   name: '${privateZone}/@'
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: asePrivateIp
//       }
//     ]
//   }
// }
