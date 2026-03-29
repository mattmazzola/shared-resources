param uniqueRgString string
// global	3-24 Alphanumerics.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage
@minLength(3)
@maxLength(24)
param name string = '${resourceGroup().name}${uniqueRgString}storage'
param location string = resourceGroup().location
param corsAllowedOrigins array = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  kind: 'StorageV2'
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowBlobPublicAccess: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: empty(corsAllowedOrigins) ? [] : [
        {
          allowedOrigins: corsAllowedOrigins
          allowedMethods: ['GET', 'OPTIONS']
          allowedHeaders: ['*']
          exposedHeaders: ['*']
          maxAgeInSeconds: 3600
        }
      ]
    }
  }
}

output resourceId string = storageAccount.id
