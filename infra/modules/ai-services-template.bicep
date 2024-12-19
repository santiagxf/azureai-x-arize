@description('Location of the resource.')
param location string = resourceGroup().location

@description('Name of the Azure AI Services account.')
param accountName string

@description('The resource model definition representing SKU')
param sku string = 'S0'

@description('Whether or not to allow keys for this account.')
param allowKeys bool = true

@allowed([
  'Enabled'
  'Disabled'
])
@description('Whether or not public endpoint access is allowed for this account.')
param publicNetworkAccess string = 'Enabled'

@allowed([
  'Allow'
  'Deny'
])
@description('The default action for network ACLs.')
param networkAclsDefaultAction string = 'Allow'

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
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: networkAclsDefaultAction
    }
    disableLocalAuth: allowKeys
  }
}

output endpointUri string = account.properties.endpoints['Azure AI Model Inference API']
output id string = account.id
