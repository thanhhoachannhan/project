echo "[INFO] - core.urls.build"
cat <<text >core/urls.py
from django.urls import path
from core.views import Index

urlpatterns = [
    path('index', Index.as_view(), name='index'),
]
text