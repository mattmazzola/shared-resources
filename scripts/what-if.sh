#!/bin/bash

# Load environment variables from azd
source .azure/dev/.env

# Run Azure what-if deployment with detailed output
az deployment sub what-if \
  --location "$AZURE_LOCATION" \
  --template-file ./infra/main.bicep \
  --parameters environmentName="$AZURE_ENV_NAME" \
  --parameters location="$AZURE_LOCATION" \
  --parameters tenantId="$AZURE_TENANT_ID" \
  --parameters resourceGroupName="$AZURE_RESOURCE_GROUP" \
  --parameters sqlServerAdminPassword="$SQL_SERVER_ADMIN_PASSWORD"
