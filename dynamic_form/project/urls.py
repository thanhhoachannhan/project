from django.contrib import admin
from django.urls import path, include

from core.views import *

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', index, name='index'),
    path('create-contact', create_contact, name='create-contact'),
]
