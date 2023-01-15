param uniqueRgString string
// global	1-63	Lowercase letters, numbers, and hyphens.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftsql
@minLength(1)
@maxLength(63)
param serverName string = '${resourceGroup().name}-${uniqueRgString}-sql-server'
param dbName string = '${resourceGroup().name}-${uniqueRgString}-sql-db'
param location string = resourceGroup().location

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  location: location
  name: serverName
  properties: {
    administratorLogin: 'shared-klgoyi-admin'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: false
      login: 'mattmazzola@mattmazzolaLIVE.onmicrosoft.com'
      principalType: 'User'
      sid: '38ca5671-b272-4b59-bfe2-7da375143441'
      tenantId: '61f2e65a-a249-4aaa-82bb-248830f89177'
    }
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  location: location
  name: dbName
  properties: {
    autoPauseDelay: 60
    minCapacity: any('0.5')
  }
  sku: {
    family: 'Gen5'
    name: 'GP_S_Gen5'
  }
}
