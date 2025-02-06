# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set environment variables
ENV PYTHONUNBUFFERED 1
ENV LANG C.UTF-8

# Set the working directory inside the container to /app
WORKDIR /LMS-app

# Install system dependencies for PostgreSQL, Redis, etc.
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    zlib1g-dev \
    curl && rm -rf /var/lib/apt/lists/*

# Install Uvicorn for ASGI support (you may want to add Uvicorn with standard extras)
RUN pip install "uvicorn[standard]"

# Copy requirements.txt and install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files into the container
COPY . /LMS-app/

# Apply database migrations and collect static files
RUN python manage.py makemigrations
RUN python manage.py migrate
RUN python manage.py collectstatic --noinput

# Expose the port for Django (8000)
EXPOSE 8000

# Command to run Uvicorn server (ASGI)
CMD ["uvicorn", "lms.asgi:application", "--host", "0.0.0.0", "--port", "8000"]
