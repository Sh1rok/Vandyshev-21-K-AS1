from fastapi import FastAPI
import uvicorn
import os

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello, World! Привет из вашего первого микросервиса!"}

@app.get("/health")
def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    # Получаем порт из переменной окружения, или используем 8000 по умолчанию
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)