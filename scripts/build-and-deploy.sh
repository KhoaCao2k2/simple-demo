#!/bin/bash

# Script đơn giản để build và deploy demo ArgoCD
# Sử dụng: ./scripts/build-and-deploy.sh

set -e

echo "🚀 Bắt đầu demo ArgoCD đơn giản"

# Bước 1: Build Docker image
echo "📦 Bước 1: Build Docker image..."
docker build -t simple-demo:latest .

echo "✅ Docker image đã được build thành công"

# Bước 2: Test image local
echo "🧪 Bước 2: Test image local..."
echo "Chạy container trong 5 giây để test..."
timeout 5s docker run --rm -p 8000:8000 simple-demo:latest || true

echo "✅ Image test hoàn thành"

# Bước 3: Tạo namespace
echo "📁 Bước 3: Tạo namespace..."
kubectl apply -f k8s/namespace.yaml

# Bước 4: Deploy Kubernetes manifests
echo "☸️ Bước 4: Deploy Kubernetes manifests..."
kubectl apply -f k8s/

# Bước 5: Chờ deployment ready
echo "⏳ Bước 5: Chờ deployment sẵn sàng..."
kubectl wait --for=condition=available --timeout=60s deployment/simple-demo -n argocd-demo

# Bước 6: Hiển thị thông tin
echo "📊 Bước 6: Thông tin deployment..."
echo ""
echo "=== PODS ==="
kubectl get pods -n argocd-demo

echo ""
echo "=== SERVICES ==="
kubectl get svc -n argocd-demo

echo ""
echo "=== DEPLOYMENTS ==="
kubectl get deployments -n argocd-demo

# Bước 7: Hướng dẫn test
echo ""
echo "🎉 Demo đã được deploy thành công!"
echo ""
echo "📋 Để test ứng dụng:"
echo "1. Port forward: kubectl port-forward -n argocd-demo svc/simple-demo-service 8000:80"
echo "2. Mở browser: http://localhost:8000"
echo "3. Test health: curl http://localhost:8000/health"
echo ""
echo "📋 Để deploy với ArgoCD:"
echo "1. Push code lên Git repository"
echo "2. Sửa repoURL trong argocd-app.yaml"
echo "3. Apply: kubectl apply -f argocd-app.yaml"
echo "4. Xem ArgoCD UI: kubectl port-forward -n argocd svc/argocd-server 8080:443"
