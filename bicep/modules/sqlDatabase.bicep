param uniqueRgString string
// global	1-63	Lowercase letters, numbers, and hyphens.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftsql
@minLength(1)
@maxLength(63)
param name string = '${resourceGroup().name}-${uniqueRgString}-sql'
param location string = resourceGroup().location

resource sqlDatabase 'Microsoft.Sql/managedInstances@2022-05-01-preview' = {
  name: name
  location: location
}
