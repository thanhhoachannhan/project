echo "[INFO] - env.build"
pip install --upgrade pip
pip install django==5.0
pip install pillow==10.0
pip install gunicorn==20.0

################################################## == Init
# ===== #
echo "[INFO] - init.build"
# django-admin startproject project .
mkdir project
mkdir staticfiles
mkdir templates

# ===== #
echo "[INFO] - manage.build"
cat <<text >manage.py
import os, sys
from django.core.management import execute_from_command_line


if __name__ == '__main__':
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
    execute_from_command_line(sys.argv)
text

# ===== #
echo "[INFO] - wsgi.build"
cat <<text >project/wsgi.py
import os

from django.core.wsgi import get_wsgi_application


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
application = get_wsgi_application()
text

# ===== #
echo "[INFO] - asgi.build"
cat <<text >project/asgi.py
import os

from django.core.asgi import get_asgi_application


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')

application = get_asgi_application()
text

# ===== #
echo "[INFO] - settings.build"
cat <<text >project/settings.py
import os
from pathlib import Path

from django.utils.translation import gettext_lazy as _


BASE_DIR = Path(__file__).resolve().parent.parent
DEBUG=True
SECRET_KEY = 'dovanthanh'
ALLOWED_HOSTS=['*']
ROOT_URLCONF = 'project.urls'
WSGI_APPLICATION = 'project.wsgi.application'

DJANGO_APPS = [f"django.contrib.{app}" for app in ['admin','auth','contenttypes','sessions','messages','staticfiles']]
INSTALLED_APPS = DJANGO_APPS
APPS = ['authentication', 'core', 'ecommerce']
for app in APPS:
    if os.path.exists(BASE_DIR / app):
        INSTALLED_APPS += [app]

MEDIA_URL = '/uploads/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'uploads')
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATICFILES_DIRS = [os.path.join(BASE_DIR, 'staticfiles')]

AUTH_PASSWORD_VALIDATORS = []
if os.path.exists(BASE_DIR / 'authentication'): AUTH_USER_MODEL = 'authentication.User'

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

DATABASES = {'default': {'ENGINE': 'django.db.backends.sqlite3','NAME': BASE_DIR / 'db.sqlite3'}}
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

USE_TZ = True
USE_L10N = True
TIME_ZONE = 'UTC'

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

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
EMAIL_BACKEND = 'django.core.mail.backends.filebased.EmailBackend'
EMAIL_FOLDER_NAME = 'emails'
EMAIL_PATH = BASE_DIR / EMAIL_FOLDER_NAME
if not os.path.exists(EMAIL_PATH): os.mkdir(EMAIL_FOLDER_NAME)
if not os.path.exists(EMAIL_PATH/'.gitkeep'):
    f = open(EMAIL_PATH/'.gitkeep', 'w')
    f.close()

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

LOGIN_URL = 'login'
text

# ===== #
echo "[INFO] - urls.build"
cat <<text >project/urls.py
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls.i18n import i18n_patterns

from core.views import Index


urlpatterns = [
    path('', Index.as_view(), name='index'),
    path('admin/', admin.site.urls),
    path('i18n/', include('django.conf.urls.i18n')),
]
urlpatterns += i18n_patterns(
    *[path(f'{app}/', include(f'{app}.urls')) for app in settings.APPS],
    # prefix_default_language = False
)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
text

################################################## == Auth app
# ===== #
python3 manage.py startapp authentication

# ===== #
echo "[INFO] - authentication.models.build"
cat <<text >authentication/models.py
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
        return f'{self.fullname}({self.username})'

    class Meta:
        verbose_name = _('user')
        verbose_name_plural = _('users')
    
    def cart_count(self):
        return self.cartitem_set.count()
text

# ===== #
echo "[INFO] - authentication.admin.build"
cat <<text >authentication/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin, GroupAdmin
from django.contrib.auth.models import Group
from django.utils.translation import gettext_lazy as _

from authentication.models import User, UserGroup


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
text

# ===== #
echo "[INFO] - authentication.views.build"
cat <<text >authentication/views.py
from django.shortcuts import render, redirect
from django.contrib.auth import login, logout, authenticate
from django.urls import reverse
from django.views import View
from django.contrib.auth.mixins import LoginRequiredMixin


class Login(View):
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

class Logout(LoginRequiredMixin, View):
    def get(self, request):
        logout(request)
        next_url = request.GET.get('next', '/')
        return redirect(next_url)
text

# ===== #
echo "[INFO] - authentication.urls.build"
cat <<text >authentication/urls.py
from django.urls import path
from authentication.views import Login, Logout

urlpatterns = [
    path('login', Login.as_view(), name='login'),
    path('logout', Logout.as_view(), name='logout'),
]
text

################################################## == Core app
# ===== #
python3 manage.py startapp core
mkdir templates/core

# ===== #
echo "[INFO] - core.admin.build"
cat <<text >core/admin.py
from django.apps import apps
from django.contrib import admin
from django.contrib.admin.sites import AlreadyRegistered


for model in apps.get_app_config('core').get_models():
    try: admin.site.register(model)
    except AlreadyRegistered: pass
text

# ===== #
echo "[INFO] - core.views.build"
cat <<text >core/views.py
from django.shortcuts import render
from django.views import View


class Index(View):
    def get(self, request):
        return render(request, 'core/index.html')
text

# ===== #
echo "[INFO] - core.urls.build"
cat <<text >core/urls.py
from django.urls import path
from core.views import Index

urlpatterns = [
    path('index', Index.as_view(), name='index'),
]
text

# ===== #
echo "[INFO] - templates/core/index.html"
cat <<HTML >templates/core/index.html
Core
HTML

################################################## == Ecommerce app
# ===== #
python3 manage.py startapp ecommerce

# ===== #
echo "[INFO] - ecommerce.models.build"
cat <<text >ecommerce/models.py
from django.db import models
from django.utils.translation import gettext_lazy as _

from authentication.models import User


class Category(models.Model):
    name = models.CharField(max_length=100, null=True, blank=True)
    image = models.ImageField(upload_to='category', null=True, blank=True)
    def __str__(self):
        return self.name
    class Meta:
      verbose_name_plural = 'categories'

class Product(models.Model):
    name = models.CharField(max_length=54, null=True, blank=True)
    full_name = models.CharField(max_length=100, null=True, blank=True)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, null=True, blank=True)
    price = models.FloatField(null=True, blank=True)
    short_description = models.TextField(null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    def has_variant(self):
        print(self.variant_set.count())
        return self.variant_set.count() > 0
    def image(self):
        products = ProductImage.objects.all()
        return products[0].file.url
    def __str__(self):
        return self.name

class ProductImage(models.Model):
    file = models.ImageField(upload_to='product_image', null=True, blank=True)
    product = models.ForeignKey(Product, on_delete=models.CASCADE, null=True, blank=True)

class Variant(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, null=True, blank=True)
    image = models.ImageField(upload_to='variant_image', null=True, blank=True)
    attribute_name = models.CharField(max_length=100, null=True, blank=True)
    attribute_value = models.CharField(max_length=100, null=True, blank=True)

class CartItem(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, null=True, blank=True)
    variant = models.ForeignKey(Variant, on_delete=models.CASCADE, null=True, blank=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    quantity = models.IntegerField(default=1, null=True, blank=True)
text

# ===== #
echo "[INFO] - ecommerce.admin.build"
cat <<text >ecommerce/admin.py
from django.apps import apps
from django.contrib import admin
from django.contrib.admin.sites import AlreadyRegistered


for model in apps.get_app_config('ecommerce').get_models():
    try: admin.site.register(model)
    except AlreadyRegistered: pass
text

# ===== #
echo "[INFO] - ecommerce.views.build"
cat <<text >ecommerce/views.py
from django.shortcuts import render
from django.views import View
from django.contrib.auth.mixins import LoginRequiredMixin

from ecommerce.models import Product, Category


class Home(View):
    def get(self, request):
        products = Product.objects.all()
        category_id = request.GET.get('category')
        if category_id:
            products = Product.objects.filter(category=Category.objects.get(id=category_id))
        return render(request, 'home.html', {
            'products': products,
            'categories': Category.objects.all()[:7],
        })

class AddToCart(LoginRequiredMixin, View):
    def get(self, request, product_id):
        product = Product.objects.get(id=product_id)
        product_images = product.productimage_set.all()
        variant_images = []
        attributes = {}
        if product.has_variant():
            variants = product.variant_set.all()
            for variant in variants:
                variant_images.append(variant.image)
                name = variant.attribute_name
                value = variant.attribute_value
                if name not in attributes:
                    attributes[name] = []
                attributes[name].append(value)
        print(attributes)


        return render(request, 'add_to_cart.html', {
            'product': product,
            'product_images': product_images,
            'variant_images': variant_images,
            'attributes': attributes
        })
text

# ===== #
echo "[INFO] - ecommerce.urls.build"
cat <<text >ecommerce/urls.py
from django.urls import path
from ecommerce.views import Home, AddToCart

urlpatterns = [
    path('home', Home.as_view(), name='home'),
    path('add_to_cart/<int:product_id>', AddToCart.as_view(), name='add_to_cart'),
]
text

################################################## == Template
# ===== #
echo "[DIR] - template.inc.create"
mkdir templates/inc

# ===== #
echo "[INFO] - template.base.build"
cat <<HTML >templates/base.html
{% load static %}
{% load i18n %}
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="{% static 'css/main.css' %}">
  <title>{% block title %}{% endblock %}</title>
</head>
<body>
  <div class="app_root">
    {% include 'inc/header.html' %}
    {% block content %}{% endblock %}
  </div>
    <script src="{% static 'js/main.js' %}"></script>
</body>
</html>
HTML

# ===== #
cat <<HTML >templates/inc/header.html
{% load static %}
{% load i18n %}
<div class="header_root {% if request.user.is_authenticated %}header_root_authenticated{% endif %}">
  <a class="logo_container" href="{% url 'home' %}">Logo</a>
  <div class="search_container">
    <div class="search_root">
      <input type="text" placeholder="Search anything...">
      <a href="" class="button_search">Search</a>
    </div>
  </div>
  <div class="action_container">
    <div class="action_root {% if request.user.is_authenticated %}action_root_authenticated{% endif %}">
      {% if request.user.is_authenticated %}
        <div class="become_seller">{% translate 'Become A Seller' %}</div>
      {% endif %}
      <div class="language">
        <form action="{% url 'set_language' %}" method="post" id="language_selection">
          {% csrf_token %}
          <input name="next" type="hidden" value="{{ request.get_full_path }}">
          <select name="language" >
            {% get_current_language as LANGUAGE_CODE %}
            {% get_available_languages as LANGUAGES %}
            {% get_language_info_list for LANGUAGES as languages %}
            {% for language in languages %}
              <option value="{{ language.code }}"{% if language.code == LANGUAGE_CODE %} selected{% endif %}>
                {{ language.name_local }} ({{ language.code }})
              </option>
            {% endfor %}
          </select>
          <input type="submit" id="submit_btn" hidden value="Go">
        </form> 
      </div>
      {% if request.user.is_authenticated %}
        <div class="action_cart">
          <div class="action_cart_title">Cart <span class="cart_count">{{ request.user.cart_count }}</span></div>
        </div>
        <div class="action-logout"><a href="{% url 'logout' %}?next={{ request.path }}">Logout</a></div>
      {% else %}
        <div class="action-login"><a href="{% url 'login' %}">Login</a></div>
      {% endif %}
    </div>
  </div>
</div>
HTML

# ===== #
cat <<HTML >templates/home.html
{% extends 'base.html' %}
{% load i18n %}
{% block title %} {% translate 'HOME_TITLE' %} {% endblock %}
{% block content %}
<div class="categories_container">
  <div class="categories_root">
    <div class="category_header_root">
      <div class="category_title">Categories</div>
      <div></div>
      <a class="category_see_all" href="">See all</a>
    </div>
    <div class="category_list_container">
      <div class="category_list_root" id="category_list_root">
        {% for category in categories %}
        <div class="category_detail_container">
          <a class="category_detail_root" href="{% url 'home' %}?category={{category.id}}">
            <div class="category_img_container">
              <img src="{{category.image.url}}" alt="{{category.name}}">
            </div>
            <div>{{category.name}}</div>
        </a>
        </div>
        {% endfor %}
      </div>
    </div>
  </div>
</div>

<script>
  let resizeTimer;

  window.addEventListener('resize', function () {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(hideOverflowedItems, 10);
  });

  function hideOverflowedItems() {
    const container = document.getElementById('category_list_root');
    const items = container.querySelectorAll('.category_detail_container');
    
    let totalWidth = 0;
    let visibleItems = 0;
    let offsetWidth = items[0].offsetWidth
    
    items.forEach((item) => {
      totalWidth += offsetWidth;
      if (totalWidth <= container.clientWidth) {
        visibleItems++;
      }
    });

    items.forEach((item, index) => {
      item.style.display = index < visibleItems ? 'grid' : 'none';
    });
  }
  hideOverflowedItems();
</script>

<div class="product_container">
  <div class="product_root">
    <div class="product_header_root">
      <div class="product_title">Products</div>
      <div></div>
      <a class="product_see_all" href="">See all</a>
    </div>
    <div class="product_content_container">
      <div class="product_content_root">
        <div class="product_filter_title_root">
          <div class="sort_by_title_container">Sort By</div>
          <div class="sort_by_content_container">
            <form action="#" method="get">
              <label><input type="radio" name="options" value="price">Price</label>
              <label><input type="radio" name="options" value="date">Date</label>
              <label><input type="radio" name="options" value="popular">Popular</label>
              <label><input type="radio" name="options_sort" value="asc">Asc</label>
              <label><input type="radio" name="options_sort" value="desc">Desc</label>
              <input type="submit" value="Sort">
            </form>
          </div>
          <div class="advance_search_title">Advance Search</div>
        </div>
        <div class="product_filter_container">
          Lorem
        </div>
        <div class="product_list_container">
          {% for product in products %}
          <div class="product">
            <img src="{{ product.image }}" alt="{{ product.name}}">
              <div class="product-info">
                <div class="pri-info">
                  <h3>{{ product.name}}</h3>
                  <p class="price">$ {{ product.price }}</p>
                </div>
                  <div class="sec-info">
                    <p>Type: {{ product.category.name }}</p>
                    <!-- <p> {{ product.short_description }} </p> -->
                  </div>
              </div>
              <div class="action-container">
                  <table>
                      <tbody>
                          <tr>
                              <td style="width: 50%;"><a href=""><button class="btn-buy-action">Detail</button></a></td>
                              <td><a href="{% url 'add_to_cart' product.id %}"><button class="btn-buy-action">Add To Cart</button></a></td>
                          </tr>
                          <tr>
                              <td colspan="2"><a href="{% url 'add_to_cart' product.id %}"><button class="btn-buy-action">Buy</button></a></td>
                          </tr>
                      </tbody>
                  </table>
              </div>
          </div>
          {% endfor %}
        </div>
      </div>
    </div>
  </div>
</div>
{% endblock %}
HTML

# ===== #
cat <<HTML >templates/login.html
{% load static %}
{% load i18n %}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% translate 'LOGIN_TITLE' %}</title>
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            background-color: white;
        }
        .login-container {
            border: 1px solid #000;
            width: 300px;
            padding: 20px;
            background-color: #fff;
        }
        .logo {
            border: 1px solid #000;
            height: 50px;
            line-height: 50px;
            font-size: xx-large;
            text-align: center;
            margin: auto auto 20px auto;
            width: 50%;
        }

        table {
            width: 100%;
            text-align: center;
        }

        table, th, td, tr {
            border: 1px solid #000;
            border-collapse: collapse;
        }

        td input {
            all: unset;
            height: 30px;
            line-height: 30px;
        }

        .link-row{
            text-decoration: none;
            border: 1px solid #000;
            display: flex;
            justify-content: space-between;
            padding: 5px;
            margin-top: 1rem;
        }

        .link-row a{
            text-decoration: none;
            color: #000;
        }

        button {
            width: 100%;
            padding: 10px;
            border: none;
            border-radius: 0;
            cursor: pointer;
            background-color: #fff;
            border: 1px solid #000;
            border-top: none;
        }

    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">Logo</div>
        <form method="post"> {% csrf_token %}
            <table>
                <tbody>
                    <tr>
                        <td><label for="username">Username:</label></td>
                        <td><input type="text" id="username" name="username" placeholder="Enter your username"></td>
                    </tr>
                    <tr>
                        <td><label for="password">Password:</label></td>
                        <td><input type="password" id="password" name="password" placeholder="Enter your password"></td>
                    </tr>
                </tbody>
            </table>
            <button type="submit">Login</button>
            <div class="link-row">
                <div class="forgot-password">
                    <a href="#">Forgot Password?</a>
                </div>
                <div class="register">
                    <a href="#">Register</a>
                </div>
            </div>
        </form>
    </div>
</body>
</html>
HTML

# ===== #
mkdir staticfiles/css
cat <<text >staticfiles/css/main.css
@import url('https://fonts.googleapis.com/css2?family=Saira:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap');

html {
  margin: 3px;
  padding: 0;
  /* width: 500px; */
  box-sizing: border-box;
}

body {
  font-family: 'Saira', sans-serif;
  background-color: white;
  border: 2px solid black;
  font-size: 10px;
}

a {
  all: unset;
  cursor: pointer;
}

img {
  width: 50px;
  height: 50px;
}

.app_root {
  
}
.app_root>div:not(:first-child),
.app_root>a:not(:first-child) {
  border-top: 1px solid black;
}

.header_root {
  height: 25px;
  display: grid;
  grid-template-columns: 30px auto 120px;
}
.header_root>div:not(:first-child),
.header_root>a:not(:first-child) {
  border-left: 1px solid black;
}

.header_root_authenticated {
  height: 25px;
  display: grid;
  grid-template-columns: 30px auto 260px;
}
.header_root_authenticated>div:not(:first-child),
.header_root_authenticated>a:not(:first-child) {
  border-left: 1px solid black;
}

.logo_container {
  display: grid;
  place-items: center;
}

.search_container {
  display: grid;
  place-items: center;
}

.search_root {
  display: grid;
  grid-template-columns: auto 50px;
  width: 95%;
  height: 80%;
  border: 1px solid black;
}
.search_root>div:not(:first-child),
.search_root>a:not(:first-child) {
  border-left: 1px solid black;
}

.search_root input {
  all: unset;
  padding: 0 2px;
}

.button_search {
  display: grid;
  place-items: center;
}

.action_container {
  display: grid;
  place-items: center;
}

.action_root {
  width: 95%;
  height: 80%;
  border: 1px solid black;
  display: grid;
  grid-template-columns: auto 40px;
}
.action_root>div:not(:first-child),
.action_root>a:not(:first-child) {
  border-left: 1px solid black;
}

.action_root_authenticated {
  width: 95%;
  height: 80%;
  border: 1px solid black;
  display: grid;
  grid-template-columns: auto auto 40px 40px;
}
.action_root_authenticated>div:not(:first-child),
.action_root_authenticated>a:not(:first-child) {
  border-left: 1px solid black;
}

.become_seller {
  display: grid;
  place-items: center;
}

.language {
  display: grid;
  place-items: center;
}

.language select {
  all: unset;
  border: 1px solid black;
  padding-left: 2px;
}

.action_cart {
  display: grid;
  place-items: center;
}

.cart_count {
  color: red;
}

.action-logout {
  display: grid;
  place-items: center;
}

.action-login {
  display: grid;
  place-items: center;
}

.categories_container {
  display: grid;
  place-items: center;
}

.categories_root {
  width: 99%;
  margin: 2px 0;
  border: 1px solid black;
}
.categories_root>div:not(:first-child),
.categories_root>a:not(:first-child) {
  border-top: 1px solid black;
}

.category_header_root {
  display: grid;
  grid-template-columns: 75px auto 50px;
}
.category_header_root>div:not(:first-child),
.category_header_root>a:not(:first-child) {
  border-left: 1px solid black;
}

.category_title {
  display: grid;
  place-items: center;
}

.category_see_all {
  display: grid;
  place-items: center;
}

.category_list_container {
  display: grid;
  place-items: center;
}

.category_list_root {
  width: 98%;
  margin: 2px 0;
  display: grid;
  grid-template-columns: repeat(auto-fit, 100px);
  grid-auto-flow: column;
  overflow: hidden;
  justify-content: space-between;
}
.category_list_root>div:not(:first-child),
.category_list_root>a:not(:first-child) {
  /* border-left: 1px solid black; */
}

.category_detail_container {
  display: grid;
  place-items: center;
}

.category_detail_root {
  width: 80%;
  border: 1px solid black;
  margin: 2px 0;
}
.category_detail_root>div:not(:first-child),
.category_detail_root>a:not(:first-child),
.category_detail_root>p:not(:first-child) {
  border-top: 1px solid black;
}

.category_img_container {
  display: grid;
  place-items: center;
}

.category_img_container img {
  width: 75px;
  height: 75px;
}

.product_container {
  display: grid;
  place-items: center;
}

.product_root {
  width: 99%;
  margin: 2px 0;
  border: 1px solid black;
}
.product_root>div:not(:first-child),
.product_root>a:not(:first-child) {
  border-top: 1px solid black;
}

.product_header_root {
  display: grid;
  grid-template-columns: 75px auto 50px;
}
.product_header_root>div:not(:first-child),
.product_header_root>a:not(:first-child) {
  border-left: 1px solid black;
}

.product_title {
  display: grid;
  place-items: center;
}

.product_see_all {
  display: grid;
  place-items: center;
}

.product_content_container {
  display: grid;
  place-items: center;
}

.product_content_root {
  width: 97%;
  margin: 5px 0;
  border: 1px solid black;
}
.product_content_root>div:not(:first-child),
.product_content_root>a:not(:first-child) {
  border-top: 1px solid black;
}

.product_filter_title_root {
  display: grid;
  grid-template-columns: 50px auto 80px;
}
.product_filter_title_root>div:not(:first-child),
.product_filter_title_root>a:not(:first-child) {
  border-left: 1px solid black;
}
text

# ===== #
mkdir staticfiles/js
cat <<text >staticfiles/js/main.js
var languageSelection = document.getElementById('language_selection');
var submitBtn = document.getElementById('submit_btn');

languageSelection.addEventListener('change', function () {
    submitBtn.click();
});
text

################################################## == Makefile
# ===== #
echo "[INFO] - makefile.build"
cat <<text >makefile
all:
	rm -fr migrations
	rm -fr db.sqlite3
	python3 manage.py makemigrations core authentication ecommerce
	python3 manage.py migrate
	python3 manage.py shell -c "from django.contrib.auth import get_user_model; get_user_model().objects.filter(username='admin').exists() or get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin')"
	python3 manage.py runserver 2000
server:
	python3 manage.py runserver 2000
clear:
	find . -mindepth 1 -not -name 'build.sh' -delete
text

################################################## == Migrate
# ===== #
echo "[INFO] - collectstatic"
python3 manage.py collectstatic --no-input
echo "[INFO] - migrate"
python3 manage.py makemigrations core authentication ecommerce
python3 manage.py migrate
echo "[INFO] - superuser.create"
python3 manage.py shell -c "from django.contrib.auth import get_user_model; get_user_model().objects.filter(username='admin').exists() or get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin');"
