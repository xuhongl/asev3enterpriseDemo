param location string
param suffix string
param aseId string

var appPlanname = 'asp-${suffix}'

resource appservice 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appPlanname
  location: location
  kind: 'linux'
  properties: {
    reserved: true
    zoneRedundant: false
    hostingEnvironmentProfile: {
      id: aseId
    }    
  }
  sku: {
    tier: 'IsolatedV2'
    name: 'I1V2'
  }
}
