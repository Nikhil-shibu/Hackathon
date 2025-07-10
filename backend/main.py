from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import os
from dotenv import load_dotenv
from firebase_config import firebase_db

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI(
    title="Supportive Companion API",
    description="Backend API for specially-abled community support app",
    version="1.0.0"
)

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models for request/response
class UserProfile(BaseModel):
    user_id: str
    name: str
    condition: str  # autism, dementia, dyslexia, down_syndrome
    preferences: dict
    caregiver_id: Optional[str] = None

class CommunicationRequest(BaseModel):
    user_id: str
    message: str
    type: str  # "text_to_speech", "symbol_to_speech", "voice_to_text"

class RoutineTask(BaseModel):
    task_id: str
    title: str
    description: str
    image_url: Optional[str] = None
    time: str
    completed: bool = False

class MemoryItem(BaseModel):
    item_id: str
    title: str
    description: str
    image_url: Optional[str] = None
    reminder_time: Optional[str] = None

# In-memory storage for demo (replace with Firebase later)
users_db = {}
routines_db = {}
memory_db = {}

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "Supportive Companion API is running!", 
        "status": "healthy",
        "features": [
            "Communication Support",
            "Daily Routines",
            "Memory Support",
            "Learning Assistance"
        ]
    }

# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "Supportive Companion API"}

# User Profile endpoints
@app.post("/api/users/profile")
async def create_user_profile(profile: UserProfile):
    # Try Firebase first, fallback to in-memory storage
    firebase_result = await firebase_db.create_user_profile(profile.dict())
    if "error" in firebase_result:
        # Fallback to in-memory storage
        users_db[profile.user_id] = profile.dict()
        return {"message": "User profile created successfully (local storage)", "user_id": profile.user_id}
    else:
        return {"message": "User profile created successfully (Firebase)", "user_id": profile.user_id}

@app.get("/api/users/{user_id}/profile")
async def get_user_profile(user_id: str):
    # Try Firebase first, fallback to in-memory storage
    firebase_result = await firebase_db.get_user_profile(user_id)
    if "error" in firebase_result:
        # Fallback to in-memory storage
        if user_id not in users_db:
            raise HTTPException(status_code=404, detail="User not found")
        return users_db[user_id]
    else:
        return firebase_result

# Communication endpoints
@app.post("/api/communication/text-to-speech")
async def text_to_speech(request: CommunicationRequest):
    # Mock response for now
    return {
        "message": "Text converted to speech successfully", 
        "audio_url": f"https://api.example.com/audio/{request.user_id}/speech.wav",
        "text": request.message,
        "user_id": request.user_id
    }

@app.post("/api/communication/symbol-to-speech")
async def symbol_to_speech(request: CommunicationRequest):
    # Mock response for symbols
    symbol_responses = {
        "water": "I want water",
        "food": "I am hungry",
        "help": "I need help",
        "bathroom": "I need to go to the bathroom",
        "happy": "I am happy",
        "sad": "I am sad"
    }
    
    response_text = symbol_responses.get(request.message.lower(), "I want to communicate")
    
    return {
        "message": "Symbol converted to speech successfully",
        "audio_url": f"https://api.example.com/audio/{request.user_id}/symbol.wav",
        "text": response_text,
        "symbol": request.message,
        "user_id": request.user_id
    }

# Daily Routine endpoints
@app.get("/api/routines/{user_id}")
async def get_user_routines(user_id: str):
    if user_id not in routines_db:
        # Return sample routine for demo
        return {
            "user_id": user_id,
            "routines": [
                {
                    "task_id": "morning_1",
                    "title": "Brush Teeth",
                    "description": "Brush your teeth for 2 minutes",
                    "time": "08:00",
                    "completed": False,
                    "image_url": "https://example.com/images/brush_teeth.png"
                },
                {
                    "task_id": "morning_2",
                    "title": "Eat Breakfast",
                    "description": "Have a healthy breakfast",
                    "time": "08:30",
                    "completed": False,
                    "image_url": "https://example.com/images/breakfast.png"
                },
                {
                    "task_id": "morning_3",
                    "title": "Take Medicine",
                    "description": "Take your morning medicine",
                    "time": "09:00",
                    "completed": False,
                    "image_url": "https://example.com/images/medicine.png"
                }
            ]
        }
    return {"user_id": user_id, "routines": routines_db[user_id]}

@app.post("/api/routines/{user_id}/tasks")
async def create_routine_task(user_id: str, task: RoutineTask):
    if user_id not in routines_db:
        routines_db[user_id] = []
    routines_db[user_id].append(task.dict())
    return {"message": "Routine task created successfully", "task_id": task.task_id}

@app.put("/api/routines/{user_id}/tasks/{task_id}/complete")
async def complete_task(user_id: str, task_id: str):
    return {
        "message": "Task completed successfully", 
        "task_id": task_id,
        "user_id": user_id,
        "completed_at": "2025-07-10T10:30:00Z"
    }

# Memory Support endpoints
@app.get("/api/memory/{user_id}")
async def get_memory_items(user_id: str):
    if user_id not in memory_db:
        # Return sample memory items for demo
        return {
            "user_id": user_id,
            "memory_items": [
                {
                    "item_id": "family_1",
                    "title": "Mom",
                    "description": "This is your mother, Sarah",
                    "image_url": "https://example.com/images/mom.jpg"
                },
                {
                    "item_id": "family_2",
                    "title": "Dad",
                    "description": "This is your father, John",
                    "image_url": "https://example.com/images/dad.jpg"
                },
                {
                    "item_id": "important_1",
                    "title": "Home Address",
                    "description": "123 Main Street, Your City",
                    "image_url": "https://example.com/images/home.jpg"
                }
            ]
        }
    return {"user_id": user_id, "memory_items": memory_db[user_id]}

@app.post("/api/memory/{user_id}/items")
async def create_memory_item(user_id: str, item: MemoryItem):
    if user_id not in memory_db:
        memory_db[user_id] = []
    memory_db[user_id].append(item.dict())
    return {"message": "Memory item created successfully", "item_id": item.item_id}

# Learning Support endpoints
@app.get("/api/learning/{user_id}/content")
async def get_learning_content(user_id: str, difficulty: str = "easy"):
    return {
        "user_id": user_id,
        "difficulty": difficulty,
        "content": [
            {
                "lesson_id": "colors_1",
                "title": "Learning Colors",
                "description": "Learn basic colors with pictures",
                "type": "visual",
                "content_url": "https://example.com/lessons/colors.json"
            },
            {
                "lesson_id": "numbers_1",
                "title": "Counting Numbers",
                "description": "Learn to count from 1 to 10",
                "type": "interactive",
                "content_url": "https://example.com/lessons/numbers.json"
            }
        ]
    }

# Caregiver Dashboard endpoints
@app.get("/api/caregiver/{caregiver_id}/dashboard")
async def get_caregiver_dashboard(caregiver_id: str):
    return {
        "caregiver_id": caregiver_id,
        "patients": [
            {
                "user_id": "patient_1",
                "name": "Alex",
                "condition": "autism",
                "last_activity": "2025-07-10T09:30:00Z",
                "progress": {
                    "tasks_completed_today": 2,
                    "total_tasks": 5,
                    "streak_days": 3
                }
            }
        ],
        "summary": {
            "total_patients": 1,
            "active_today": 1,
            "alerts": []
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
