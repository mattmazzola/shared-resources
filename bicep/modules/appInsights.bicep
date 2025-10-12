param name string = '${resourceGroup().name}-appinsights'
param location string = resourceGroup().location
param logAnalyticsWorkspaceResourceId string

// components	resource group	1-260
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftinsights
resource appInsightsResource 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaMachineLearningExtension'
    RetentionInDays: 90
    WorkspaceResourceId: logAnalyticsWorkspaceResourceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output resourceId string = appInsightsResource.id
