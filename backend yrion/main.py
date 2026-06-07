from fastapi import FastAPI

# 🔐 AUTH (dossier: inscription_et_connexion)
# Attention à la faute "inscrpition" présente sur ta capture
from inscription_et_connexion.inscrpition import router as auth_register_router
from inscription_et_connexion.connexion import router as auth_login_router

# 🏠 ACCUEIL (dossier: acceuil)
from acceuil.acceuil import router as home_router

# 👤 PROFIL & ⚙️ PARAMÈTRES (dossier: parametre_et_profil)
from parametre_et_profil.profil import router as profile_router
from parametre_et_profil.parametre import router as settings_router


app = FastAPI(title="NX Backend 🚀")


# =========================
# 🔐 AUTH ROUTES
# =========================
app.include_router(auth_register_router, prefix="/auth")
app.include_router(auth_login_router, prefix="/auth")


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
# 🧠 ROOT TEST
# =========================
@app.get("/")
def root():
    return {
        "status": "success",
        "message": "NX backend actif 🚀",
        "modules": [
            "auth",
            "home",
            "profile",
            "parametre"
        ]
    }