param name string = '${resourceGroup().name}-ml-workspace'
param location string = resourceGroup().location
param storageAccountResourceId string
param keyVaultResourceId string
param appInsightsResourceId string
param containerRegistryResourceId string

resource mlWorkspaceResource 'Microsoft.MachineLearningServices/workspaces@2022-12-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  kind: 'Default'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    storageAccount: storageAccountResourceId
    keyVault: keyVaultResourceId
    applicationInsights: appInsightsResourceId
    containerRegistry: containerRegistryResourceId
    publicNetworkAccess: 'Enabled'
    discoveryUrl: 'https://${location}.api.azureml.ms/discovery'
  }
}
