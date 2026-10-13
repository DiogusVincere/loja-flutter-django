"""
Configurações do Django para o projeto core (API da loja).

Tudo o que muda entre a máquina de desenvolvimento e o servidor vem de
variáveis de ambiente — ver backend/.env.example.
"""
import os
from datetime import timedelta
from pathlib import Path

from django.core.management.utils import get_random_secret_key

BASE_DIR = Path(__file__).resolve().parent.parent


def _bool(valor, padrao=False):
    """Converte "True", "1", "sim"... em booleano; vazio devolve o padrão."""
    if valor is None or valor.strip() == "":
        return padrao
    return valor.strip().lower() in ("1", "true", "t", "yes", "y", "sim", "s")


def _lista(valor, padrao=""):
    """Converte "a,b, c" em ["a", "b", "c"]."""
    return [item.strip() for item in (valor or padrao).split(",") if item.strip()]


# SECRET_KEY: em produção defina a variável de ambiente SECRET_KEY.
# Sem ela, uma chave aleatória é gerada a cada inicialização — serve para
# desenvolver, mas invalida sessões e tokens JWT toda vez que o servidor reinicia.
SECRET_KEY = os.environ.get("SECRET_KEY") or get_random_secret_key()

# DEBUG fica desligado por padrão; ligue com DEBUG=True só em desenvolvimento.
DEBUG = _bool(os.environ.get("DEBUG"), padrao=False)

# Lista separada por vírgula. ".onrender.com" aceita qualquer subdomínio do Render.
ALLOWED_HOSTS = _lista(os.environ.get("ALLOWED_HOSTS"), "localhost,127.0.0.1")

CSRF_TRUSTED_ORIGINS = _lista(
    os.environ.get("CSRF_TRUSTED_ORIGINS"),
    "http://localhost:8000,http://127.0.0.1:8000",
)

# CORS: o app Flutter (Android/iOS) não envia Origin, mas o Flutter Web envia.
# Por padrão libera tudo; para restringir, defina CORS_ALLOW_ALL_ORIGINS=False
# e CORS_ALLOWED_ORIGINS=https://meusite.com,https://outro.com
CORS_ALLOW_ALL_ORIGINS = _bool(os.environ.get("CORS_ALLOW_ALL_ORIGINS"), padrao=True)
CORS_ALLOWED_ORIGINS = _lista(os.environ.get("CORS_ALLOWED_ORIGINS"))


# Aplicações

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "myapp",
    "rest_framework",
    "corsheaders",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "core.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "core.wsgi.application"


# Django REST Framework + JWT

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
}

AUTHENTICATION_BACKENDS = [
    "django.contrib.auth.backends.ModelBackend",
]

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(days=1),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "AUTH_HEADER_TYPES": ("Bearer",),
}


# Banco de dados (SQLite no disco do serviço)

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
    }
}


# Validação de senha

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]


# Internacionalização

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True


# Arquivos estáticos (só o admin usa)

STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
