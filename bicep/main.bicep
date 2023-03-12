param location string = 'westus3'

var uniqueRgString = take(uniqueString(resourceGroup().id), 6)

var keyVaultName = '${resourceGroup().name}-${uniqueRgString}-keyvault'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: '61f2e65a-a249-4aaa-82bb-248830f89177'
    accessPolicies: [
      {
        tenantId: '61f2e65a-a249-4aaa-82bb-248830f89177'
        // Matt Mazzola
        objectId: 'ff05dde2-c18e-47fc-9ad2-ebf0c9efb3a0'
        permissions: {
          keys: [
            'All'
          ]
          secrets: [
            'All'
          ]
          certificates: [
            'All'
          ]
        }
      }
      {
        tenantId: '61f2e65a-a249-4aaa-82bb-248830f89177'
        // shared-ml-workspace
        objectId: '0b28d83d-83ac-4bd9-9a24-5003cf8e4796'
        // applicationId: 'e61d1383-cd7b-4518-88c4-14257146ce66'
        permissions: {
          keys: [
            'All'
          ]
          secrets: [
            'All'
          ]
          certificates: [
            'All'
          ]
        }
      }
    ]
  }
}

module cosmosDatabase 'modules/cosmosDatabase.bicep' = {
  name: 'databaseModule'
  params: {
    uniqueRgString: uniqueRgString
    keyVaultName: keyVault.name
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'containerRegistry'
  params: {
    uniqueRgString: uniqueRgString
  }
}

module logAnalytics 'modules/logAnalyticsWorkspace.bicep' = {
  name: 'logAnalytics'
}

module appInsights 'modules/appInsights.bicep' = {
  name: 'appIngsights'
  params: {
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}

module containerAppsEnv 'modules/containerAppsEnvironment.bicep' = {
  name: 'containerAppsEnv'
  params: {
    appInsightsResourceId: appInsights.outputs.resourceId
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}

module sqlServer 'modules/sqlServer.bicep' = {
  name: 'sqlDatabaseModule'
  params: {
    uniqueRgString: uniqueRgString
  }
}

module serviceBus 'modules/serviceBus.bicep' = {
  name: 'serviceBusModule'
  params: {
    uniqueRgString: uniqueRgString
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccountModule'
  params: {
    uniqueRgString: uniqueRgString
  }
}

module mlWorkspace 'modules/mlWorkspace.bicep' = {
  name: 'mlWorkspaceModule'
  params: {
    storageAccountResourceId: storageAccount.outputs.resourceId
    keyVaultResourceId: keyVault.id
    appInsightsResourceId: appInsights.outputs.resourceId
    containerRegistryResourceId: containerRegistry.outputs.resourceId
  }
}
