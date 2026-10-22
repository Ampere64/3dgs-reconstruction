@echo off
REM Splatfacto formal training (30000 iters) on ns_cu128 / CUDA 12.8
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64 -vcvars_ver=14.33.31629
set CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8
set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8
set "PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8\bin;%PATH%"
set TORCH_CUDA_ARCH_LIST=8.9
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
echo Starting Splatfacto formal training (30000 iters) on ns_cu128 ...
"C:\Users\amper\anaconda3\envs\ns_cu128\Scripts\ns-train.exe" splatfacto ^
  --data "C:\Users\amper\Desktop\Code X\Graduation project\nerfstudio_data" ^
  --output-dir "C:\Users\amper\Desktop\Code X\Graduation project\outputs" ^
  --max-num-iterations 30000 ^
  --steps-per-save 5000
pause
