FROM python:3.11-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir flask catt

# Set working directory
WORKDIR /app
COPY app.py .

# Expose the Flask port
EXPOSE 5000

CMD ["python", "app.py"]