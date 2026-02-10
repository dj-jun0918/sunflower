# Solar Eye Backend Deployment Script (GPU Enabled)

$PROJECT_ID = "knu-team-01"
$REGION = "asia-northeast3" # Seoul
$SERVICE_NAME = "solar-eye-backend-gpu"
$IMAGE_TAG = "gcr.io/$PROJECT_ID/solar-eye-backend:fixed"

Write-Host "🚀 Starting Deployment Process for $SERVICE_NAME..." -ForegroundColor Cyan

# 1. Build Container Image
Write-Host "`n📦 Building Docker Image via Cloud Build..." -ForegroundColor Yellow
gcloud builds submit --config cloudbuild.yaml .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build Failed!" -ForegroundColor Red
    exit 1
}

# 2. Deploy to Cloud Run (with GPU)
Write-Host "`n☁️ Deploying to Cloud Run (NVIDIA L4 GPU)..." -ForegroundColor Yellow
gcloud run deploy $SERVICE_NAME `
    --image $IMAGE_TAG `
    --region $REGION `
    --platform managed `
    --allow-unauthenticated `
    --port 8000 `
    --gpu 1 `
    --gpu-type nvidia-rtx-pro-6000 `
    --cpu 20 `
    --memory 80Gi `
    --no-cpu-throttling `
    --min-instances 1 `
    --max-instances 2 `
    --timeout 300 `
    --service-account "solar-eye-backend-sa@$PROJECT_ID.iam.gserviceaccount.com" `
    --set-env-vars "PYTHONUNBUFFERED=1,USE_GPU=true,MODULE_NAME=app.main"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Deployment Successful!" -ForegroundColor Green
    Write-Host "Service URL can be found above."
} else {
    Write-Host "`n❌ Deployment Failed!" -ForegroundColor Red
    Write-Host "Ensure that you have quota for NVIDIA L4 GPUs in $REGION."
}
