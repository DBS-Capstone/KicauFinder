FROM python:3.11.13-slim

# Install dependencies untuk audio
RUN apt-get update && apt-get install -y ffmpeg && apt-get clean

# Copy requirements dan install
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Atur direktori kerja
WORKDIR /app

# Copy semua isi folder dashboard ke /app
COPY kicau_model.h5 .
COPY app.py .

# Jalankan streamlit dan bind ke semua interface
CMD ["streamlit", "run", "app.py", "--server.address=0.0.0.0"]
