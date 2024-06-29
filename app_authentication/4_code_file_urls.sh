echo "[INFO] - authentication.urls.build"
cat <<text >authentication/urls.py
from django.urls import path
from authentication.views import Login, Logout

urlpatterns = [
    path('login', Login.as_view(), name='login'),
    path('logout', Logout.as_view(), name='logout'),
]
text