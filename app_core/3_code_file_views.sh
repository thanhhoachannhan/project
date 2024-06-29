echo "[INFO] - core.views.build"
cat <<text >core/views.py
from django.shortcuts import render
from django.views import View


class Index(View):
    def get(self, request):
        return render(request, 'core/index.html')
text