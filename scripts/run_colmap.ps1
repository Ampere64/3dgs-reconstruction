$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$imagePath = Join-Path $projectRoot 'testphoto1'
$outputPath = Join-Path $projectRoot 'colmap_run_02'
$databasePath = Join-Path $outputPath 'database.db'
$sparsePath = Join-Path $outputPath 'sparse'
$colmapPath = 'C:\XIAZAI\colmap-x64-windows-cuda\bin\colmap.exe'

if (-not (Test-Path -LiteralPath $colmapPath)) {
    throw "COLMAP was not found at: $colmapPath"
}

if (-not (Test-Path -LiteralPath $imagePath)) {
    throw "Image directory was not found at: $imagePath"
}

if (Test-Path -LiteralPath $databasePath) {
    throw "An existing COLMAP database was found at: $databasePath. Move or remove it before rerunning this script."
}

New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
New-Item -ItemType Directory -Path $sparsePath -Force | Out-Null

# All images come from the same DJI camera. COLMAP will initialize its intrinsics from EXIF.
& $colmapPath feature_extractor `
    --database_path $databasePath `
    --image_path $imagePath `
    --ImageReader.single_camera 1 `
    --ImageReader.camera_model OPENCV `
    --FeatureExtraction.use_gpu 1

& $colmapPath exhaustive_matcher `
    --database_path $databasePath `
    --FeatureMatching.use_gpu 1

& $colmapPath mapper `
    --database_path $databasePath `
    --image_path $imagePath `
    --output_path $sparsePath

$models = Get-ChildItem -Path $sparsePath -Directory -ErrorAction SilentlyContinue
if (-not $models) {
    throw "COLMAP did not produce a sparse model. Review the command output for the failing stage."
}

Write-Host "COLMAP processing completed. Inspect the model under: $($models[0].FullName)"
