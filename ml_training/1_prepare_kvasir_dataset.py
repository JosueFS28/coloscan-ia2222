import os
import shutil
from pathlib import Path
import pandas as pd
from sklearn.model_selection import train_test_split

# ==================== CONFIGURACIÓN ====================
DATASET_PATH = "../nuevo_dataset"  # Cambia esto a tu ruta
OUTPUT_PATH = "./kvasir_prepared"
TEST_SIZE = 0.2
RANDOM_SEED = 42

# ==================== MAPEO DE CLASES ====================

BENIGNO_FOLDERS = [
    # Anatomía normal del colon
    'lower-gi-tract/anatomical-landmarks/cecum',
    'lower-gi-tract/anatomical-landmarks/ileum',
    'lower-gi-tract/anatomical-landmarks/retroflex-rectum',
    # Buena calidad de visualización
    'lower-gi-tract/quality-of-mucosal-views/bbps-2-3',
]

MALIGNO_FOLDERS = [
    # Patologías
    'lower-gi-tract/pathological-findings/hemorrhoids',
    'lower-gi-tract/pathological-findings/polyps',
    'lower-gi-tract/pathological-findings/ulcerative-colitis-grade-0',
    'lower-gi-tract/pathological-findings/ulcerative-colitis-grade-1',
    'lower-gi-tract/pathological-findings/ulcerative-colitis-grade-2',
    'lower-gi-tract/pathological-findings/ulcerative-colitis-grade-3',
    # Mala calidad (puede indicar problema)
    'lower-gi-tract/quality-of-mucosal-views/bbps-0-1',
    'lower-gi-tract/quality-of-mucosal-views/impacted-stool',
    # Intervenciones terapéuticas
    'lower-gi-tract/therapeutic-interventions/dyed-lifted-polyps',
    'lower-gi-tract/therapeutic-interventions/dyed-resection-margins',
]

# ==================== FUNCIONES ====================

def collect_images(base_path, folders_list):
    """Recolecta todas las imágenes de las carpetas especificadas"""
    images = []
    
    for folder in folders_list:
        full_path = os.path.join(base_path, folder)
        
        if not os.path.exists(full_path):
            print(f"⚠️ Carpeta no encontrada: {folder}")
            continue
        
        # Buscar imágenes
        for ext in ['*.jpg', '*.jpeg', '*.png']:
            images.extend(Path(full_path).glob(ext))
        
        count = len(list(Path(full_path).glob('*.*')))
        print(f"   📂 {folder}: {count} imágenes")
    
    return [str(img) for img in images]

def prepare_kvasir_dataset():
    """
    Prepara el dataset Kvasir para clasificación binaria
    """
    print("=" * 70)
    print("🔍 PREPARANDO DATASET KVASIR")
    print("=" * 70)
    
    # Verificar que el dataset existe
    if not os.path.exists(DATASET_PATH):
        print(f"❌ ERROR: Dataset no encontrado en {DATASET_PATH}")
        print("   Actualiza la variable DATASET_PATH con la ruta correcta")
        return
    
    # Recolectar imágenes
    print("\n📊 Recolectando imágenes BENIGNAS (colon sano):")
    benigno_images = collect_images(DATASET_PATH, BENIGNO_FOLDERS)
    
    print("\n📊 Recolectando imágenes MALIGNAS (colon con patología):")
    maligno_images = collect_images(DATASET_PATH, MALIGNO_FOLDERS)
    
    # Estadísticas
    total_benigno = len(benigno_images)
    total_maligno = len(maligno_images)
    total = total_benigno + total_maligno
    
    print("\n" + "=" * 70)
    print("📊 RESUMEN DEL DATASET")
    print("=" * 70)
    print(f"✅ Benigno (sano):     {total_benigno:>6} imágenes ({total_benigno/total*100:.1f}%)")
    print(f"❌ Maligno (patología): {total_maligno:>6} imágenes ({total_maligno/total*100:.1f}%)")
    print(f"📦 TOTAL:               {total:>6} imágenes")
    
    if total_benigno == 0 or total_maligno == 0:
        print("\n❌ ERROR: Una de las clases está vacía!")
        return
    
    # Calcular balance
    balance_ratio = min(total_benigno, total_maligno) / max(total_benigno, total_maligno)
    print(f"\n⚖️  Balance: {balance_ratio:.2%}")
    
    if balance_ratio < 0.3:
        print("   ⚠️ Dataset desbalanceado. Se aplicarán class weights durante entrenamiento")
    elif balance_ratio > 0.7:
        print("   ✅ Dataset bien balanceado")
    
    # Crear estructura de salida
    print("\n📦 Creando estructura de directorios...")
    
    if os.path.exists(OUTPUT_PATH):
        print(f"🗑️ Eliminando dataset anterior...")
        shutil.rmtree(OUTPUT_PATH)
    
    os.makedirs(OUTPUT_PATH, exist_ok=True)
    train_path = os.path.join(OUTPUT_PATH, "train")
    test_path = os.path.join(OUTPUT_PATH, "test")
    
    for split in [train_path, test_path]:
        os.makedirs(os.path.join(split, "benigno"), exist_ok=True)
        os.makedirs(os.path.join(split, "maligno"), exist_ok=True)
    
    # Split train/test
    print(f"\n🔀 Dividiendo dataset (train: {int((1-TEST_SIZE)*100)}%, test: {int(TEST_SIZE*100)}%)...")
    
    benigno_train, benigno_test = train_test_split(
        benigno_images, 
        test_size=TEST_SIZE, 
        random_state=RANDOM_SEED
    )
    
    maligno_train, maligno_test = train_test_split(
        maligno_images, 
        test_size=TEST_SIZE, 
        random_state=RANDOM_SEED
    )
    
    # Copiar archivos
    print("\n📋 Copiando archivos...")
    
    def copy_images(images, destination):
        for i, img_path in enumerate(images):
            if i % 100 == 0 and i > 0:
                print(f"   Copiadas: {i}/{len(images)}")
            
            filename = os.path.basename(img_path)
            # Agregar prefijo de carpeta original para evitar duplicados
            parent_folder = Path(img_path).parent.name
            new_filename = f"{parent_folder}_{filename}"
            dst = os.path.join(destination, new_filename)
            shutil.copy2(img_path, dst)
    
    print("   📁 Train - Benigno...")
    copy_images(benigno_train, os.path.join(train_path, "benigno"))
    
    print("   📁 Train - Maligno...")
    copy_images(maligno_train, os.path.join(train_path, "maligno"))
    
    print("   📁 Test - Benigno...")
    copy_images(benigno_test, os.path.join(test_path, "benigno"))
    
    print("   📁 Test - Maligno...")
    copy_images(maligno_test, os.path.join(test_path, "maligno"))
    
    # Resumen final
    train_ben = len(os.listdir(os.path.join(train_path, "benigno")))
    train_mal = len(os.listdir(os.path.join(train_path, "maligno")))
    test_ben = len(os.listdir(os.path.join(test_path, "benigno")))
    test_mal = len(os.listdir(os.path.join(test_path, "maligno")))
    
    print("\n" + "=" * 70)
    print("✅ DATASET PREPARADO EXITOSAMENTE")
    print("=" * 70)
    print(f"\n📊 TRAIN SET:")
    print(f"   Benigno: {train_ben:>5} imágenes ({train_ben/(train_ben+train_mal)*100:.1f}%)")
    print(f"   Maligno: {train_mal:>5} imágenes ({train_mal/(train_ben+train_mal)*100:.1f}%)")
    print(f"   Total:   {train_ben+train_mal:>5} imágenes")
    
    print(f"\n📊 TEST SET:")
    print(f"   Benigno: {test_ben:>5} imágenes ({test_ben/(test_ben+test_mal)*100:.1f}%)")
    print(f"   Maligno: {test_mal:>5} imágenes ({test_mal/(test_ben+test_mal)*100:.1f}%)")
    print(f"   Total:   {test_ben+test_mal:>5} imágenes")
    
    print(f"\n📁 Ubicación: {os.path.abspath(OUTPUT_PATH)}")
    print("\n🎯 Próximo paso: python 2_train_model_kvasir.py")
    
    # Guardar metadata
    metadata = {
        'total_images': total,
        'benigno': total_benigno,
        'maligno': total_maligno,
        'balance_ratio': balance_ratio,
        'train_split': 1 - TEST_SIZE,
        'test_split': TEST_SIZE
    }
    
    import json
    with open(os.path.join(OUTPUT_PATH, 'dataset_info.json'), 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print("📄 Metadata guardada en dataset_info.json")

if __name__ == "__main__":
    prepare_kvasir_dataset()