# 🚀 Hướng dẫn ArgoCD cho người mới bắt đầu

## 🤔 ArgoCD là gì?

**ArgoCD** là một công cụ **GitOps** giúp bạn:
- Tự động deploy ứng dụng từ Git repository lên Kubernetes
- Đồng bộ hóa giữa Git và Kubernetes cluster
- Quản lý ứng dụng thông qua giao diện web đẹp

## 🔄 GitOps là gì?

**GitOps** = **Git** + **Operations**
- **Git** là "single source of truth" (nguồn chân lý duy nhất)
- Mọi thay đổi đều được lưu trong Git
- ArgoCD tự động đồng bộ Git → Kubernetes

```
Git Repository → ArgoCD → Kubernetes Cluster
     ↑              ↓
   Thay đổi    Tự động sync
```

## 📁 Cấu trúc demo đơn giản

```
simple-demo/
├── simple-app.py          # Ứng dụng Python đơn giản
├── requirements.txt       # Dependencies
├── Dockerfile            # Build Docker image
├── k8s/                  # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── argocd-app.yaml       # ArgoCD Application
```

## 🎯 Demo này sẽ làm gì?

1. **Tạo ứng dụng Python đơn giản** (chỉ có 2 endpoints)
2. **Build Docker image**
3. **Tạo Kubernetes manifests**
4. **Deploy qua ArgoCD**
5. **Test ứng dụng**

## 📋 Yêu cầu

- ✅ ArgoCD đã chạy trên minikube
- ✅ kubectl
- ✅ Docker
- ✅ Git repository (GitHub/GitLab)

## 🚀 Bước 1: Tạo ứng dụng đơn giản

### 1.1 Ứng dụng Python
```python
# simple-app.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def hello():
    return {"message": "Xin chào! Đây là demo ArgoCD"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
```

### 1.2 Test ứng dụng local
```bash
cd simple-demo
pip install fastapi uvicorn
python simple-app.py
# Truy cập: http://localhost:8000
```

## 🐳 Bước 2: Build Docker image

### 2.1 Tạo Dockerfile
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY simple-app.py .
CMD ["python", "simple-app.py"]
```

### 2.2 Build image
```bash
docker build -t simple-demo:latest .
```

### 2.3 Test image
```bash
docker run -p 8000:8000 simple-demo:latest
```

## ☸️ Bước 3: Tạo Kubernetes manifests

### 3.1 Namespace
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: argocd-demo
```

### 3.2 Deployment
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-demo
  namespace: argocd-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: simple-demo
  template:
    metadata:
      labels:
        app: simple-demo
    spec:
      containers:
      - name: simple-demo
        image: simple-demo:latest
        ports:
        - containerPort: 8000
```

### 3.3 Service
```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: simple-demo-service
  namespace: argocd-demo
spec:
  selector:
    app: simple-demo
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
```

## 🔄 Bước 4: Deploy với ArgoCD

### 4.1 Tạo ArgoCD Application
```yaml
# argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: simple-demo-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-username/your-repo.git
    targetRevision: HEAD
    path: argocd/app/simple-demo/k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd-demo
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 4.2 Deploy ArgoCD Application
```bash
# Apply ArgoCD Application
kubectl apply -f argocd-app.yaml

# Check status
kubectl get applications -n argocd
```

## 🎉 Bước 5: Test và sử dụng

### 5.1 Kiểm tra ArgoCD UI
```bash
# Port forward ArgoCD UI
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Truy cập: https://localhost:8080
# Username: admin
# Password: (lấy từ secret)
```

### 5.2 Test ứng dụng
```bash
# Port forward ứng dụng
kubectl port-forward -n argocd-demo svc/simple-demo-service 8000:80

# Test endpoints
curl http://localhost:8000/
curl http://localhost:8000/health
```

## 🔄 GitOps Workflow

### Khi bạn thay đổi code:

1. **Sửa code** trong Git repository
2. **Commit và push** lên Git
3. **ArgoCD tự động detect** thay đổi
4. **ArgoCD tự động sync** lên Kubernetes
5. **Ứng dụng được update** mà không cần can thiệp thủ công

### Ví dụ thay đổi:
```python
# Sửa simple-app.py
@app.get("/")
async def hello():
    return {
        "message": "Xin chào! Đây là demo ArgoCD - VERSION 2.0",
        "version": "2.0.0"
    }
```

Sau khi push lên Git, ArgoCD sẽ tự động deploy version mới!

## 🎯 Lợi ích của ArgoCD

### ✅ So với deploy thủ công:
- **Tự động hóa**: Không cần `kubectl apply` thủ công
- **Đồng bộ**: Git là nguồn chân lý duy nhất
- **Rollback dễ dàng**: Chỉ cần revert Git commit
- **Audit trail**: Mọi thay đổi đều có lịch sử trong Git
- **UI đẹp**: Quản lý qua giao diện web

### ✅ So với CI/CD truyền thống:
- **Đơn giản hơn**: Không cần pipeline phức tạp
- **Nhanh hơn**: Deploy ngay khi có thay đổi
- **An toàn hơn**: Git là nguồn chân lý duy nhất

## 🚨 Troubleshooting

### Lỗi thường gặp:

1. **ArgoCD không sync**
   ```bash
   # Check ArgoCD logs
   kubectl logs -n argocd deployment/argocd-application-controller
   ```

2. **Image không tìm thấy**
   ```bash
   # Check image pull policy
   kubectl describe pod -n argocd-demo
   ```

3. **Namespace không tồn tại**
   ```bash
   # Tạo namespace
   kubectl create namespace argocd-demo
   ```

## 🎓 Bài tập thực hành

### Bài tập 1: Thay đổi message
1. Sửa message trong `simple-app.py`
2. Commit và push lên Git
3. Xem ArgoCD tự động sync
4. Test endpoint mới

### Bài tập 2: Thay đổi số replicas
1. Sửa `replicas: 2` trong `deployment.yaml`
2. Commit và push lên Git
3. Xem ArgoCD tạo thêm pod
4. Kiểm tra `kubectl get pods -n argocd-demo`

### Bài tập 3: Rollback
1. Tạo một commit có lỗi
2. Xem ArgoCD sync và fail
3. Rollback về commit trước
4. Xem ArgoCD tự động fix

## 🎉 Kết luận

ArgoCD giúp bạn:
- **Deploy tự động** từ Git
- **Quản lý dễ dàng** qua UI
- **Rollback nhanh chóng** khi có lỗi
- **Audit trail** đầy đủ

**GitOps** = **Git** + **Operations** = **Đơn giản** + **Mạnh mẽ**!

---

**Chúc bạn thành công với ArgoCD! 🚀**
