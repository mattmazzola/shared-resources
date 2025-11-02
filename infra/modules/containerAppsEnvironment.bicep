// resource group	2-32	Lowercase letters, numbers, and hyphens..
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftapp
@minLength(2)
@maxLength(32)
param name string = '${resourceGroup().name}-containerappsenv'
param location string = resourceGroup().location
param logAnalyticsWorkspaceResourceId string
param appInsightsResourceId string

resource containerAppEnv 'Microsoft.App/managedEnvironments@2025-02-02-preview' = {
  name: name
  location: location
  properties: {
    daprAIInstrumentationKey: reference(appInsightsResourceId, '2020-02-02').InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspaceResourceId, '2025-02-01').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceResourceId, '2025-02-01').primarySharedKey
      }
    }
  }
}

output resourceId string = containerAppEnv.id
