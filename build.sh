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
