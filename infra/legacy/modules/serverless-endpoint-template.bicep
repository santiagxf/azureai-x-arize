param projectName string = 'intelligent-apps'
param endpointName string = 'myserverless-text-1234ss'
param location string = resourceGroup().location
param modelId string = 'azureml://registries/azureml-mistral/models/Mistral-large'

var modelName = substring(modelId, (lastIndexOf(modelId, '/') + 1))
var subscriptionName = '${modelName}-subscription'

resource projectName_subscription 'Microsoft.MachineLearningServices/workspaces/marketplaceSubscriptions@2024-04-01-preview' = if (!startsWith(
  modelId,
  'azureml://registries/azureml/'
)) {
  name: '${projectName}/${subscriptionName}'
  properties: {
    modelId: modelId
  }
}

resource projectName_endpoint 'Microsoft.MachineLearningServices/workspaces/serverlessEndpoints@2024-04-01-preview' = {
  name: '${projectName}/${endpointName}'
  location: location
  sku: {
    name: 'Consumption'
  }
  properties: {
    modelSettings: {
      modelId: modelId
    }
  }
  dependsOn: [
    projectName_subscription
  ]
}

output endpointUri string = projectName_endpoint.properties.inferenceEndpoint.uri
