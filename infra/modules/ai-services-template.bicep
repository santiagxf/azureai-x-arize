param accountName string
param sku string = 'S0'
param location string = resourceGroup().location

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: accountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: sku
  }
  kind: 'AIServices'
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
    }
    disableLocalAuth: true
  }
}

output endpointUri string = account.properties.endpoints['Azure AI Model Inference API']
output id string = account.id
