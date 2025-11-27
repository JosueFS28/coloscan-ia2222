import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, regularizers
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint
import matplotlib.pyplot as plt
import json
from datetime import datetime

# ==================== CONFIGURACIÓN CORREGIDA ====================
DATASET_PATH = "./kvasir_prepared"
MODEL_OUTPUT_PATH = "../backend/trained_model"
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 16  # ← Reducido para mejor aprendizaje
EPOCHS = 100     # ← Aumentado
LEARNING_RATE = 0.0005  # ← Aumentado (era muy bajo)

# ==================== MODELO SIMPLIFICADO Y EFECTIVO ====================

def create_model_v2():
    """
    Modelo más simple pero efectivo
    """
    print("🏗️  Creando modelo optimizado...")
    
    # MobileNetV2 (más rápido y funciona mejor con datasets médicos)
    base_model = keras.applications.MobileNetV2(
        input_shape=(*IMAGE_SIZE, 3),
        include_top=False,
        weights='imagenet'
    )
    
    # Descongelar solo las últimas 20 capas
    base_model.trainable = True
    for layer in base_model.layers[:-20]:
        layer.trainable = False
    
    # Arquitectura más simple
    model = keras.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.BatchNormalization(),
        
        layers.Dense(256, activation='relu'),
        layers.Dropout(0.5),
        
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.3),
        
        layers.Dense(1, activation='sigmoid')
    ])
    
    # Compilar
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=LEARNING_RATE),
        loss='binary_crossentropy',
        metrics=['accuracy', keras.metrics.Precision(), keras.metrics.Recall()]
    )
    
    print("✅ Modelo creado!")
    return model

# ==================== DATA GENERATORS ====================

def create_generators():
    """
    Generadores de datos
    """
    print("\n📊 Creando generadores...")
    
    # Augmentation MODERADO (no tan agresivo)
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=20,
        width_shift_range=0.2,
        height_shift_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='nearest'
    )
    
    test_datagen = ImageDataGenerator(rescale=1./255)
    
    train_gen = train_datagen.flow_from_directory(
        os.path.join(DATASET_PATH, "train"),
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='binary',
        shuffle=True
    )
    
    test_gen = test_datagen.flow_from_directory(
        os.path.join(DATASET_PATH, "test"),
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='binary',
        shuffle=False
    )
    
    print(f"✅ Train: {train_gen.samples} imágenes")
    print(f"✅ Test: {test_gen.samples} imágenes")
    print(f"🏷️  Mapeo: {train_gen.class_indices}")
    
    # Class weights
    total = train_gen.samples
    class_counts = {}
    for class_name, class_idx in train_gen.class_indices.items():
        count = len([f for f in os.listdir(os.path.join(DATASET_PATH, "train", class_name))])
        class_counts[class_idx] = count
    
    class_weight = {
        idx: total / (len(class_counts) * count)
        for idx, count in class_counts.items()
    }
    
    print(f"⚖️  Class weights: {class_weight}")
    
    return train_gen, test_gen, class_weight

# ==================== ENTRENAR ====================

def train_model_v2(model, train_gen, test_gen, class_weight):
    """
    Entrenamiento con callbacks ajustados
    """
    print("\n🚀 Iniciando entrenamiento...")
    
    os.makedirs(MODEL_OUTPUT_PATH, exist_ok=True)
    
    callbacks = [
        EarlyStopping(
            monitor='val_accuracy',  # ← Cambiado a accuracy
            patience=20,  # ← Más tolerante
            restore_best_weights=True,
            mode='max',
            verbose=1
        ),
        ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=7,
            min_lr=1e-7,
            verbose=1
        ),
        ModelCheckpoint(
            os.path.join(MODEL_OUTPUT_PATH, 'best_checkpoint.h5'),
            monitor='val_accuracy',
            save_best_only=True,
            mode='max',
            verbose=1
        )
    ]
    
    history = model.fit(
        train_gen,
        epochs=EPOCHS,
        validation_data=test_gen,
        callbacks=callbacks,
        class_weight=class_weight,
        verbose=1
    )
    
    return history

# ==================== EVALUAR ====================

def evaluate_model_v2(model, test_gen):
    """
    Evaluación
    """
    print("\n📊 Evaluando modelo...")
    
    results = model.evaluate(test_gen, verbose=1)
    
    print(f"\n✅ Resultados:")
    print(f"   Loss:      {results[0]:.4f}")
    print(f"   Accuracy:  {results[1]*100:.2f}%")
    print(f"   Precision: {results[2]:.4f}")
    print(f"   Recall:    {results[3]:.4f}")
    
    # Predicciones
    test_gen.reset()
    predictions = model.predict(test_gen, verbose=1)
    y_pred = (predictions > 0.5).astype(int).flatten()
    y_true = test_gen.classes
    
    # Matriz de confusión
    from sklearn.metrics import classification_report, confusion_matrix
    
    class_labels = {v: k for k, v in test_gen.class_indices.items()}
    target_names = [class_labels[i] for i in sorted(class_labels.keys())]
    
    print("\n📋 Reporte:")
    print(classification_report(y_true, y_pred, target_names=target_names))
    
    print("\n🔢 Matriz de Confusión:")
    cm = confusion_matrix(y_true, y_pred)
    print(cm)
    
    return {
        'accuracy': results[1],
        'precision': results[2],
        'recall': results[3]
    }

# ==================== GUARDAR ====================

def save_model_v2(model, train_gen, metrics):
    """
    Guardar modelo
    """
    print("\n💾 Guardando...")
    
    # Guardar modelo
    model_path = os.path.join(MODEL_OUTPUT_PATH, "cancer_model.h5")
    model.save(model_path)
    print(f"✅ {model_path}")
    
    # Guardar labels
    class_labels = {v: k for k, v in train_gen.class_indices.items()}
    labels_path = os.path.join(MODEL_OUTPUT_PATH, "class_labels.json")
    with open(labels_path, 'w') as f:
        json.dump(class_labels, f)
    print(f"✅ {labels_path}")

# ==================== GRÁFICOS ====================

def plot_history(history):
    """
    Gráficos
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))
    
    # Accuracy
    ax1.plot(history.history['accuracy'], label='Train')
    ax1.plot(history.history['val_accuracy'], label='Val')
    ax1.set_title('Accuracy')
    ax1.set_xlabel('Epoch')
    ax1.legend()
    ax1.grid(True)
    
    # Loss
    ax2.plot(history.history['loss'], label='Train')
    ax2.plot(history.history['val_loss'], label='Val')
    ax2.set_title('Loss')
    ax2.set_xlabel('Epoch')
    ax2.legend()
    ax2.grid(True)
    
    plt.tight_layout()
    plt.savefig('training_v2.png', dpi=300)
    print("✅ Gráfico guardado: training_v2.png")
    plt.show()

# ==================== MAIN ====================

def main():
    print("=" * 70)
    print("🚀 ENTRENAMIENTO V2 - OPTIMIZADO")
    print("=" * 70)
    
    model = create_model_v2()
    train_gen, test_gen, class_weight = create_generators()
    history = train_model_v2(model, train_gen, test_gen, class_weight)
    metrics = evaluate_model_v2(model, test_gen)
    save_model_v2(model, train_gen, metrics)
    plot_history(history)
    
    print("\n" + "=" * 70)
    print("✅ COMPLETADO")
    print("=" * 70)
    print(f"\n🎯 Accuracy: {metrics['accuracy']*100:.2f}%")

if __name__ == "__main__":
    main()