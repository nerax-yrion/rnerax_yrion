from fastapi import APIRouter
import sqlite3

router = APIRouter()

def get_db():
    conn = sqlite3.connect("database_yrion/yrion.db")
    conn.row_factory = sqlite3.Row
    return conn


# 🏠 ACCUEIL / FEED (UI READY)
@router.get("/")
def get_home_feed():

    conn = get_db()
    cursor = conn.cursor()

    # 🔥 Posts + user (tout prêt pour UI)
    cursor.execute("""
        SELECT 
            posts.id AS post_id,
            posts.content,
            posts.image,
            posts.created_at,

            users.id AS user_id,
            users.username,
            users.profile_image

        FROM posts
        JOIN users ON posts.user_id = users.id
        ORDER BY posts.id DESC
    """)

    rows = cursor.fetchall()
    conn.close()

    # 📱 FORMAT EXACT POUR FLUTTER UI
    feed = []

    for row in rows:
        feed.append({
            "postId": row["post_id"],
            "text": row["content"] or "",
            "imageUrl": row["image"] or "",

            "time": row["created_at"],

            "user": {
                "id": row["user_id"],
                "name": row["username"],
                "avatar": row["profile_image"] or ""
            },

            # ❤️ prêt pour UI boutons
            "actions": {
                "likes": 0,
                "comments": 0,
                "isLiked": False
            }
        })

    return {
        "status": "success",
        "feed": feed
    }