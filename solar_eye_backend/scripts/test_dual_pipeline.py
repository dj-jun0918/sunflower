"""
Solar Eye - Dual Pipeline Verification Script

이 스크립트는 변경된 AI 파이프라인(CCTV/Drone)이 정상 작동하는지 검증합니다.
실제 모델 로딩을 시도하므로, requirements.txt의 패키지들이 설치되어 있어야 합니다.
"""

import sys
import os
import cv2
import numpy as np
import logging
from pathlib import Path

# Add project root to path
sys.path.append(str(Path(__file__).parent.parent))

from app.ai.pipeline import get_pipeline

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_dummy_image(width=1920, height=1080):
    """테스트용 더미 이미지 생성 (검은 화면에 흰 사각형)"""
    img = np.zeros((height, width, 3), dtype=np.uint8)
    # 패널처럼 보이는 흰 사각형 추가
    cv2.rectangle(img, (500, 300), (900, 700), (255, 255, 255), -1)
    return img

def test_pipeline():
    print("🚀 AI 파이프라인 검증 시작...")
    
    try:
        # 1. 파이프라인 초기화
        # 모델 파일들이 존재하는지 먼저 확인
        models_dir = Path("app/ai/models")
        if not models_dir.exists():
             print(f"❌ '{models_dir}' 디렉토리를 찾을 수 없습니다. 실행 경로를 확인하세요.")
             return

        print("1. 파이프라인 초기화 중...")
        pipeline = get_pipeline()
        print("✅ 파이프라인 초기화 성공")
        
        # 2. 더미 이미지 준비
        image = create_dummy_image()
        print(f"2. 테스트 이미지 생성 완료 ({image.shape})")
        
        # 3. CCTV 모드 테스트
        print("\n[Test 1] CCTV 모드 실행 (YOLO -> Real-ESRGAN -> SegFormer)")
        try:
            results_cctv = pipeline.analyze(image, monitoring_type="cctv")
            print(f"✅ CCTV 분석 완료: {len(results_cctv)}개 패널 탐지됨")
            for i, res in enumerate(results_cctv):
                print(f"  - Panel {i+1}: {res.defect_type} ({res.class_confidence:.2f})")
        except Exception as e:
            print(f"❌ CCTV 모드 실패: {e}")
            import traceback
            traceback.print_exc()

        # 4. Drone 모드 테스트
        print("\n[Test 2] Drone 모드 실행 (YOLO -> Keras)")
        try:
            results_drone = pipeline.analyze(image, monitoring_type="drone")
            print(f"✅ Drone 분석 완료: {len(results_drone)}개 패널 탐지됨")
            for i, res in enumerate(results_drone):
                 print(f"  - Panel {i+1}: {res.defect_type} ({res.class_confidence:.2f})")
        except Exception as e:
            print(f"❌ Drone 모드 실패: {e}")
            import traceback
            traceback.print_exc()
            
    except ImportError as e:
        print(f"\n❌ 필수 라이브러리가 설치되지 않았습니다: {e}")
        print("requirements.txt를 설치하고 scripts/fix_basicsr.py를 실행했는지 확인해주세요.")
    except Exception as e:
        print(f"\n❌ 치명적 오류 발생: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_pipeline()
