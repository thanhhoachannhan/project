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