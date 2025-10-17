"""
Demo ứng dụng đơn giản nhất cho ArgoCD
Chỉ có 1 endpoint để test
"""

from fastapi import FastAPI
import uvicorn

# Tạo ứng dụng FastAPI đơn giản
app = FastAPI(title="ArgoCD Simple Demo", version="1.0.0")

@app.get("/")
async def hello():
    """Endpoint đơn giản để test"""
    return {
        "message": "Xin chào! Đây là demo ArgoCD đơn giản",
        "status": "OK",
        "version": "1.0.0"
    }

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
