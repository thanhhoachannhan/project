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