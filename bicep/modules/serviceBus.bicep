param uniqueRgString string
// global	6-50	Alphanumerics.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftservicebus
@minLength(6)
@maxLength(50)
param name string = '${resourceGroup().name}-${uniqueRgString}-servicebus'
param location string = resourceGroup().location

resource containerRegistry 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
}
