import os
from typing import Tuple
import chainlit as cl
from chainlit.input_widget import Select, Slider

from llama_index.core import (
    Settings,
    StorageContext,
    VectorStoreIndex,
    SummaryIndex,
    SimpleDirectoryReader,
    load_index_from_storage,
    get_response_synthesizer
)
from llama_index.core.query_engine import RouterQueryEngine
from llama_index.core.selectors import LLMSingleSelector
from llama_index.core.retrievers import VectorIndexRetriever, SummaryIndexRetriever
from llama_index.core.response_synthesizers import ResponseMode
from llama_index.llms.azure_inference import AzureAICompletionsModel
from llama_index.embeddings.azure_inference import AzureAIEmbeddingsModel
from llama_index.core.query_engine.retriever_query_engine import RetrieverQueryEngine
from llama_index.core.callbacks import CallbackManager
from llama_index.core.tools import QueryEngineTool

try:
    # rebuild storage context
    storage_context = StorageContext.from_defaults(persist_dir="./storage")
    # load index
    vector_index = load_index_from_storage(storage_context, index_id="vector_index")
    summary_index = load_index_from_storage(storage_context, index_id="summary_index")
except:
    vector_index = None
    summary_index = None
    pass


def rebuild_indexes(data_path: str) -> Tuple[VectorStoreIndex, SummaryIndex]:
    documents = SimpleDirectoryReader(data_path).load_data(show_progress=True)
    
    vector_index = VectorStoreIndex.from_documents(documents)
    vector_index.set_index_id("vector_index")
    vector_index.storage_context.persist()
    summary_index = SummaryIndex.from_documents(documents)
    summary_index.set_index_id("summary_index")
    summary_index.storage_context.persist()

    return vector_index, summary_index


def build_simple_query_engine():
    global vector_index

    retriever = VectorIndexRetriever(
        index=vector_index, 
        similarity_top_k=2,
    )

    response_synthesizer = get_response_synthesizer(
        response_mode=ResponseMode.COMPACT,
        streaming = True
    )

    query_engine = RetrieverQueryEngine(
        retriever=retriever,
        response_synthesizer=response_synthesizer,
    )

    return query_engine


def build_summary_query_engine():
    global summary_index

    retriever = SummaryIndexRetriever(
        index=summary_index,
    )

    response_synthesizer = get_response_synthesizer(
        response_mode=ResponseMode.TREE_SUMMARIZE,
        streaming = True
    )

    query_engine = RetrieverQueryEngine(
        retriever=retriever,
        response_synthesizer=response_synthesizer,
    )

    return query_engine

@cl.on_chat_start
async def start():
    global vector_index
    global summary_index

    cl_settings = await cl.ChatSettings(
        [
            Select(
                id="llm",
                label="LLM model",
                description="The LLM used for generation",
                items={
                    "Cohere Command R+": "Cohere-command-r-plus-08-2024",
                    "Phi-3.5-Mini-instruct": "Phi-3.5-mini-instruct",
                    "Mistral-Large": "Mistral-large-2407",
                    "Mistral-Small": "Mistral-small",
                },
            ),
            Select(
                id="router_llm",
                label="Router LLM",
                description="The LLM model used for routing the requests.",
                items={
                    "GPT-4o-mini": "gpt-4o-mini",
                    "Mistral-Small": "Mistral-small",
                    "Phi-3.5-Mini-instruct": "Phi-3.5-mini-instruct",
                },
            ),
            Select(
                id="embedding_model",
                label="Embedding model",
                description="The model used for generating embeddings.",
                items={
                    "Cohere Embed V3 Multilingual": "Cohere-embed-v3-multilingual",
                    "Cohere Embed V3 English": "Cohere-embed-v3-english",
                    "text-embedding-3-large": "text-embedding-3-large",
                },
            )
        ]).send()

    Settings.llm = AzureAICompletionsModel(
        endpoint=os.getenv("AZURE_INFERENCE_ENDPOINT"),
        credential=os.getenv("AZURE_INFERENCE_CREDENTIAL"),
        model_name="Cohere-command-r-plus-08-2024",
        temperature=0.1, max_tokens=1024, streaming=True
    )
    Settings.embed_model = AzureAIEmbeddingsModel(
        endpoint=os.getenv("AZURE_INFERENCE_ENDPOINT"),
        credential=os.getenv("AZURE_INFERENCE_CREDENTIAL"),
        model_name="Cohere-embed-v3-multilingual",
    )
    Settings.callback_manager = CallbackManager([cl.LlamaIndexCallbackHandler()])
    Settings.context_window = 4096

    if not vector_index:
        vector_index, summary_index = rebuild_indexes("../data/paul_graham/")

    query_engine = build_query_engine_with_router()
    cl.user_session.set("query_engine", query_engine)
    cl.user_session.set("settings", cl_settings)

    await cl.Message(
        author="Assistant", content="Hello! I'm an AI assistant. I will try to answer questions about the life of Paul Graham. For specific questions I will use a vector index, but for more comprehensive questions I will use a summary index. I use a LLM to analyze you queston and decide which strategy I should use based on the complexity of the query. Use the settings section to change the model I use to decide."
    ).send()

def build_query_engine_with_router(router_llm=None):
    summary_tool = QueryEngineTool.from_defaults(
        query_engine=build_summary_query_engine(),
        description=(
            "Useful for summarization questions related to Paul Graham eassy on"
            " What I Worked On."
        ),
    )

    vector_tool = QueryEngineTool.from_defaults(
        query_engine=build_simple_query_engine(),
        description=(
            "Useful for retrieving specific context from Paul Graham essay on What"
            " I Worked On."
        ),
    )

    query_engine = RouterQueryEngine(
        selector=LLMSingleSelector.from_defaults(llm=router_llm),
        query_engine_tools=[
            summary_tool,
            vector_tool,
        ],
    )

    return query_engine

@cl.on_message
async def main(message: cl.Message):
    query_engine = cl.user_session.get("query_engine") # type: RetrieverQueryEngine

    msg = cl.Message(content="", author="Assistant")

    res = await cl.make_async(query_engine.query)(message.content)

    for token in res.response_gen:
        await msg.stream_token(token)
    await msg.send()

@cl.on_settings_update
async def setup_agent(settings):
    cl.user_session.set("settings", settings)

    if settings.get("router_llm", None):
        router_llm_environ = settings["router_llm"]
        router_llm = AzureAICompletionsModel(
            endpoint=os.getenv("AZURE_INFERENCE_ENDPOINT"),
            credential=os.getenv("AZURE_INFERENCE_CREDENTIAL"),
            model_name=router_llm_environ,
            temperature=0.1, max_tokens=1024, streaming=True
        )
        query_engine = build_query_engine_with_router(router_llm)
        cl.user_session.set("query_engine", query_engine)

        await cl.Message(
            author="Assistant", content=f"We are now using {router_llm_environ} for routing queries.", disable_feedback=True
        ).send()
