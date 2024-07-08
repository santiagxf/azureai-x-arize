# TBD


## Deploy

```bash
RESOURCE_GROUP="santiagxf-azurei-x-arize-dev"
LOCATION="eastus2"

az group create --location $LOCATION --name $RESOURCE_GROUP
az deployment group create --resource-group $RESOURCE_GROUP --template-file deploy.json
```