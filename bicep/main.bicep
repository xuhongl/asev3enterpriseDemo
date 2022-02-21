targetScope='subscription'

@description('The location where the resources will be deployed')
param location string

@description('If the ASE is external or not')
param externalAse bool

@description('The VNET configuration (hub and spoke)')
param vnetConfiguration object = {
  hub: {
    name: 'vnet-hub'
    addressPrefixe: '10.0.0.0/16'
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }          
      }
      {
        name: 'snet-jumpbox'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }          
      }         
    ]
  }
  spoke: {
    name: 'vnet-spoke'
    addressPrefixe: '10.1.0.0/16'
    subnets: [
      {
        name: 'snet-ase'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }        
      }
    ]    
  }
}

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
