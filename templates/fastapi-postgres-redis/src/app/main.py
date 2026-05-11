from fastapi import FastAPI

from app.config import settings

app = FastAPI(title=settings.app_name)


@app.get("/")
def root() -> dict[str, str]:
    return {
        "message": "FastAPI template is running",
        "app": settings.app_name,
        "environment": settings.app_env,
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {
        "status": "ok",
        "app": settings.app_name,
        "environment": settings.app_env,
    }