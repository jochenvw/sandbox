param loc string = 'westeurope'

// Script deploys a PostgreSQL Flexible Server with Azure AD authentication enabled
// Attempt to re-create error 'Unknown enum is for the AAD admin principal type'
// November 2023

param tentantId string = '[FILL IN TENANT ID]'
param adminPrincipalName string = '[FILL IN ADMIN PRINCIPAL NAME]'
param adminObjectId string = '[FILL IN ADMIN OBJECT ID]'

resource db 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: 'nl-stu-jvw-postgresql-db'
  location: loc
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '15'
    availabilityZone: '1'
    storage: {
      storageSizeGB: 32
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: tentantId
    } 
  }
}

resource dba 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2023-03-01-preview' = {
  name: adminObjectId
  parent: db
  properties: {
    principalName: adminPrincipalName
    principalType: 'User'
    tenantId: tentantId
  }
}
