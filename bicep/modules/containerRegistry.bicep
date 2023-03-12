param uniqueRgString string
// global	5-50	Alphanumerics.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcontainerregistry
@minLength(5)
@maxLength(50)
param name string = '${resourceGroup().name}${uniqueRgString}acr'
param location string = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

output resourceId string = containerRegistry.id
