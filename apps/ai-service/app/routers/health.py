from datetime import datetime, timezone

from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
async def health_check() -> dict:
    return {
        "status": "ok",
        "service": "flowiq-ai-service",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "version": "0.0.1",
    }
