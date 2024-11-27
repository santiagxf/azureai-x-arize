param accountName string
param modelName string
param modelVersion string
@allowed([
  'OpenAI'
  'Microsoft'
  'Mistral AI'
  'Meta'
  'Cohere'
  'AI21 Labs'
])
param modelPublisherFormat string
@allowed([
    'GlobalStandard'
    'Standard'
    'GlobalProvisioned'
    'Provisioned'
])
param skuName string = 'GlobalStandard'
param raiPolicyName string = 'Microsoft.Default'
param capacity int = 1

resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  name: '${accountName}/${modelName}'
  sku: {
    name: skuName
    capacity: capacity
  }
  properties: {
    model: {
      format: modelPublisherFormat
      name: modelName
      version: modelVersion
    }
    raiPolicyName: raiPolicyName
  }
}
