# ColoScan IA - Detección de Cáncer de Colon

Sistema de detección de patologías en colonoscopía usando Redes Neuronales Convolucionales (CNN).

## 🎯 Características

- ✅ Clasificación multi-clase de imágenes de colonoscopía
- ✅ 7 tipos de diagnósticos
- ✅ Accuracy de 98%
- ✅ Backend con FastAPI
- ✅ Frontend con Flutter
- ✅ Base de datos MySQL

## 🏗️ Estructura del Proyecto
```
proyecto_colon_unfv/
├── backend/          # API REST con FastAPI
├── frontend/         # App móvil con Flutter
├── ml_training/      # Scripts de entrenamiento
└── dataset/          # Datasets (no incluido en repo)
```

## 📦 Instalación

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## 🚀 Deployment

Ver [DEPLOYMENT.md](DEPLOYMENT.md) para instrucciones detalladas.

## 👥 Autores

- Tu Nombre - Universidad Nacional Federico Villarreal

## 📄 Licencia

Proyecto de tesis - UNFV 2025