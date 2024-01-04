sudo apt-get update -y
sudo apt-get install python3-pip -y
pip install --upgrade pip
pip install django==5.0
pip install pillow==10.0
pip install gunicorn==20.0

export PATH="$PATH:/home/thanh/.local/bin"
source ~/.bashrc

django-admin startproject project .
python3 manage.py startapp core

echo "import os
DEBUG=True
ALLOWED_HOST=['*']
INSTALLED_APPS += ['core']
AUTH_PASSWORD_VALIDATORS = []
MEDIA_URL = '/uploads/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'uploads')
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATICFILES_DIRS = [os.path.join(BASE_DIR, 'staticfiles')]
" >> project/settings.py

python3 manage.py makemigrations core
python3 manage.py migrate
python3 manage.py shell -c "from django.contrib.auth import get_user_model;
get_user_model().objects.filter(username='admin').exists() or get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin');"

mkdir ~/.ssh
cd ~/.ssh
ssh-keygen -t rsa -b 4096 -C "thanhhoachannnhan@gmail.com" -P ""
echo "Host github.com\n\tAddKeysToAgent yes\n\tIdentityFile ~/.ssh/id_rsa" > config
cd ~/


