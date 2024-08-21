# GitHub Model Catalog and Choosing the right LLM Model

In this repository, you will learn how you can use models deployed in GitHub Model Catalog to use the best model for the right job and consume the greatest innovation.

## Deploy

We are using Github Models as Service to deploy the required models. The environment supports a dedicated codespace and you can interact with the following Serverless API endpoints. 

* Cohere Embed V3 - Multilingual
* Cohere Command R+
* Mistral-Large
* Mistral-Small
* Phi-3-Mini 128K
* OpenAI GPT-4

Notice that serverless API endpoints are currently supported on `eastus2` and `swidencentral`.

## Running the demo

## Environment setup

### GitHub Codespaces

You can run this template virtually by using GitHub Codespaces. The button will open a web-based VS Code instance in your browser:

1. Open the template (this may take several minutes):

    [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/leestott/azureai-x-arize)

2. Open a terminal window

### VS Code Dev Containers

⚠️ This option will only work if your Docker Desktop is allocated at least 16 GB of RAM. If you have less than 16 GB of RAM, you can try the [GitHub Codespaces option](#github-codespaces) or [set it up locally](#local-environment).

A related option is VS Code Dev Containers, which will open the project in your local VS Code using the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers):

1. Start Docker Desktop (install it if not already installed)
2. Open the project:

    [![Open in Dev Containers](https://img.shields.io/static/v1?style=for-the-badge&label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/leestott/azureai-x-arize)

3. In the VS Code window that opens, once the project files show up (this may take several minutes), open a terminal window.
4. Continue with the [deployment steps](#deployment)


This example currently build the packages `llama-index-embeddings-azure-inference` and `llama-index-llms-azure-inference` from source in LlamaIndex.

This repository has the following examples:

* [llama_index_selector.ipynb](llama_index_selector.ipynb): It explains how multiple LLMs can be use for data generation, evaluation, and for specific tasks like tool selection. It shows how to instrument your code using Phoenix.
* [src/app.py](src/app.py): A chainlit project that allows you to play with index we built in the previous example. Use the notebook to learn about the technique and the approach. You can use this playground for testing the idea.

## Running the Web App Demo 
To use chainlit, run the following command:

```bash
source .env
cd src
chainlit run app.py -w
```

A browser will open in `http://localhost:8000`.

![](docs/chainlit.gif)
