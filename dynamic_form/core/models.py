from django.db import models


class Contact(models.Model):
    name = models.CharField(max_length=128)
    phone = models.CharField(max_length=20)
    def __str__(self):
        return self.name
