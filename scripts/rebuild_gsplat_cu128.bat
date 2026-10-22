@echo off
REM Compile gsplat in ns_cu128 with CUDA 12.8 + cl 19.33
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64 -vcvars_ver=14.33.31629
set CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8
set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8
set "PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8\bin;%PATH%"
set TORCH_CUDA_ARCH_LIST=8.9
echo Triggering gsplat JIT compile (ns_cu128 / cu128) ...
"C:\Users\amper\anaconda3\envs\ns_cu128\python.exe" -c "from gsplat.cuda._backend import _C; print('JIT_OK', _C)" > cu128_compile_log.txt 2>&1
echo exit code: %errorlevel%
pause
