# Azure AI Foundry x Phoenix

In this repository, you will learn how you can use models deployed in Azure AI Foundry to use the best model for the right job and consume the greatest innovation.

## Deploy

We are using infrastructure as code to deploy the required models. The following script deploys different models using [Azure AI model inference](https://aka.ms/aiservices/inference) in Azure AI Foundry. 

* Cohere Embed V3 - Multilingual
* Cohere Command R+
* Mistral-Large
* Mistral-Small
* Phi-3-Mini 128K
* OpenAI GPT-4o

> [!TIP]
> Want to try all the models in Models as a Service? Try to deploy the model list included in `models-all.json` which will deploy all the models using bicep. For that open the file `deploy.bicep` and replace `models.json` for `models-all.json`.


```bash
RESOURCE_GROUP="santiagxf-azurei-x-arize-dev"
LOCATION="eastus2" 

cd .cloud

az group create --location $LOCATION --name $RESOURCE_GROUP
az deployment group create --resource-group $RESOURCE_GROUP --template-file deploy.json
```

Once deployment is done, create an `.env` file with the endpoints URLs and keys like the following one:

__.env__

```bash
export AZURE_AI_ENDPOINT="https://my-azure-ai-resource.services.ai.azure.com/models"
export AZURE_AI_CREDENTIAL="my_awesome_key"
export AZURE_OPENAI_ENDPOINT="https://my-azure-ai-resource.openai.azure.com"
```

> [!TIP]
> You can get this information very quickly by going to https://ai.azure.com

## Run

Use `.devcontainer` to spin off a GitHub codespace to run the examples. This will install all the packages required. This example currently build the packages `llama-index-embeddings-azure-inference` and `llama-index-llms-azure-inference` from source in LlamaIndex.

This repository has the following examples:

* [llama_index_selector.ipynb](llama_index_selector.ipynb): It explains how multiple LLMs can be use for data generation, evaluation, and for specific tasks like tool selection. It shows how to instrument your code using Phoenix.
* [src/app.py](src/app.py): A chainlit project that allows you to play with index we built in the previous example. Use the notebook to learn about the technique and the approach. You can use this playground for testing the idea.

To use chainlit, run the following command:

```bash
source .env
cd src
chainlit run app.py -w
```

A browser will open in `http://localhost:8000`.

![](docs/chainlit.gif)
