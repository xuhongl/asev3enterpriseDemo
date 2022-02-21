targetScope='subscription'

@description('The location where the resources will be deployed')
param location string

// @description('If the ASE is external or not')
// param externalAse bool

@description('The VNET configuration (hub and spoke)')
param vnetConfiguration object

var hubRgName = 'rg-hub-ase-demo'
var spokeRgName = 'rg-spoke-ase-demo'

resource hubRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: hubRgName
  location: location
}

resource spokeRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: spokeRgName
  location: location
}

module vnetHub 'modules/networking/vnet.bicep' = {
  scope: resourceGroup(hubRg.name)
  name: 'vnetHub'
  params: {
    location: location
    vnetConfiguration: vnetConfiguration.hub
  }
}
