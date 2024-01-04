pip install --upgrade pip
pip install django==5.0
pip install pillow==10.0
pip install gunicorn==20.0

django-admin startproject project .
python3 manage.py startapp core

echo "##################################################
import os
DEBUG=True
ALLOWED_HOST=['*']
INSTALLED_APPS += ['core']
AUTH_PASSWORD_VALIDATORS = []
MEDIA_URL = '/uploads/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'uploads')
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATICFILES_DIRS = [os.path.join(BASE_DIR, 'staticfiles')]
" >> project/settings.py

echo "##################################################
from django.urls import include
from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls.i18n import i18n_patterns

from core.views import *

urlpatterns += [
	path('i18n/', include('django.conf.urls.i18n')),
]
urlpatterns += i18n_patterns(
	
	# prefix_default_language = False
)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settins.MEDIA_ROOT)
" >> project/urls.py

python3 manage.py makemigrations core
python3 manage.py migrate
python3 manage.py shell -c "from django.contrib.auth import get_user_model;
get_user_model().objects.filter(username='admin').exists() or get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin');"


