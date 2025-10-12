param location string = 'westus3'

@secure()
param sqlServerAdminPassword string

var uniqueRgString = take(uniqueString(subscription().id, resourceGroup().id), 6)

var keyVaultName = '${resourceGroup().name}-${uniqueRgString}-keyvault'

var tenantId = '61f2e65a-a249-4aaa-82bb-248830f89177'

var mlServicePrincipalObjectId = '0b28d83d-83ac-4bd9-9a24-5003cf8e4796'

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
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
      // {
      //   tenantId: tenantId
      //   // shared-ml-workspace
      //   objectId: mlServicePrincipalObjectId
      //   // applicationId: 'e61d1383-cd7b-4518-88c4-14257146ce66'
      //   permissions: {
      //     keys: [
      //       'All'
      //     ]
      //     secrets: [
      //       'All'
      //     ]
      //     certificates: [
      //       'All'
      //     ]
      //   }
      // }
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
    tenantId: tenantId
    administratorPassword: sqlServerAdminPassword
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
    uniqueRgString: uniqueRgString
    storageAccountResourceId: storageAccount.outputs.resourceId
    keyVaultResourceId: keyVault.id
    appInsightsResourceId: appInsights.outputs.resourceId
    containerRegistryResourceId: containerRegistry.outputs.resourceId
  }
}
