echo "[INFO] - settings.build"
cat <<text >project/settings.py
""" Settings """
import os
from pathlib import Path

from django.utils.translation import gettext_lazy as _

""" Base settings """
BASE_DIR = Path(__file__).resolve().parent.parent
DEBUG=True
SECRET_KEY = 'dovanthanh'
ALLOWED_HOSTS=['*']
ROOT_URLCONF = 'project.urls'
WSGI_APPLICATION = 'project.wsgi.application'
""" APPS """
AUTH_APP = 'authentication'
APPS = [AUTH_APP, 'core', 'ecommerce']
DJANGO_APPS = [f"django.contrib.{app}" for app in ['admin','auth','contenttypes','sessions','messages','staticfiles']]
INSTALLED_APPS = DJANGO_APPS + [app for app in APPS if os.path.exists(BASE_DIR / app)]
if os.path.exists(BASE_DIR / AUTH_APP) and AUTH_APP in APPS: AUTH_USER_MODEL = f'{AUTH_APP}.User'
""" Media """
MEDIA_URL = '/uploads/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'uploads')
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATICFILES_DIRS = [os.path.join(BASE_DIR, 'staticfiles')]
""" Templates """
CONTEXT_PROCESSORS = [
    'django.template.context_processors.debug',
    'django.template.context_processors.request',
    'django.contrib.auth.context_processors.auth',
    'django.contrib.messages.context_processors.messages'
]
TEMPLATES = [{
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'DIRS': [os.path.join(BASE_DIR, 'templates')],
    'APP_DIRS': True,
    'OPTIONS': {'context_processors': CONTEXT_PROCESSORS,},
}]
""" Databases """
DATABASES = {'default': {'ENGINE': 'django.db.backends.sqlite3','NAME': BASE_DIR / 'db.sqlite3'}}
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
""" Timezone """
USE_TZ = True
USE_L10N = True
TIME_ZONE = 'UTC'
""" Languages """
USE_I18N = True
LANGUAGE_CODE = 'en'
LOCALE_PATHS = [BASE_DIR / 'locale/',]
LANGUAGES = (
    ('en', _('English')),
    ('vi', _('Vietnamese')),
    ('ja', _('Japanese')),
)
if not os.path.exists(BASE_DIR / 'locale'): os.mkdir('locale')
for lang in LANGUAGES:
    if not os.path.exists(BASE_DIR / 'locale' / lang[0]): os.mkdir(BASE_DIR / 'locale' / lang[0])
    if not os.path.exists(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES'): os.mkdir(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES')
""" Email """
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
EMAIL_BACKEND = 'django.core.mail.backends.filebased.EmailBackend'
EMAIL_FOLDER_NAME = 'emails'
EMAIL_PATH = BASE_DIR / EMAIL_FOLDER_NAME
if not os.path.exists(EMAIL_PATH): os.mkdir(EMAIL_FOLDER_NAME)
if not os.path.exists(EMAIL_PATH/'.gitkeep'):
    f = open(EMAIL_PATH/'.gitkeep', 'w')
    f.close()
""" Middleware """
AUTH_PASSWORD_VALIDATORS = []
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.locale.LocaleMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
""" Redirect """
LOGIN_URL = 'login'
""" EOF """
text