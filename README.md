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
Projeyi `/root` yerine `/home` dizininde barındırıyoruz. Bu, Nginx izin hatalarını önler.

```bash
# Proje dizinini oluştur
mkdir -p /home/django_projects/test_com
cd /home/django_projects/test_com

# Gerekli boş dosyaları ve klasörleri oluştur
touch db.sqlite3
mkdir -p staticfiles media templates
```
