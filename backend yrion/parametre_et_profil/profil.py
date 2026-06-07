from fastapi import APIRouter
import sqlite3

router = APIRouter()

def get_db():
    conn = sqlite3.connect("database_yrion/yrion.db")
    conn.row_factory = sqlite3.Row
    return conn


@router.get("/{user_id}")
def get_profile(user_id: int):

    conn = get_db()
    cursor = conn.cursor()

    # 👤 user data
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()

    if not user:
        return {
            "status": "error",
            "message": "Utilisateur introuvable"
        }

    # 📊 stats (posts count)
    cursor.execute("SELECT COUNT(*) as total FROM posts WHERE user_id = ?", (user_id,))
    posts_count = cursor.fetchone()["total"]

    conn.close()

    return {
        "status": "success",
        "profile": {
            "id": user["id"],
            "username": user["username"],
            "email": user["email"],
            "bio": user["bio"] or "Aucune bio",
            "profile_image": user["profile_image"] or "",
            "stats": {
                "posts": posts_count
            }
        }
    }