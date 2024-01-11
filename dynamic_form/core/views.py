from django.shortcuts import render

from .models import *
from .forms import *


def index(request):
    return render(request, 'index.html', {
        'form': ContactForm(),
        'contacts': Contact.objects.all(),
    })

def create_contact(request):
    if request.method == 'POST':
        form = ContactForm(request.POST or None)
        if form.is_valid():
            contact = form.save()
            return render(request, 'part/contact.html', {
                'contact': contact,
            })
    return render(request, 'part/form.html', {
        'form': ContactForm(),
    })

