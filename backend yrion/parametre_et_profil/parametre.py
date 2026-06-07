from fastapi import APIRouter
import sqlite3

router = APIRouter()

def get_db():
    conn = sqlite3.connect("database_yrion/yrion.db")
    conn.row_factory = sqlite3.Row
    return conn


# ⚙️ GET SETTINGS (UI)
@router.get("/{user_id}")
def get_settings(user_id: int):

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM settings WHERE user_id = ?", (user_id,))
    settings = cursor.fetchone()

    conn.close()

    # si pas encore créé
    if not settings:
        return {
            "status": "success",
            "settings": {
                "theme": "dark",
                "notifications": True
            }
        }

    return {
        "status": "success",
        "settings": {
            "theme": settings["theme"],
            "notifications": bool(settings["notifications"])
        }
    }


# ✏️ UPDATE SETTINGS (UI FRIENDLY)
@router.put("/{user_id}")
def update_settings(user_id: int, data: dict):

    theme = data.get("theme")
    notifications = data.get("notifications")

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM settings WHERE user_id = ?", (user_id,))
    exists = cursor.fetchone()

    if not exists:
        cursor.execute("""
            INSERT INTO settings (user_id, theme, notifications)
            VALUES (?, ?, ?)
        """, (
            user_id,
            theme or "dark",
            1 if notifications else 0
        ))
    else:
        cursor.execute("""
            UPDATE settings
            SET theme = ?, notifications = ?
            WHERE user_id = ?
        """, (
            theme,
            1 if notifications else 0,
            user_id
        ))

    conn.commit()
    conn.close()

    return {
        "status": "success",
        "message": "Paramètres mis à jour",
        "settings": {
            "theme": theme,
            "notifications": notifications
        }
    }