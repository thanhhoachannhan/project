echo "[INFO] - ecommerce.admin.build"
cat <<text >ecommerce/admin.py
from django.apps import apps
from django.contrib import admin
from django.contrib.admin.sites import AlreadyRegistered


for model in apps.get_app_config('ecommerce').get_models():
    try: admin.site.register(model)
    except AlreadyRegistered: pass
text