// workspaces	resource group	4-63	Alphanumerics and hyphens.
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftoperationalinsights
@minLength(4)
@maxLength(63)
param name string = '${resourceGroup().name}-loganalytics'
param location string = resourceGroup().location

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
}

output resourceId string = logAnalyticsWorkspace.id
