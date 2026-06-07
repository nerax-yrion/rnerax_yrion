from fastapi import APIRouter
import sqlite3

router = APIRouter()

# Connexion DB
def get_db():
    conn = sqlite3.connect("database_yrion/yrion.db")
    conn.row_factory = sqlite3.Row
    return conn


@router.post("/register")
def register(data: dict):

    username = data.get("username")
    email = data.get("email")
    password = data.get("password")

    if not username or not email or not password:
        return {
            "status": "error",
            "message": "Tous les champs sont obligatoires"
        }

    conn = get_db()
    cursor = conn.cursor()

    # 🔍 vérifier email déjà utilisé
    cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
    user = cursor.fetchone()

    if user:
        return {
            "status": "error",
            "message": "Email déjà utilisé"
        }

    # 🧠 créer utilisateur
    cursor.execute("""
        INSERT INTO users (username, email, password)
        VALUES (?, ?, ?)
    """, (username, email, password))

    conn.commit()
    conn.close()

    return {
        "status": "success",
        "message": "Compte créé avec succès 🚀"
    }