import sys
import platform
import os

print(f"OS: {platform.system()} {platform.release()}")
print(f"Python: {sys.version}")

try:
    import torch
    print(f"PyTorch Version: {torch.__version__}")
    
    cuda_available = torch.cuda.is_available()
    print(f"CUDA Available: {cuda_available}")
    
    if cuda_available:
        print(f"Device Count: {torch.cuda.device_count()}")
        print(f"Current Device: {torch.cuda.current_device()}")
        print(f"Device Name: {torch.cuda.get_device_name(0)}")
    else:
        print("Running on CPU.")
        
except ImportError:
    print("PyTorch not installed.")
except Exception as e:
    print(f"An error occurred: {e}")
