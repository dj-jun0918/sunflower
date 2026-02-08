# Solar Eye Backend - Cloud Run GPU Deployment Script (PowerShell)
# Usage: .\scripts\deploy_gpu.ps1 -ProjectId [PROJECT_ID] -Region [REGION]

param (
    [string]$ProjectId = "knu-team-01",
    [string]$Region = "us-central1"  # Default: Iowa (L4 GPU is widely available here)
)

$ServiceName = "solar-eye-backend"
$RepoName = "solar-eye-repo"
$ImageTag = "gcr.io/$ProjectId/$ServiceName`:latest"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Solar Eye Backend - Cloud Run GPU Deployment (Windows)" -ForegroundColor Cyan
Write-Host "========================================================"
Write-Host "Project ID: $ProjectId"
Write-Host "Region:     $Region"
Write-Host "Service:    $ServiceName"
Write-Host "GPU Type:   nvidia-l4"
Write-Host "========================================================"

if ([string]::IsNullOrWhiteSpace($ProjectId)) {
    Write-Error "Error: Project ID is not set. Please provide it via -ProjectId or set gcloud config."
    exit 1
}

# 1. Build Container Image
Write-Host "Rx Building container image..." -ForegroundColor Yellow
# Note: This will use .gcloudignore to include model files!
try {
    cmd /c "gcloud builds submit --tag $ImageTag ."
    if ($LASTEXITCODE -ne 0) { throw "Build failed" }
    Write-Host "✅ Build successful!" -ForegroundColor Green
}
catch {
    Write-Error "❌ Build failed!"
    exit 1
}

# 2. Deploy to Cloud Run
Write-Host "🚀 Deploying to Cloud Run..." -ForegroundColor Yellow

try {
    cmd /c "gcloud run deploy $ServiceName `
        --image $ImageTag `
        --region $Region `
        --platform managed `
        --allow-unauthenticated `
        --gpu 1 `
        --gpu-type nvidia-l4 `
        --memory 16Gi `
        --cpu 4 `
        --timeout 300 `
        --concurrency 1 `
        --execution-environment gen2 `
        --add-cloudsql-instances knu-team-01:us-central1:solar-eye-db `
        --set-env-vars APP_ENV=production,POSTGRES_HOST=/cloudsql/knu-team-01:us-central1:solar-eye-db,POSTGRES_USER=postgres,POSTGRES_DB=solar_eye,POSTGRES_PORT=5432,USE_GPU=true"
        
    if ($LASTEXITCODE -ne 0) { throw "Deployment failed" }
    
    Write-Host "✅ App deployed successfully!" -ForegroundColor Green
    
    $Url = cmd /c "gcloud run services describe $ServiceName --region $Region --format 'value(status.url)'"
    Write-Host "Parsed URL: $Url" -ForegroundColor Cyan
}
catch {
    Write-Error "❌ Deployment failed!"
    exit 1
}
