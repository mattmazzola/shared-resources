param uniqueRgString string

@secure()
param administratorPassword string

// global	1-63	Lowercase letters, numbers, and hyphens.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftsql
@minLength(1)
@maxLength(63)
param serverName string = '${resourceGroup().name}-${uniqueRgString}-sql-server'
param location string = resourceGroup().location

param tenantId string

resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' = {
  location: location
  name: serverName
  properties: {
    administratorLogin: 'shared-${uniqueRgString}-admin'
    administratorLoginPassword: administratorPassword
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: false
      login: 'mattmazzola@mattmazzolaLIVE.onmicrosoft.com'
      principalType: 'User'
      sid: '38ca5671-b272-4b59-bfe2-7da375143441'
      tenantId: tenantId
    }
    publicNetworkAccess: 'Enabled'
  }
}
