# Railway Deployment Guide

## Prerequisites
- Railway account (https://railway.app)
- GitHub account (optional but recommended)

## Step 1: Push code to GitHub

```bash
cd d:\UangJajanTracker
git add .
git commit -m "Prepare for Railway deployment"
git push
```

## Step 2: Deploy on Railway Dashboard

1. Visit https://railway.app
2. Click "New Project"
3. Select "Deploy from GitHub Repo"
4. Connect your `UangJajanTracker` repository
5. Select the repo when prompted

## Step 3: Create MySQL Service

1. In Railway project dashboard, click "+ Create"
2. Select "MySQL" 
3. A new MySQL service will be created with auto-generated credentials
4. Note the connection details (Railway provides `DATABASE_URL`)

## Step 4: Configure Node.js Service

1. Click "+ Create" again
2. Select "GitHub Repo"
3. Connect to your repo again
4. For "Root Directory", enter: `backend/API`
5. Set environment variables in the service settings:

```
PORT=3000
NODE_ENV=production
DB_HOST=${{MySQL.MYSQL_HOST}}
DB_PORT=${{MySQL.MYSQL_PORT}}
DB_USER=${{MySQL.MYSQL_USER}}
DB_PASSWORD=${{MySQL.MYSQL_PASSWORD}}
DB_NAME=${{MySQL.MYSQL_DB}}
JWT_SECRET=your_secure_jwt_secret_here
JWT_EXPIRES_IN=7d
```

6. Set Start Command: `npm install && npm start`

## Step 5: Link Services

1. In the Node.js service, go to "Variables"
2. Make sure MySQL variables are properly referenced as shown above

## Step 6: Get Your Remote URL

Once deployed, Railway provides a public URL like:
```
https://your-app-name.up.railway.app
```

## Step 7: Update Flutter App

Replace the URL in [lib/services/api_service.dart](../lib/services/api_service.dart):

```dart
static const String _remoteUrl = 'https://your-app-name.up.railway.app/api/v1';
```

Then rebuild:
```bash
flutter clean
flutter pub get
flutter build apk   # for Android
```

## Database Migrations

If you need to run migrations on Railway:

1. In Railway dashboard, go to Node.js service
2. Click "Deployments" → "Logs"
3. Or connect via Railway CLI:
   ```bash
   railway connect
   npm run db:migrate
   ```

## Important Notes

- Keep `.env` file out of git (add to `.gitignore`)
- Use strong `JWT_SECRET` in production
- Railway free tier: 500 hours/month (enough for development)
- MySQL: Railway provides free PostgreSQL/MySQL instances

## Troubleshooting

### Service won't start
- Check "Deployments" → "Logs" for errors
- Verify environment variables are set
- Make sure `start` script in package.json is correct

### Database connection fails
- Ensure DB environment variables match exactly
- Check Railway MySQL service is running
- Verify network connectivity

### CORS issues on mobile
- Backend already has CORS enabled
- Ensure request URL matches exactly (trailing slashes, protocol, etc.)
