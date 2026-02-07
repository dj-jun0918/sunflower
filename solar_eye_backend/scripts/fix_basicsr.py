import os
import sys
import site
from pathlib import Path

def fix_basicsr():
    """
    Fix basicsr compatibility issue with newer torchvision
    Error: ImportError: cannot import name 'rgb_to_grayscale' from 'torchvision.transforms.functional_tensor'
    """
    print("Finding basicsr installation...")
    
    # site-packages 경로 탐색
    site_packages = site.getsitepackages()
    basicsr_path = None
    
    for sp in site_packages:
        possible_path = Path(sp) / "basicsr"
        if possible_path.exists():
            basicsr_path = possible_path
            break
            
    if not basicsr_path:
        # Try user site packages
        possible_path = Path(site.getusersitepackages()) / "basicsr"
        if possible_path.exists():
            basicsr_path = possible_path

    if not basicsr_path:
        print("❌ basicsr not found in site-packages.")
        return False

    print(f"Found basicsr at: {basicsr_path}")
    
    # Target file
    degradation_py = basicsr_path / "data" / "degradations.py"
    
    if not degradation_py.exists():
        print(f"❌ Target file not found: {degradation_py}")
        return False
        
    # Read and replace
    try:
        content = degradation_py.read_text(encoding='utf-8')
        
        old_import = "from torchvision.transforms.functional_tensor import rgb_to_grayscale"
        new_import = "from torchvision.transforms.functional import rgb_to_grayscale"
        
        if old_import in content:
            new_content = content.replace(old_import, new_import)
            degradation_py.write_text(new_content, encoding='utf-8')
            print(f"✅ patched {degradation_py}")
            return True
        elif new_import in content:
            print(f"ℹ️ already patched: {degradation_py}")
            return True
        else:
            print(f"⚠️ Import statement not found in {degradation_py}. It might be a different version.")
            return False
            
    except Exception as e:
        print(f"❌ Error patching file: {e}")
        return False

if __name__ == "__main__":
    fix_basicsr()
