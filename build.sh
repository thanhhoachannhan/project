################################################## == Init
source ./init_project/0_build_env.sh
source ./init_project/1_init_project.sh
source ./init_project/2_code_file_manage.sh
source ./init_project/3_code_file_wsgi_and_asgi.sh
source ./init_project/4_code_file_settings.sh
source ./init_project/5_code_file_urls.sh
################################################## == Auth app
source ./app_authentication/0_init_app.sh
source ./app_authentication/1_code_file_models.sh
source ./app_authentication/2_code_file_admin.sh
source ./app_authentication/3_code_file_views.sh
source ./app_authentication/4_code_file_urls.sh
source ./app_authentication/5_code_templates.sh
################################################## == Core app
source ./app_core/0_init_app.sh
source ./app_core/1_code_file_models.sh
source ./app_core/2_code_file_admin.sh
source ./app_core/3_code_file_views.sh
source ./app_core/4_code_file_urls.sh
source ./app_core/5_code_templates.sh
################################################## == Ecommerce app
source ./app_ecommerce/0_init_app.sh
source ./app_ecommerce/1_code_file_models.sh
source ./app_ecommerce/2_code_file_admin.sh
source ./app_ecommerce/3_code_file_views.sh
source ./app_ecommerce/4_code_file_urls.sh
source ./app_ecommerce/5_code_templates.sh
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
python3 manage.py collectstatic --no-input > /dev/null 2>&1
echo "[INFO] - migrate"
python3 manage.py makemigrations core authentication ecommerce > /dev/null 2>&1
python3 manage.py migrate > /dev/null 2>&1
echo "[INFO] - superuser.create"
python3 manage.py shell -c "from django.contrib.auth import get_user_model; get_user_model().objects.filter(username='admin').exists() or get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin');"
