targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment (e.g., dev, staging, prod)')
param environmentName string

param location string = 'westus3'

@secure()
param sqlServerAdminPassword string

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Tags for shared resources - use prefixed env name to avoid conflicts with other projects
var tags = {
  'azd-env-name': 'shared-${environmentName}' // e.g., "shared-dev", "shared-prod"
  project: 'shared-resources'
}

param tenantId string
param resourceGroupName string
var mlServicePrincipalObjectId = '0b28d83d-83ac-4bd9-9a24-5003cf8e4796'

resource sharedRg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

var uniqueRgString = take(uniqueString(sharedRg.id), 6)

module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVaultModule'
  scope: sharedRg
  params: {
    uniqueRgString: uniqueRgString
    location: location
    tenantId: tenantId
    tags: tags
  }
}

module cosmosDatabase 'modules/cosmosDatabase.bicep' = {
  name: 'databaseModule'
  scope: sharedRg
  params: {
    uniqueRgString: uniqueRgString
    keyVaultName: keyVault.outputs.name
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'containerRegistryModule'
  scope: sharedRg
  params: {
    uniqueRgString: uniqueRgString
  }
}

module logAnalytics 'modules/logAnalyticsWorkspace.bicep' = {
  name: 'logAnalyticsModule'
  scope: sharedRg
}

module appInsights 'modules/appInsights.bicep' = {
  name: 'appIngsightsModule'
  scope: sharedRg
  params: {
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}

module containerAppsEnv 'modules/containerAppsEnvironment.bicep' = {
  name: 'containerAppsEnvModule'
  scope: sharedRg
  params: {
    appInsightsResourceId: appInsights.outputs.resourceId
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}

module sqlServer 'modules/sqlServer.bicep' = {
  name: 'sqlDatabaseModule'
  scope: sharedRg
  params: {
    uniqueRgString: uniqueRgString
    tenantId: tenantId
    administratorPassword: sqlServerAdminPassword
  }
}

module serviceBus 'modules/serviceBus.bicep' = {
  name: 'serviceBusModule'
  scope: sharedRg
  params: {
    uniqueRgString: uniqueRgString
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccountModule'
  scope: sharedRg
  params: {
    uniqueRgString: uniqueRgString
  }
}

module mlWorkspace 'modules/mlWorkspace.bicep' = {
  name: 'mlWorkspaceModule'
  scope: sharedRg
  params: {
    uniqueRgString: uniqueRgString
    storageAccountResourceId: storageAccount.outputs.resourceId
    keyVaultResourceId: keyVault.outputs.resourceId
    appInsightsResourceId: appInsights.outputs.resourceId
    containerRegistryResourceId: containerRegistry.outputs.resourceId
    // Optional: Uncomment to create compute resources during deployment
    // createTrainingCluster: true
    // createNotebookCompute: true
  }
}

// Outputs required by azd
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = sharedRg.name
