param location string
param suffix string

resource cache 'Microsoft.Cache/redis@2021-06-01' = {
  name: 'cache-${suffix}'
  location: location
  properties: {
    sku: {
      capacity: 0
      family: 'C'
      name: 'Basic'
    }
  }
}

output cacheName string = cache.name
