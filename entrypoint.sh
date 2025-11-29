#!/bin/sh

echo "Migrasyonlar yapılıyor..."
python manage.py migrate

echo "Statik dosyalar toplanıyor..."
python manage.py collectstatic --no-input

echo "Gunicorn başlatılıyor..."

# x yerine kendi proje adımızı yazıyoruz.
gunicornx.wsgi:application --bind 0.0.0.0:8000
