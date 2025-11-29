# Django Projesi: Docker, Portainer ve Nginx ile Dağıtım Rehberi

Bu proje, Django tabanlı bir web uygulamasının **Docker**, **Gunicorn** ve **Host Nginx** (Reverse Proxy) kullanılarak Linux bir sunucuda nasıl yayınlanacağını adım adım anlatır. Veritabanı olarak **SQLite** kullanılır ve veriler kalıcı (persistent) olarak saklanır.

## 🏗️ Mimari Yapısı

* **Django + Gunicorn:** Docker konteyneri içinde çalışır (Port 8000).
* **Host Nginx:** Sunucuda doğrudan çalışır. SSL sonlandırma, HTTP->HTTPS yönlendirme ve statik dosya sunumunu yapar.
* **SQLite:** Veritabanı dosyası sunucuda tutulur ve Docker'a mount edilir.
* **Portainer:** Docker konteynerini yönetmek için kullanılır.

---

## 🚀 Ön Hazırlıklar

Sunucuda aşağıdaki araçların kurulu olması gerekir:
* Docker & Docker Compose
* Nginx
* Portainer (Docker yönetimi için)

### 1. Klasör Yapısı ve İzinler
Projeyi `/root` yerine `/home` dizininde barındırıyoruz. Bu, Nginx izin hatalarını önler. (Bu "/home" klasörünün içerisinde "django_projects" adında bir alt klasör daha mevcut, biz rehbere bu şekilde devam edeceğiz)

```bash
# Gerekli boş dosyaları ve klasörleri oluştur (x kısmı projenin en ana klasörünün adını almalıdır).
cd /home/django_projects/x
touch db.sqlite3
mkdir -p staticfiles media templates

# NGINX'ih staticfiles dosyaları okuyabilmesi için izin ayarını yapalım
sudo chmod -R 755 /home/django_projects/test_com
```

### 2. "settings.py" Düzenlemeleri
Aşağıda verilen kısımların projenin `settings.py` dosyasının içerisinde olduğundan emin olalım.

```python
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

ALLOWED_HOSTS = ['armaganuzun.com', 'localhost', '127.0.0.1']

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Templates Klasörü
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'], # Ana templates klasörü
        'APP_DIRS': True,
        # ...
    },
]

# SSL ve Güvenlik
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
``` 
