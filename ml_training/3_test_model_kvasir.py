import os
import numpy as np
from PIL import Image
import tensorflow as tf
import json
from pathlib import Path
import random

# ==================== CONFIGURACIÓN ====================
MODEL_PATH = "../backend/trained_model/cancer_model.h5"
LABELS_PATH = "../backend/trained_model/class_labels.json"
TEST_PATH = "./kvasir_prepared/test"
IMAGE_SIZE = (224, 224)
NUM_SAMPLES = 10

# ==================== CARGAR MODELO ====================

def load_model():
    """Carga modelo y labels"""
    print("🔄 Cargando modelo...")
    model = tf.keras.models.load_model(MODEL_PATH)
    
    with open(LABELS_PATH, 'r') as f:
        class_labels = json.load(f)
    
    print("✅ Modelo cargado exitosamente!")
    return model, class_labels

# ==================== PREDECIR ====================

def predict_image(model, image_path, class_labels):
    """Hace predicción sobre una imagen"""
    # Cargar imagen
    img = Image.open(image_path).convert('RGB')
    img = img.resize(IMAGE_SIZE)
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    
    # Predecir
    prediction = model.predict(img_array, verbose=0)[0][0]
    
    # Interpretar
    if prediction > 0.5:
        label = class_labels['1']
        confidence = prediction
    else:
        label = class_labels['0']
        confidence = 1 - prediction
    
    return label, confidence

# ==================== PRUEBAS ====================

def test_model():
    """Prueba el modelo con imágenes aleatorias"""
    model, class_labels = load_model()
    
    print("\n" + "=" * 70)
    print("🧪 PROBANDO MODELO CON IMÁGENES ALEATORIAS")
    print("=" * 70)
    
    # Probar ambas clases
    for class_name in ['benigno', 'maligno']:
        class_path = os.path.join(TEST_PATH, class_name)
        images = list(Path(class_path).glob('*.jpg')) + list(Path(class_path).glob('*.png'))
        
        if len(images) == 0:
            print(f"\n⚠️ No se encontraron imágenes en {class_path}")
            continue
        
        # Seleccionar muestras aleatorias
        samples = random.sample(images, min(NUM_SAMPLES, len(images)))
        
        print(f"\n📂 Clase Real: {class_name.upper()}")
        print("-" * 70)
        
        correct = 0
        for img_path in samples:
            predicted_label, confidence = predict_image(model, str(img_path), class_labels)
            
            is_correct = predicted_label == class_name
            if is_correct:
                correct += 1
            
            status = "✅" if is_correct else "❌"
            print(f"{status} {img_path.name[:40]:40} → {predicted_label.upper():8} ({confidence*100:.1f}%)")
        
        accuracy = (correct / len(samples)) * 100
        print(f"\n   Accuracy en muestra: {accuracy:.1f}% ({correct}/{len(samples)})")

if __name__ == "__main__":
    test_model()