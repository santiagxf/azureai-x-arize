param location string = resourceGroup().location

@description('Name of the Azure AI hub')
param hubName string = 'hub-azurei-x-arize-dev'

@description('Name of the Azure AI project')
param projectName string = 'intelligent-apps'

@description('Name of the storage account used for the workspace.')
param storageAccountName string = replace(hubName, '-', '')
param keyVaultName string = replace(hubName, 'hub', 'kv')
param applicationInsightsName string = replace(hubName, 'hub', 'log')

@description('The container registry resource id if you want to create a link to the workspace.')
param containerRegistryName string = replace(hubName, '-', '')

@description('The tags for the resources')
param tagValues object = {
  owner: 'santiagxf'
  project: 'azurei-x-arize'
  environment: 'dev'
}

var tenantId = subscription().tenantId
var resourceGroupName = resourceGroup().name
var storageAccountId = resourceId(resourceGroupName, 'Microsoft.Storage/storageAccounts', storageAccountName)
var keyVaultId = resourceId(resourceGroupName, 'Microsoft.KeyVault/vaults', keyVaultName)
var applicationInsightsId = resourceId(resourceGroupName, 'Microsoft.Insights/components', applicationInsightsName)
var containerRegistryId = resourceId(
  resourceGroupName,
  'Microsoft.ContainerRegistry/registries',
  containerRegistryName
)

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
  }
  tags: tagValues
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableRbacAuthorization: true
    accessPolicies: []
  }
  tags: tagValues
}

resource applicationInsights 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
  tags: tagValues
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
  tags: tagValues
}

resource hub 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
  name: hubName
  kind: 'Hub'
  location: location
  identity: {
    type: 'systemAssigned'
  }
  sku: {
    tier: 'Standard'
    name: 'standard'
  }
  properties: {
    description: 'Azure AI hub'
    friendlyName: hubName
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightsId
    containerRegistry: (empty(containerRegistryName) ? null : containerRegistryId)
    encryption: {
      status: 'Disabled'
      keyVaultProperties: {
        keyVaultArmId: keyVaultId
        keyIdentifier: ''
      }
    }
    hbiWorkspace: false
  }
  tags: tagValues
}

resource project 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
  name: projectName
  kind: 'Project'
  location: location
  identity: {
    type: 'systemAssigned'
  }
  sku: {
    tier: 'Standard'
    name: 'standard'
  }
  properties: {
    description: 'Azure AI project'
    friendlyName: projectName
    hbiWorkspace: false
    hubResourceId: hub.id
  }
  tags: tagValues
}
