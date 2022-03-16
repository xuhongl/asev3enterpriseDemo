targetScope='subscription'

@description('The location where the resources will be deployed')
param location string

@description('The VNET configuration (hub and spoke)')
param vnetConfiguration object

var hubRgName = 'rg-hub-ase-demo'
var spokeRgName = 'rg-spoke-ase-demo'

var hubsuffix = uniqueString(hubRg.id)
var spokeSuffix = uniqueString(spokeRg.id)

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

module vnetSpoke 'modules/networking/vnet.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'vnetHub'
  params: {
    location: location
    vnetConfiguration: vnetConfiguration.spoke
  }
}

module peeringhub 'modules/networking/peering.bicep' = {
  scope: resourceGroup(hubRg.name)
  name: 'peeringhub'
  params: {
    peeringName: '${vnetHub.outputs.vnetName}/hub-to-spoke'
    remoteVnetId: vnetSpoke.outputs.vnetId
  }
}

module peeringspoke 'modules/networking/peering.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'peeringspoke'
  params: {
    peeringName: '${vnetSpoke.outputs.vnetName}/spoke-to-hub'
    remoteVnetId: vnetHub.outputs.vnetId
  }
}

module firewall 'modules/firewall/firewall.bicep' = {
  scope: resourceGroup(hubRg.name)  
  name: 'firewall'
  params: {
    location: location
    subnetId: vnetHub.outputs.subnets[0].id
    suffix: hubsuffix
  }
}

module ase 'modules/ase/ase.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'ase'
  params: {
    location: location
    subnetId: vnetSpoke.outputs.subnets[0].id
    suffix: spokeSuffix
  }
}

module dnsZone 'modules/DNS/privatezone.bicep'= {
  scope: resourceGroup(spokeRg.name)
  name: 'dnsZone'
  params: {
    aseName: ase.outputs.aseName
    vnetId: vnetSpoke.outputs.vnetId
    vnetNameSpoke: vnetSpoke.outputs.vnetName
    asePrivateIp: ase.outputs.asePrivateIp
  }
}

module routeTable 'modules/networking/routeTable.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'routeTable'
  params: {
    fwPrivateIP: firewall.outputs.privateIp
    fwPublicIP: firewall.outputs.publicIp
    location: location
  }
}

module appServicePlan 'modules/webapp/appservice.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'appServicePlan'
  params: {
    aseId: ase.outputs.aseId    
    location: location
    suffix: spokeSuffix
  }
}

module web 'modules/webapp/webapp.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'web'
  params: {
    appServiceId: appServicePlan.outputs.appserviceId
    aseId: ase.outputs.aseId
    location: location
    suffix: spokeSuffix
  }
}

module workspace 'modules/analytics/workspace.bicep' = {
  scope: resourceGroup(hubRg.name)
  name: 'workspace'
  params: {
    location: location
    suffix: hubsuffix
  }
}

output webAppname string = web.outputs.webappname
