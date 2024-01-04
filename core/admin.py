from django.contrib import admin
from django.apps import apps
from django.contrib.admin.sites import AlreadyRegistered
from django.contrib.auth.admin import UserAdmin

from core.models import User


class UserAdmin(UserAdmin):
    fieldsets = (
        (None, {
            'fields': ('username', 'password', 'fullname', 'email', 'avatar', 'address', 'is_seller', 'groups')
        }),
        ('Advance options', {
            'classes': ('collapse',), 
            'fields': ('user_permissions', 'is_active', 'is_staff', 'is_superuser')
        }),
    )
    list_display = ('username', 'email', 'date_joined')
    list_filter = ('is_staff', 'is_active')
    search_fields = ('fullname__startswith',)

    class Meta:
        ordering = ('date_joined',)
admin.site.register(User, UserAdmin)
apps.get_model('auth.Group')._meta.app_label = 'core'

for model in apps.get_app_config('core').get_models():
    try: admin.site.register(model)
    except AlreadyRegistered: pass


