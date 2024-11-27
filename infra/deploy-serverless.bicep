param location string = resourceGroup().location
param hubName string = 'hub-azurei-x-arize-dev'
param projectName string = 'intelligent-apps'

@description('The models to deploy in the project')
param modelIds array = [
  'azureml://registries/azureml-cohere/models/Cohere-command-r-plus'
  'azureml://registries/azureml-cohere/models/Cohere-embed-v3-multilingual'
  'azureml://registries/azureml-mistral/models/Mistral-large'
  'azureml://registries/azureml-mistral/models/Mistral-small'
  'azureml://registries/azureml/models/Phi-3-mini-4k-instruct'
]

var resourceGroupName = resourceGroup().name

module projectHub 'modules/project-hub-template.bicep' = {
  name: 'projectHub'
  scope: resourceGroup(resourceGroupName)
  params: {
    hubName: hubName
    projectName: projectName
  }
}

module deployment_models 'modules/serverless-endpoint-template.bicep' = [
  for (item, i) in modelIds: {
    name: 'deployment-models-${i}'
    scope: resourceGroup(resourceGroupName)
    params: {
      projectName: projectName
      endpointName: '${substring(item,(lastIndexOf(item,'/')+1))}-${substring(uniqueString(resourceGroup().id),0,5)}'
      location: location
      modelId: item
    }
    dependsOn: [
      projectHub
    ]
  }
]

output endpoints string = reference('deployment-models-0').outputs.endpointUri.value
