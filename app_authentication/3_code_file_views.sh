echo "[INFO] - authentication.views.build"
cat <<text >authentication/views.py
from django.shortcuts import render, redirect
from django.contrib.auth import login, logout, authenticate
from django.urls import reverse
from django.views import View
from django.contrib.auth.mixins import LoginRequiredMixin


class Login(View):
    def get(self, request):
        if request.user.is_authenticated:
            return redirect(reverse('home'))
        return render(request, 'login.html')
    def post(self, request):
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            next_url = request.GET.get('next', 'home')
            return redirect(next_url)
        return render(request, 'login.html')

class Logout(LoginRequiredMixin, View):
    def get(self, request):
        logout(request)
        next_url = request.GET.get('next', '/')
        return redirect(next_url)
text