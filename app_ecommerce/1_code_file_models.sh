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
