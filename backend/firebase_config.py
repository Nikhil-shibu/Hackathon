import firebase_admin
from firebase_admin import credentials, firestore, storage
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Firebase configuration
class FirebaseConfig:
    def __init__(self):
        self.db = None
        self.bucket = None
        self.app = None
        self.initialize_firebase()
    
    def initialize_firebase(self):
        """Initialize Firebase Admin SDK"""
        try:
            # For development, you can use the emulator or service account key
            # Method 1: Using service account key file (recommended for hackathon)
            service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_PATH')
            
            if service_account_path and os.path.exists(service_account_path):
                # Initialize with service account key
                cred = credentials.Certificate(service_account_path)
                self.app = firebase_admin.initialize_app(cred, {
                    'storageBucket': os.getenv('FIREBASE_STORAGE_BUCKET', 'your-project-id.appspot.com')
                })
            else:
                # Method 2: Using default credentials (for local testing)
                # This will work if you have Firebase CLI installed and logged in
                try:
                    self.app = firebase_admin.initialize_app()
                except Exception as e:
                    print(f"Firebase initialization with default credentials failed: {e}")
                    print("Please set up Firebase service account key or use Firebase emulator")
                    return
            
            # Initialize Firestore
            self.db = firestore.client()
            
            # Initialize Storage
            self.bucket = storage.bucket()
            
            print("✅ Firebase initialized successfully!")
            
        except Exception as e:
            print(f"❌ Firebase initialization failed: {e}")
            print("Running in mock mode - using in-memory storage")
            self.db = None
            self.bucket = None

# Global Firebase instance
firebase_config = FirebaseConfig()

# Database operations
class FirebaseDB:
    def __init__(self):
        self.db = firebase_config.db
    
    async def create_user_profile(self, user_data):
        """Create user profile in Firestore"""
        if not self.db:
            return {"error": "Firebase not initialized"}
        
        try:
            doc_ref = self.db.collection('users').document(user_data['user_id'])
            doc_ref.set(user_data)
            return {"success": True, "user_id": user_data['user_id']}
        except Exception as e:
            return {"error": str(e)}
    
    async def get_user_profile(self, user_id):
        """Get user profile from Firestore"""
        if not self.db:
            return {"error": "Firebase not initialized"}
        
        try:
            doc_ref = self.db.collection('users').document(user_id)
            doc = doc_ref.get()
            if doc.exists:
                return doc.to_dict()
            else:
                return {"error": "User not found"}
        except Exception as e:
            return {"error": str(e)}
    
    async def save_routine_task(self, user_id, task_data):
        """Save routine task to Firestore"""
        if not self.db:
            return {"error": "Firebase not initialized"}
        
        try:
            doc_ref = self.db.collection('users').document(user_id).collection('routines').document(task_data['task_id'])
            doc_ref.set(task_data)
            return {"success": True, "task_id": task_data['task_id']}
        except Exception as e:
            return {"error": str(e)}
    
    async def get_user_routines(self, user_id):
        """Get user routines from Firestore"""
        if not self.db:
            return {"error": "Firebase not initialized"}
        
        try:
            routines_ref = self.db.collection('users').document(user_id).collection('routines')
            docs = routines_ref.stream()
            routines = []
            for doc in docs:
                routine_data = doc.to_dict()
                routines.append(routine_data)
            return {"routines": routines}
        except Exception as e:
            return {"error": str(e)}
    
    async def save_memory_item(self, user_id, memory_data):
        """Save memory item to Firestore"""
        if not self.db:
            return {"error": "Firebase not initialized"}
        
        try:
            doc_ref = self.db.collection('users').document(user_id).collection('memory').document(memory_data['item_id'])
            doc_ref.set(memory_data)
            return {"success": True, "item_id": memory_data['item_id']}
        except Exception as e:
            return {"error": str(e)}
    
    async def get_memory_items(self, user_id):
        """Get memory items from Firestore"""
        if not self.db:
            return {"error": "Firebase not initialized"}
        
        try:
            memory_ref = self.db.collection('users').document(user_id).collection('memory')
            docs = memory_ref.stream()
            memory_items = []
            for doc in docs:
                memory_data = doc.to_dict()
                memory_items.append(memory_data)
            return {"memory_items": memory_items}
        except Exception as e:
            return {"error": str(e)}
    
    async def update_task_completion(self, user_id, task_id, completed=True):
        """Update task completion status"""
        if not self.db:
            return {"error": "Firebase not initialized"}
        
        try:
            doc_ref = self.db.collection('users').document(user_id).collection('routines').document(task_id)
            doc_ref.update({
                'completed': completed,
                'completed_at': firestore.SERVER_TIMESTAMP
            })
            return {"success": True, "task_id": task_id}
        except Exception as e:
            return {"error": str(e)}

# Global database instance
firebase_db = FirebaseDB()
