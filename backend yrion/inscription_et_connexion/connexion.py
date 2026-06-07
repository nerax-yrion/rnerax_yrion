from fastapi import APIRouter
import sqlite3

router = APIRouter()

def get_db():
    conn = sqlite3.connect("database_yrion/yrion.db")
    conn.row_factory = sqlite3.Row
    return conn


@router.post("/login")
def login(data: dict):

    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return {
            "status": "error",
            "message": "Email et mot de passe requis"
        }

    conn = get_db()
    cursor = conn.cursor()

    # 🔍 chercher utilisateur
    cursor.execute(
        "SELECT * FROM users WHERE email = ? AND password = ?",
        (email, password)
    )

    user = cursor.fetchone()
    conn.close()

    if not user:
        return {
            "status": "error",
            "message": "Identifiants incorrects"
        }

    return {
        "status": "success",
        "message": "Connexion réussie 🚀",
        "user": {
            "id": user["id"],
            "username": user["username"],
            "email": user["email"]
        }
    }