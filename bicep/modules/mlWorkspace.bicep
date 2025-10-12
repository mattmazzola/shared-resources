param name string = '${resourceGroup().name}-ml-workspace'
param location string = resourceGroup().location
param storageAccountResourceId string
param keyVaultResourceId string
param appInsightsResourceId string
param containerRegistryResourceId string

param uniqueRgString string
param computeName string = '${resourceGroup().name}-${uniqueRgString}-ml-vm'
param clusterName string = '${resourceGroup().name}-${uniqueRgString}-ml-clust'

// workspaces	resource group	3-33	Alphanumerics and hyphens.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftmachinelearningservices
resource mlWorkspaceResource 'Microsoft.MachineLearningServices/workspaces@2025-09-01' = {
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
    applicationInsights: appInsightsResourceId
    containerRegistry: containerRegistryResourceId
    discoveryUrl: 'https://${location}.api.azureml.ms/discovery'
    friendlyName: name
    keyVault: keyVaultResourceId
    storageAccount: storageAccountResourceId
    publicNetworkAccess: 'Enabled'
  }
}

// https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces/computes?pivots=deployment-language-bicep#compute-objects
resource cluster 'Microsoft.MachineLearningServices/workspaces/computes@2022-12-01-preview' = {
  parent: mlWorkspaceResource
  location: location
  name: clusterName
  properties: {
    computeLocation: location
    disableLocalAuth: false
    computeType: 'AmlCompute'
    properties: {
      scaleSettings: {
        maxNodeCount: 1
        minNodeCount: 0
        nodeIdleTimeBeforeScaleDown: 'PT2M'
      }
      vmSize: 'STANDARD_DS11_V2'
      remoteLoginPortPublicAccess: 'Disabled'
    }
  }
}

resource notebookCompute 'Microsoft.MachineLearningServices/workspaces/computes@2022-12-01-preview' = {
  parent: mlWorkspaceResource
  location: location
  name: computeName
  properties: {
    computeLocation: location
    disableLocalAuth: true
    computeType: 'ComputeInstance'
    properties: {
      vmSize: 'STANDARD_DS12_V2'
    }
  }
}
