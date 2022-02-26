param location string
param suffix string

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: 'log-${suffix}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 7
  }
}
