param uniqueRgString string
// global 3-24	Alphanumerics and hyphens
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault
@minLength(3)
@maxLength(24)
param keyVaultName string = '${resourceGroup().name}-${uniqueRgString}-keyvault'
param location string = resourceGroup().location
param tenantId string
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
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

output resourceId string = keyVault.id
output name string = keyVault.name
output uri string = keyVault.properties.vaultUri
