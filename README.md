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

# NGINX'in staticfiles dosyaları okuyabilmesi için izin ayarını yapalım
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
STATICFILES_DIRS = [
    BASE_DIR / 'static',
]

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

### 3. Docker İmaj Dosyasının Oluşturulması
`/home/django_projects/x` içerisindeyken aşağıdaki komutu çalıştıralım.

```bash
sudo docker build -t django-test:latest .
```


### 4. Portainer Üzerinde Compose Dosyasının Çalıştırılması
Proje dosyaları içerisinde yer alan `docker-compose.yml` içeriği Portainer üzerine yapıştırarak çalıştıralım.

### 5. NGINX İçerisinden Reverse Proxy Yapma
NOT: Cloudflare orgin SSL dosyalarımı daha önceden `/etc/nginx/ssl/armaganuzun.com.crt` içerisine yerleştirmiştim.

```bash
# Aşağıdaki komutu çalıştırıp komudun aşağısındaki kısmı kendimize göre düzenleyerek içerisine ekleyelim. (x.com yerine proje adı veya her hangi bir şey yazabilirsiniz)
sudo nano /etc/nginx/sites-available/x.com
```

```nginx
# HTTP -> HTTPS Yönlendirme
server {
    listen 80;
    server_name armaganuzun.com;
    return 301 https://$host$request_uri;
}

# HTTPS Blok
server {
    listen 443 ssl;
    server_name armaganuzun.com;

    ssl_certificate /etc/nginx/ssl/armaganuzun.com.crt;
    ssl_certificate_key /etc/nginx/ssl/armaganuzun.com.key;
    
    location = /favicon.ico { access_log off; log_not_found off; }

    # Statik Dosyalar (Nginx doğrudan sunar)
    location /static/ {
        alias /home/django_projects/test_com/staticfiles/;
        expires 30d;
    }

    # Medya Dosyaları
    location /media/ {
        alias /home/django_projects/test_com/media/;
    }

    # Ana Uygulama (Gunicorn'a yönlendir)
    location / {
        proxy_pass [http://127.0.0.1:8001](http://127.0.0.1:8001);
        # proxy_pass http://127.0.0.1:8001; şeklinde de olabilir.
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

```bash
# Enabled klasörüne kısayolu atalım. (x.com kısmına bu başlık altında koyulan adın aynısını yazalım).
sudo ln -s /etc/nginx/sites-available/x.com /etc/nginx/sites-enabled
# NGINX dosyalarını test ettirip, yeniden başlatalım.
sudo nginx -t
sudo systemctl restart nginx
```

