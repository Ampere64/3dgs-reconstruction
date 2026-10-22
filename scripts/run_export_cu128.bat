@echo off
REM Export formal splatfacto model to browser-viewable .ply (ns_cu128 / CUDA 12.8)
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64 -vcvars_ver=14.33.31629
set CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8
set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8
set "PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8\bin;%PATH%"
set TORCH_CUDA_ARCH_LIST=8.9
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
echo Exporting gaussian splat to PLY ...
"C:\Users\amper\anaconda3\envs\ns_cu128\Scripts\ns-export.exe" gaussian-splat ^
  --load-config "C:\Users\amper\Desktop\Code X\Graduation project\outputs\nerfstudio_data\splatfacto\2026-09-08_124052\config.yml" ^
  --output-dir "C:\Users\amper\Desktop\Code X\Graduation project\outputs\export_run2" ^
  --output-filename splat.ply
echo exit code: %errorlevel%
pause
