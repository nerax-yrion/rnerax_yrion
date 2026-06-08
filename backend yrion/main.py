from fastapi import FastAPI

# 🏠 ACCUEIL (dossier: acceuil)
from acceuil.acceuil import router as home_router

# 👤 PROFIL & ⚙️ PARAMÈTRES (dossier: parametre_et_profil)
from parametre_et_profil.profil import router as profile_router
from parametre_et_profil.parametre import router as settings_router

app = FastAPI(title="NX Backend Application 🚀")

# =========================
# 🏠 HOME (FEED)
# =========================
app.include_router(home_router, prefix="/home")

# =========================
# 👤 PROFILE
# =========================
app.include_router(profile_router, prefix="/profile")

# =========================
# ⚙️ SETTINGS
# =========================
app.include_router(settings_router, prefix="/parametre")

# =========================
# 👑 RACINE PERSONNALISÉE (Alan Mitha)
# =========================
@app.get("/")
def root():
    return {
        "Application": "NX Application Backend (Python) 🚀",
        "Créateur": "Alan Mitha",
        "Version": "1.0.0-Prod",
        "Statut": "Opérationnel",
        "Note": "L'authentification (Auth) est désormais déportée sur notre microservice d'élite Rust 🛡️",
        "Modules_Actifs": [
            "home",
            "profile",
            "parametre"
        ]
    }