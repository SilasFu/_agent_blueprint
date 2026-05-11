from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "fastapi-postgres-redis"
    app_env: str = "development"
    app_host: str = "0.0.0.0"
    app_port: int = 8000

    postgres_host: str = "127.0.0.1"
    postgres_port: int = 5432
    postgres_db: str = "appdb"
    postgres_user: str = "app"
    postgres_password: str = "app123"

    redis_host: str = "127.0.0.1"
    redis_port: int = 6379
    redis_db: int = 0

    database_url: str = "postgresql://app:app123@127.0.0.1:5432/appdb"
    redis_url: str = "redis://127.0.0.1:6379/0"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")


settings = Settings()