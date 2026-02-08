import zipfile
import os
import sys

# Windows에서 한글 출력 문제 해결
sys.stdout.reconfigure(encoding='utf-8')

BACKEND_DIR = r'd:\solar-eye\solar_eye_backend'
ZIP_PATH = r'd:\solar-eye\solar_eye_backend_v9.zip'

def create_zip():
    print(f"📦 압축 파일 생성 시작: {ZIP_PATH}")
    
    if os.path.exists(ZIP_PATH):
        try:
            os.remove(ZIP_PATH)
            print("Existing zip removed.")
        except PermissionError:
            print("⚠️ 기존 파일을 삭제할 수 없습니다. 덮어쓰기를 시도합니다.")

    with zipfile.ZipFile(ZIP_PATH, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(BACKEND_DIR):
            # .git, __pycache__, venv 폴더는 제외
            if '.git' in root or '__pycache__' in root or 'venv' in root or '.idea' in root:
                continue
                
            for file in files:
                if file.endswith('.pyc') or file.endswith('.DS_Store'):
                    continue
                    
                file_path = os.path.join(root, file)
                # zip 파일 내부 경로 (solar_eye_backend 폴더를 최상위로)
                arcname = os.path.relpath(file_path, BACKEND_DIR)
                
                print(f"  + 추가: {arcname}")
                zipf.write(file_path, arcname)
    
    print("\n✅ 압축 완료!")
    print(f"파일 위치: {ZIP_PATH}")
    
    # 검증
    print("\n🔍 내용물 확인 중...")
    with zipfile.ZipFile(ZIP_PATH, 'r') as zipf:
        file_list = zipf.namelist()
        if 'scripts/deploy_gpu.sh' in file_list:
            print("✅ scripts/deploy_gpu.sh 파일 확인됨 (성공)")
        else:
            print("❌ scripts/deploy_gpu.sh 파일이 없습니다! (실패)")

if __name__ == "__main__":
    create_zip()
