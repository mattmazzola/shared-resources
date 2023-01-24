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

module containerAppsEnv 'modules/containerAppsEnvironment.bicep' = {
  name: 'containerAppsEnv'
  params: {
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsId
  }
}

module sqlDatabase 'modules/sqlDatabase.bicep' = {
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

module storageAccount 'modules/storage.bicep' = {
  name: 'storageAccountModule'
  params: {
    uniqueRgString: uniqueRgString
  }
}
