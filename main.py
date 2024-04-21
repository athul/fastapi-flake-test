from fastapi import FastAPI  
import uvicorn

app = FastAPI()  

@app.get("/") 
async def main_route():     
  return {"message": "Hey, It is me Goku"}

def start():
  """Launched with `poetry run start` at root level"""
  uvicorn.run("my_package.main:app", host="0.0.0.0", port=8000, reload=True)
