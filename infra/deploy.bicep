param location string = resourceGroup().location
param resourceGroupName string = resourceGroup().name

param accountName string = 'azurei-x-arize-models-dev'
param hubName string = 'hub-azurei-x-arize-dev'
param projectName string = 'intelligent-apps'

var models = json(loadTextContent('models.json'))

module projectHub 'modules/project-hub-template.bicep' = {
  name: 'projectHub'
  scope: resourceGroup(resourceGroupName)
  params: {
    hubName: hubName
    projectName: projectName
  }
}

module aiServicesAccount 'modules/ai-services-template.bicep' = {
  name: 'aiServicesAccount'
  scope: resourceGroup(resourceGroupName)
  params: {
    accountName: accountName
    location: location
  }
}

module aiServicesConnection 'modules/ai-services-connection-template.bicep' = {
  name: 'aiServicesConnection'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: accountName
    endpointUri: aiServicesAccount.outputs.endpointUri
    resourceId: aiServicesAccount.outputs.id
    hubName: hubName
  }
}

@batchSize(1)
module model_deployemnts 'modules/ai-services-deployment-template.bicep' = [
  for (item, i) in models: {
    name: 'deployment-${item.name}'
    scope: resourceGroup(resourceGroupName)
    params: {
      accountName: accountName
      modelName: item.name
      modelVersion: item.version
      modelPublisherFormat: item.provider
    }
    dependsOn: [
      aiServicesAccount
    ]
  }
]

output endpoint string = aiServicesAccount.outputs.endpointUri
