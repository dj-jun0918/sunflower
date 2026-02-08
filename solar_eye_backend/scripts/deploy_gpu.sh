#!/bin/bash

# Solar Eye Backend - Cloud Run GPU Deployment Script
# Usage: ./scripts/deploy_gpu.sh [PROJECT_ID] [REGION]

# Default values
PROJECT_ID=${1:-knu-team-01}
REGION=${2:-asia-southeast1}  # Default: Singapore (asia-southeast1)
SERVICE_NAME="solar-eye-backend"
IMAGE_TAG="gcr.io/$PROJECT_ID/$SERVICE_NAME:latest"
# Artifact Registry Format (Recommended for new deployments)
# IMAGE_TAG="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$SERVICE_NAME:latest"

echo "========================================================"
echo "Solar Eye Backend - Cloud Run GPU Deployment"
echo "========================================================"
echo "Project ID: $PROJECT_ID"
echo "Region:     $REGION"
echo "Service:    $SERVICE_NAME"
echo "GPU Type:   nvidia-l4"
echo "========================================================"

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Project ID is not set. Please provide it as an argument or set gcloud config."
    exit 1
fi

# 1. Build Container Image
echo "Rx Building container image..."
# Note: This will use .gcloudignore to include model files!
gcloud builds submit --tag "$IMAGE_TAG" .

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"

# 2. Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run..."

gcloud run deploy "$SERVICE_NAME" \
    --image "$IMAGE_TAG" \
    --region "$REGION" \
    --platform managed \
    --allow-unauthenticated \
    --gpu 1 \
    --gpu-type nvidia-l4 \
    --memory 16Gi \
    --cpu 4 \
    --timeout 300 \
    --concurrency 1 \
    --execution-environment gen2 \
    --add-cloudsql-instances knu-team-01:us-central1:solar-eye-db \
    --set-env-vars "APP_ENV=production,POSTGRES_HOST=/cloudsql/knu-team-01:us-central1:solar-eye-db,POSTGRES_USER=postgres,POSTGRES_PASSWORD=rare7979,POSTGRES_DB=solar_eye,POSTGRES_PORT=5432,USE_GPU=true"

# Note: Add other environment variables as needed (DB_URL, etc.) using --set-env-vars

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed!"
    exit 1
fi

echo "✅ App deployed successfully!"
echo "Parsed URL: $(gcloud run services describe $SERVICE_NAME --region $REGION --format 'value(status.url)')"
