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