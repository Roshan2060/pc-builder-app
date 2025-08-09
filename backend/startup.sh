#!/bin/bash
echo "PC Builder...."

echo "Running database migrations..."
python manage.py migrate --no-input

echo "Collecting static files..."
python manage.py collectstatic --no-input

echo "Creating superuser if needed..."
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='admin').exists() or User.objects.create_superuser('admin', 'pc@gmail.com', 'pc123')" | python manage.py shell

echo "Starting Gunicorn server..."
echo "Server will be available at the assigned URL"
# ...existing code...
gunicorn config.wsgi:application --bind 0.0.0.0:8000 --log-file -
# ...existing code...
