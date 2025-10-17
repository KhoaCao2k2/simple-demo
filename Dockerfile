# Dockerfile đơn giản nhất
FROM python:3.11-slim

# Tạo thư mục làm việc
WORKDIR /app

# Copy requirements và cài đặt
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy code
COPY simple-app.py .

# Chạy ứng dụng
CMD ["python", "simple-app.py"]
