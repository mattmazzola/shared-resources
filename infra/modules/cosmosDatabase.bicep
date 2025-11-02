param uniqueRgString string
// global	3-44	Lowercase letters, numbers, and hyphens.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftdocumentdb
@minLength(3)
@maxLength(44)
param name string = '${resourceGroup().name}-${uniqueRgString}-cosmos'
param location string = 'West US'
param keyVaultName string

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2025-05-01-preview' = {
  name: name
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}

var databaseKeySecretName = '${resourceGroup().name}-db-key'

resource databaseKey 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  name: '${keyVaultName}/${databaseKeySecretName}'
  properties: {
    value: databaseAccount.listKeys().primaryMasterKey
  }
}
