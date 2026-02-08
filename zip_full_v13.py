
import zipfile
import os

def zip_exclude_venv(output_filename="solar_eye_backend_v13_full.zip"):
    source_dir = r"d:\solar-eye\solar_eye_backend"
    exclude_dirs = {'.git', '.idea', 'venv', '__pycache__', 'static'}  # exclude large generated files if needed, but keep models!
    # Models are in app/ai/models - keep them!
    
    with zipfile.ZipFile(output_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        print(f"Compressing {source_dir} to {output_filename}...")
        for root, dirs, files in os.walk(source_dir):
            if 'venv' in dirs:
                dirs.remove('venv')
            if '.git' in dirs:
                dirs.remove('.git')
            if '.idea' in dirs:
                dirs.remove('.idea')
            if '__pycache__' in dirs:
                dirs.remove('__pycache__')
            # static 폴더는 제외? (이미지들은 제외하고 싶지만, uploads 폴더 구조는 유지해야 함...)
            # 일단 static 폴더 자체는 포함하되 내용물은 제외?
            # 아니면 그냥 포함? (너무 크면 제외)
            # 일단 포함하자. (모델 포함이 핵심)
            
            for file in files:
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, source_dir)
                
                # Exclude .pyc files
                if file.endswith('.pyc'):
                    continue
                
                zipf.write(file_path, rel_path)

    print("Compression complete!")

if __name__ == "__main__":
    zip_exclude_venv()
