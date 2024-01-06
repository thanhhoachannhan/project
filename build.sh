pip install --upgrade pip
pip install django==5.0
pip install pillow==10.0
pip install gunicorn==20.0

django-admin startproject project .
python3 manage.py startapp core
mkdir staticfiles
mkdir templates

echo "##################################################
import os
DEBUG=True
ALLOWED_HOSTS=['*']
INSTALLED_APPS += ['core']
AUTH_PASSWORD_VALIDATORS = []
MEDIA_URL = '/uploads/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'uploads')
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATICFILES_DIRS = [os.path.join(BASE_DIR, 'staticfiles')]
AUTH_USER_MODEL = 'core.User'
TEMPLATES[0]['DIRS'] = [os.path.join(BASE_DIR, 'templates')]
" >> project/settings.py

echo "##################################################
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls.i18n import i18n_patterns

urlpatterns = [
	path('admin/', admin.site.urls),
	path('i18n/', include('django.conf.urls.i18n')),
]
urlpatterns += i18n_patterns(
	path('', include('core.urls')),
	# prefix_default_language = False
)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
" >> project/urls.py

echo "##################################################
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, UserManager, Permission, GroupManager
from django.contrib.auth.validators import UnicodeUsernameValidator
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

class UserGroup(models.Model):
	name = models.CharField(_('name'), max_length=150, unique=True)
	permissions = models.ManyToManyField(
		Permission,
		verbose_name=_('permissions'),
		blank=True,
	)

	objects = GroupManager()

	class Meta:
		verbose_name = _('group')
		verbose_name_plural = _('groups')

	def __str__(self):
		return self.name

	def natural_key(self):
		return (self.name,)


class User(AbstractBaseUser, PermissionsMixin):
	username = models.CharField(_('username'), max_length=101, unique=True, validators=[UnicodeUsernameValidator()])
	fullname = models.CharField(_('fullname'), max_length=100)
	email = models.EmailField(_('email'))
	avatar = models.ImageField(_('avatar'), upload_to='avatar')
	address = models.TextField(_('address'))
	is_seller = models.BooleanField(_('is_seller'), default=False)
	is_staff = models.BooleanField(_('is_staff'), default=False)
	is_active = models.BooleanField(_('is_active'), default=True)
	date_joined = models.DateTimeField(_('date_joined'), default=timezone.now)
	groups = models.ManyToManyField(UserGroup, verbose_name=_('groups'), blank=True)

	objects = UserManager()

	EMAIL_FIELD = 'email'
	USERNAME_FIELD = 'username'
	# REQUIRED_FIELDS = ['email']

	def __str__(self):
		return f'self.fullname({self.username})'

	class Meta:
		verbose_name = _('user')
		verbose_name_plural = _('users')
" > core/models.py

echo "##################################################
from django.apps import apps
from django.contrib import admin
from django.contrib.admin.sites import AlreadyRegistered
from django.contrib.auth.admin import UserAdmin, GroupAdmin
from django.contrib.auth.models import Group
from django.utils.translation import gettext_lazy as _

from core.models import User, UserGroup


@admin.register(User)
class UserAdmin(UserAdmin):
	fieldsets = (
		(None, {
			'fields': ('username', 'password', 'fullname', 'email', 'avatar', 'address', 'is_seller', 'groups')
		}),
		('Advanced options', {
			'classes': ('collapse'),
			'fields': ('user_permissions', 'is_active', 'is_staff', 'is_superuser')
		})
	)
	list_display = ('username', 'email', 'date_joined')
	list_filter = ('is_staff', 'is_active')
	search_fields = ('username__startswith', 'fullname__startswith')

	class Meta:
		ordering = ('date_joined')


admin.site.unregister(Group)
@admin.register(UserGroup)
class CustomGroupAdmin(GroupAdmin):
	fieldsets = (
		(None, {'fields': ('name', 'permissions')}),
	)

for model in apps.get_app_config('core').get_models():
	try: admin.site.register(model)
	except AlreadyRegistered: pass
" > core/admin.py

echo "##################################################
from django.shortcuts import render, redirect
from django.contrib.auth import login, logout, authenticate
from django.urls import reverse
from django.views import View
from django.contrib.auth.mixins import LoginRequiredMixin


class Home(View):
	def get(self, request):
		return render(request, 'home.html')

class LoginView(View):
	def get(self, request):
		if request.user.is_authenticated:
			return redirect(reverse('home'))
		return render(request, 'login.html')
	def post(self, request):
		username = request.POST.get('username')
		password = request.POST.get('password')
		user = authenticate(request, username=username, password=password)
		if user is not None:
			login(request, user)
			next_url = request.GET.get('next', 'home')
			return redirect(next_url)
		return render(request, 'login.html')
" > core/views.py

echo "##################################################
from django.urls import path
from core.views import *

urlpatterns = [
	path('login', LoginView.as_view(), name='login'),
	path('home', Home.as_view(), name='home'),
]
" > core/urls.py

echo "##################################################
home
" > templates/home.html

echo "##################################################
<form method='post'>
{% csrf_token %}
<input type='text' name='username'/>
<input type='password' name='password'/>
<input type='submit' value='login'/>
</form>
" > templates/login.html

echo "##################################################
all:
	rm -fr migrations
	rm -fr db.sqlite3
	python3 manage.py makemigrations core
	python3 manage.py migrate
	python3 manage.py shell -c \"from django.contrib.auth import get_user_model; get_user_model().objects.filter(username='admin').exists() or get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin')\"
	python3 manage.py runserver 2000
" > makefile

python3 manage.py collectstatic --no-input
python3 manage.py makemigrations core
python3 manage.py migrate
python3 manage.py shell -c "from django.contrib.auth import get_user_model; get_user_model().objects.filter(username='admin').exists() or get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin');"
python3 manage.py runserver 2000
