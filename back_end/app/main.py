from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routers import auth, users, health

app = FastAPI(
    title=settings.APP_NAME,
    description="AI-First Scaffold API",
    version="0.1.0",
)

# CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 挂载路由
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(health.router)


@app.get("/")
def root():
    return {"message": "AI-First Scaffold API running", "docs": "/docs"}
