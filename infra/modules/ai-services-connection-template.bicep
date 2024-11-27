param name string

param endpointUri string

param resourceId string

param hubName string


resource connection 'Microsoft.MachineLearningServices/workspaces/connections@2024-04-01-preview' = {
  name: '${hubName}/${name}'
  properties: {
    category: 'AIServices'
    target: endpointUri
    authType: 'AAD'
    isSharedToAll: true
    metadata: {
      ApiType: 'Azure'
      ResourceId: resourceId
    }
  }
}
