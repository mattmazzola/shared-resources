param uniqueRgString string
// global	3-24 Alphanumerics.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage
@minLength(3)
@maxLength(24)
param name string = '${resourceGroup().name}${uniqueRgString}storage'
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  kind: 'StorageV2'
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
}

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2022-05-01' = {
  parent: storageAccount
  name: 'default'
}

param queueName string = 'node-processor-queue'

resource nodeProcessorQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2022-05-01' = {
  parent: queueService
  name: queueName
}
