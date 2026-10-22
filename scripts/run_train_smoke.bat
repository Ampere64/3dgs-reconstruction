@echo off
REM ============================================================
REM Level-1: Splatfacto 5000-iteration smoke training
REM Usage : .\scripts\run_train_smoke.bat
REM Loads MSVC 14.33 (cl 19.33, accepted by CUDA 11.8) + CUDA 11.8
REM NOTE  : ASCII only - cmd parses in GBK codepage.
REM ============================================================

REM 1. Load MSVC 14.33 toolset so cl 19.33 (nvcc-11.8-compatible) is on PATH
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64 -vcvars_ver=14.33.31629
if errorlevel 1 goto :error

REM 2. Point CUDA to v11.8 (matches torch 2.7.1+cu118) and put its nvcc first
set CUDA_HOME=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8
set "PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8\bin;%PATH%"

REM 3. Compile only for RTX 4060 (Ada, sm_89)
set TORCH_CUDA_ARCH_LIST=8.9

REM 4. Verify cl and nvcc
where cl >nul 2>&1
if errorlevel 1 goto :nocl
where nvcc >nul 2>&1
if errorlevel 1 goto :nonvcc
for /f "delims=" %%v in ('nvcc --version ^| findstr /i release') do echo [OK] %%v

echo [..] Starting Splatfacto smoke training (5000 iters)...
echo [..] First run compiles gsplat CUDA kernels: expect 10-40 min.

REM 5. Train
"C:\Users\amper\anaconda3\envs\ns_try\Scripts\ns-train.exe" splatfacto ^
  --data "C:\Users\amper\Desktop\Code X\Graduation project\nerfstudio_data" ^
  --output-dir "C:\Users\amper\Desktop\Code X\Graduation project\outputs" ^
  --max-num-iterations 5000
goto :end

:nocl
echo [ERROR] cl.exe NOT found. MSVC 14.33 toolset missing.
goto :end
:nonvcc
echo [ERROR] nvcc.exe NOT found. CUDA v11.8 toolkit may be missing.
goto :end
:error
echo [ERROR] vcvarsall.bat failed to initialize MSVC 14.33 environment.
goto :end

:end
pause
