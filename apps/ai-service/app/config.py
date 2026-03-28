from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    environment: str = "development"
    host: str = "0.0.0.0"
    port: int = 8000

    database_url: str = ""
    api_url: str = "http://localhost:3001"
    internal_api_key: str = "changeme"

    openai_api_key: str = ""
    anthropic_api_key: str = ""


settings = Settings()
