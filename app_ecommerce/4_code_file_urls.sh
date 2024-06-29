echo "[INFO] - ecommerce.urls.build"
cat <<text >ecommerce/urls.py
from django.urls import path
from ecommerce.views import Home, AddToCart

urlpatterns = [
    path('home', Home.as_view(), name='home'),
    path('add_to_cart/<int:product_id>', AddToCart.as_view(), name='add_to_cart'),
]
text