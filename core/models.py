from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, UserManager
from django.contrib.auth.validators import UnicodeUsernameValidator
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

class User(AbstractBaseUser, PermissionsMixin):
    username = models.CharField(_('username'), max_length=100, unique=True, validators=[UnicodeUsernameValidator()])
    fullname = models.CharField(_('fullname'), max_length=100)
    email = models.EmailField(_('email'))
    avatar = models.ImageField(_('avatar'), upload_to='avatar', default='avatar')
    address = models.TextField(_('address'))
    is_seller = models.BooleanField(_('is_seller'), default=False)
    is_staff = models.BooleanField(_('is_staff'), default=False)
    is_active = models.BooleanField(_('is_active'), default=True)
    date_joined = models.DateTimeField(_('date_joined'), default=timezone.now)

    objects = UserManager()

    EMAIL_FIELD = 'email'
    USERNAME_FIELD = 'username'
    # REQUIRED_FIELD = ['email']

    def __str__(self):
        return f'User: {self.fullname}(username)'

    class Meta:
        verbose_name = _('user')
        verbose_name_plural = _('users')

