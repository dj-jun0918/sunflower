# Solar Eye Backend Deployment Guide (GPU)

Since your local computer does not have the Google Cloud SDK (`gcloud`) installed, the easiest way to deploy is using **Google Cloud Shell**.

## Step 1: Open Cloud Shell
1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Click the terminal icon **(>_)** in the top right toolbar to open Cloud Shell.

## Step 2: Get the Latest Code

Since you already have the folder, just update it:

```bash
# 1. Enter the directory
cd solar-eye

# 2. Update to the latest code
git checkout develop
git pull origin develop
```

*(If `git pull` fails due to conflicts, run `git reset --hard origin/develop` to force overwrite local changes with the latest code.)*

## Step 3: Deployment
Copy and paste this entire block to build and deploy with GPU support:

```bash
# 1. Build the Docker Image
gcloud builds submit --config cloudbuild.yaml .

# 2. Deploy to Cloud Run (Seoul Region, NVIDIA L4 GPU)
gcloud run deploy solar-eye-backend-gpu \
  --image gcr.io/knu-team-01/solar-eye-backend:fixed \
  --region asia-northeast3 \
  --platform managed \
  --allow-unauthenticated \
  --port 8000 \
  --gpu 1 \
  --gpu-type nvidia-l4 \
  --memory 16Gi \
  --cpu 4 \
  --no-cpu-throttling \
  --min-instances 1 \
  --max-instances 2 \
  --timeout 300 \
  --service-account solar-eye-backend-sa@knu-team-01.iam.gserviceaccount.com \
  --set-env-vars "PYTHONUNBUFFERED=1,USE_GPU=true,MODULE_NAME=app.main"
```

## Step 4: Verification
After a few minutes, the command will finish and show a **Service URL** (e.g., `https://solar-eye-backend-gpu-xyz.a.run.app`).
You must update your Flutter app's API Base URL to this new address.
