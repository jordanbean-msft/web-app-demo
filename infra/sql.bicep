param sqlServerName string
param sqlDbName string
param location string
param sqlAADAdminName string
param sqlAADAdminObjectId string

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administrators: {
      login: sqlAADAdminName
      sid: sqlAADAdminObjectId
      tenantId: subscription().tenantId
      principalType: 'User'
      azureADOnlyAuthentication: true
    }
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
  resource firewallRules 'firewallRules@2021-11-01' = {
    name: 'AllowAllAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

resource sql 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: '${sqlServer.name}/${sqlDbName}'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
  }
}

output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sql.name
output sqlDatabaseConnectionString string = 'Server=tcp:${reference(sqlServer.id).fullyQualifiedDomainName};database=${sqlDbName};'
