#!/bin/bash

# Script test ứng dụng đơn giản
# Sử dụng: ./scripts/test-app.sh

echo "🧪 Test ứng dụng ArgoCD Demo"

# Kiểm tra pods
echo "📋 Kiểm tra pods..."
kubectl get pods -n argocd-demo

echo ""
echo "📋 Kiểm tra services..."
kubectl get svc -n argocd-demo

echo ""
echo "🔗 Port forward để test..."
echo "Chạy lệnh sau để test:"
echo "kubectl port-forward -n argocd-demo svc/simple-demo-service 8000:80"
echo ""
echo "Sau đó mở browser: http://localhost:8000"
echo "Hoặc chạy: curl http://localhost:8000"
