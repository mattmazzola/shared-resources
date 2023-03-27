param name string = '${resourceGroup().name}-redis'
param location string = resourceGroup().location

resource Redis_shared_klgoyi_redis_name_resource 'Microsoft.Cache/Redis@2022-06-01' = {
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
