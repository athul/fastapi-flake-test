from fastapi import FastAPI  
import uvicorn

app = FastAPI()  

@app.get("/") 
async def main_route():     
  return {"message": "Hey, It is me Nix Docker"}

def start():
  """Launched with `poetry run start` at root level"""
  uvicorn.run("base_api.main:app", host="0.0.0.0", port=8000)
