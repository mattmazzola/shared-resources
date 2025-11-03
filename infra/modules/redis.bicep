param name string = '${resourceGroup().name}-redis'
param location string = resourceGroup().location

resource redisResource 'Microsoft.Cache/redis@2024-11-01' = {
  name: name
  location: location
  properties: {
    sku: {
      capacity: 0
      family: 'C'
      name: 'Basic'
    }
  }
}
