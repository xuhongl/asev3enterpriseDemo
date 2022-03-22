param location string
param suffix string
param appServiceId string
param aseId string

resource web 'Microsoft.Web/sites@2021-03-01' = {
  name: 'weatherapi-${suffix}'
  location: location
  properties: {
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|6.0'
    }
    serverFarmId: appServiceId
    hostingEnvironmentProfile: {
      id: aseId
    }
  }
}

output webappname string = web.name
