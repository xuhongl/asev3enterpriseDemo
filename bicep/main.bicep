targetScope='subscription'

@description('The location where the resources will be deployed')
param location string

@description('The VNET configuration (hub and spoke)')
param vnetConfiguration object

@secure()
param adminUsername string

@secure()
param adminPassword string

@description('The version of the Ubuntu OS')
param ubuntuVersion string

@description('The size of the VM')
param vmSize string

var hubRgName = 'rg-hub-ase-demo'
var spokeRgName = 'rg-spoke-ase-demo'

var hubsuffix = uniqueString(hubRg.id)
var spokeSuffix = uniqueString(spokeRg.id)

// Vault contributor role, can change this in your template to lower priviledge role
var vaultContributorRole = '/providers/Microsoft.Authorization/roleDefinitions/f25e0fa2-a7c8-4377-a976-54943a77a395'

resource hubRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: hubRgName
  location: location
}

resource spokeRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: spokeRgName
  location: location
}

module vnetHub 'modules/networking/vnet.hub.bicep' = {
  scope: resourceGroup(hubRg.name)
  name: 'vnetHub'
  params: {
    location: location
    vnetConfiguration: vnetConfiguration.hub
  }
}

module runner 'modules/compute/runner.bicep' = {
  scope: resourceGroup(hubRg.name)
  name: 'runner'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    location: location
    subnetId: vnetHub.outputs.subnets[2].id
    ubuntuVersion: ubuntuVersion
    vmSize: vmSize
  }
}

module vnetSpoke 'modules/networking/vnet.spoke.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'vnetSpoke'
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

module dnsZone 'modules/DNS/privatezone.ase.bicep'= {
  scope: resourceGroup(spokeRg.name)
  name: 'dnsZone'
  params: {
    aseName: ase.outputs.aseName
    hubVnetId: vnetHub.outputs.vnetId
    vnetNameSpoke: vnetSpoke.outputs.vnetName
    asePrivateIp: ase.outputs.asePrivateIp
    privateIpRunner: runner.outputs.privateIps
    runnerVmName: runner.outputs.vmName
    spokeVnetId: vnetSpoke.outputs.vnetId
    vnetNameHub: vnetHub.outputs.vnetName
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

module vault 'modules/vault/keyvault.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'vault'
  params: {
    location: location
    suffix: spokeSuffix
  }
}

module userAssignedIdentity 'modules/identity/appgw.identity.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'userAssignedIdentity'
  params: {
    location: location
    suffix: spokeSuffix
  }
}

module keyVaultContributorRole 'modules/identity/vault.contributor.role.bicep' = {
  scope: resourceGroup(spokeRg.name)
  name: 'keyVaultContributorRole'
  params: {
    principalId: userAssignedIdentity.outputs.principalId
    roleGuid: vaultContributorRole    
    vaultName: vault.outputs.vaultName
  }
}

output webAppname string = web.outputs.webappname
