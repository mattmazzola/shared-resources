param name string = '${resourceGroup().name}-appinsights'
param location string = resourceGroup().location
param logAnalyticsWorkspaceResourceId string

resource appInsightsResource 'microsoft.insights/components@2020-02-02' = {
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
