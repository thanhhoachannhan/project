echo "[INFO] - wsgi.build"
cat <<text >project/wsgi.py
import os

from django.core.wsgi import get_wsgi_application


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
application = get_wsgi_application()
text

echo "[INFO] - asgi.build"
cat <<text >project/asgi.py
import os

from django.core.asgi import get_asgi_application


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')

application = get_asgi_application()
text