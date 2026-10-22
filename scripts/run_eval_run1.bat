@echo off
REM ns-eval on smoke splatfacto model (ns_cu128 / CUDA 12.8)
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64 -vcvars_ver=14.33.31629
set CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8
set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8
set "PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8\bin;%PATH%"
set TORCH_CUDA_ARCH_LIST=8.9
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
"C:\Users\amper\anaconda3\envs\ns_cu128\Scripts\ns-eval.exe" ^
  --load-config "C:\Users\amper\Desktop\Code X\Graduation project\outputs\nerfstudio_data\splatfacto\2026-09-08_091637\config.yml" ^
  --output-path "C:\Users\amper\Desktop\Code X\Graduation project\outputs\eval_run1\eval_results.json"
pause
