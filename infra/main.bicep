param appName string
param environment string
param region string
param location string = resourceGroup().location
param sqlAADAdminName string
param sqlAADAdminObjectId string
param aadGroupObjectId string

module names 'resource-names.bicep' = {
  name: 'resource-names'
  params: {
    appName: appName
    region: region
    env: environment
  }
}

module managedIdentityDeployment 'managed-identity.bicep' = {
  name: 'managed-identity-deployment'
  params: {
    location: location
    managedIdentityName: names.outputs.managedIdentityName
  }
}

module loggingDeployment 'logging.bicep' = {
  name: 'logging-deployment'
  params: {
    logAnalyticsWorkspaceName: names.outputs.logAnalyticsWorkspaceName
    location: location
    appInsightsName: names.outputs.appInsightsName
    appServiceNetFrameworkName: names.outputs.appServiceNetFrameworkName
  }
}

module keyVaultDeployment 'key-vault.bicep' = {
  name: 'key-vault-deployment'
  params: {
    keyVaultName: names.outputs.keyVaultName
    location: location
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
    aadGroupObjectId: aadGroupObjectId
  }
}

module appServicePlanDeployment 'app-service-plan.bicep' = {
  name: 'app-service-plan-deployment'
  params: {
    appServicePlanName: names.outputs.appServicePlanName
    location: location
  }
}

module appServiceNetFrameworkDeployment 'app-service-net-framework.bicep' = {
  name: 'app-service-net-framework-deployment'
  params: {
    appInsightsName: loggingDeployment.outputs.appInsightsName
    appServiceNetFrameworkName: names.outputs.appServiceNetFrameworkName
    appServicePlanName: appServicePlanDeployment.outputs.appServicePlanName
    location: location
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
    sqlDbConnectionString: sqlDeployment.outputs.sqlDatabaseConnectionString
    keyVaultName: keyVaultDeployment.outputs.keyVaultName
  }
}

module sqlDeployment 'sql.bicep' = {
  name: 'sql-deployment'
  params: {
    location: location
    sqlAADAdminName: sqlAADAdminName
    sqlAADAdminObjectId: sqlAADAdminObjectId
    sqlDbName: names.outputs.sqlDbName
    sqlServerName: names.outputs.sqlServerName
  }
}
