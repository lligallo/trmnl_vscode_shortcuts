from fastapi import FastAPI, Request
from pydantic import BaseModel


async def on_fetch(request, env):
    """
    Main entry point for the Cloudflare Python Worker.

    This asynchronous function is invoked by the Cloudflare Workers runtime
    when the Worker receives an HTTP request. It uses the `asgi` module
    to bridge the incoming Cloudflare request to the FastAPI application (`app`),
    allowing FastAPI to process the request and generate a response.

    Args:
        request: The incoming HTTP request object from Cloudflare.
        env: An object providing access to Worker bindings (e.g., environment
             variables, KV namespaces, R2 buckets).

    Returns:
        A Response object that will be sent back to the client.
    """
    import asgi

    return await asgi.fetch(app, request, env)


app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello, World!"}


@app.get("/env")
async def env(req: Request):
    env = req.scope["env"]
    return {
        "message": "Here is an example of getting an environment variable: "
        + env.MESSAGE
    }

