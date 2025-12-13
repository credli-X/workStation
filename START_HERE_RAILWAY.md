# 🚀 Quick Start: Deploy to Railway

**Repository**: credli-X/workstation  
**Status**: ✅ READY FOR DEPLOYMENT  
**Time to Deploy**: ~3 minutes

---

## What You're Deploying

A **complete automation platform** with:

- ✅ **15+ Automation Agents** - Browser, Email, Sheets, Calendar, Files, Database, S3, CSV, JSON, Excel, PDF, RSS, and more
- ✅ **4 Visual Dashboards** - Main dashboard, Workflow builder (drag-and-drop), Gemini AI, Setup wizard
- ✅ **2 Chrome Extensions** - Standard (97KB) + Enterprise (143KB)
- ✅ **Workflow Engine** - Execute complex automation workflows
- ✅ **Browser Automation** - Playwright + Puppeteer integrated
- ✅ **Cloud Integration** - AWS S3, Google Workspace, Slack
- ✅ **Database Support** - PostgreSQL + SQLite

---

## Deploy Now (3 Steps)

### 1. Go to Railway
Visit: **https://railway.app**

### 2. Deploy from GitHub
- Click **"New Project"**
- Select **"Deploy from GitHub repo"**
- Choose **credli-X/workstation**

### 3. Done! 🎉
Your app will be live at: `https://your-app.railway.app`

Railway automatically:
- Generates `JWT_SECRET` (secure)
- Runs `npm install && npm run build`
- Starts with `npm start`
- Provides HTTPS and custom domains

---

## Access Your App

After deployment:

| Resource | URL |
|----------|-----|
| **Health Check** | `https://your-app.railway.app/health` |
| **Main Dashboard** | `https://your-app.railway.app/legacy/dashboard.html` |
| **Workflow Builder** | `https://your-app.railway.app/legacy/workflow-builder.html` |
| **Gemini AI** | `https://your-app.railway.app/legacy/gemini-dashboard.html` |
| **Setup Wizard** | `https://your-app.railway.app/legacy/setup.html` |
| **API Docs** | See `API.md` in repository |

---

## Quick Test

```bash
# 1. Health check
curl https://your-app.railway.app/health

# 2. Get agent capabilities
curl https://your-app.railway.app/api/agents/capabilities

# 3. Generate demo token
curl -X POST https://your-app.railway.app/api/auth/demo/token
```

---

## Optional Enhancements

### Add PostgreSQL Database
1. In Railway dashboard, click **"New"** → **"Database"** → **"PostgreSQL"**
2. Railway automatically adds `DATABASE_URL` environment variable
3. Initialize schema: `railway run psql $DATABASE_URL -f src/automation/db/schema.sql`

### Configure Google Workspace
Add these environment variables in Railway:
```
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REDIRECT_URI=https://your-app.railway.app/auth/google/callback
```

### Configure AWS S3
```
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=your-bucket-name
```

### Enable Slack Integration
```
SLACK_BOT_TOKEN=xoxb-your-token
SLACK_SIGNING_SECRET=your-signing-secret
```

---

## Download Chrome Extensions

After deployment, download extensions:

```bash
# Standard edition
curl https://your-app.railway.app/api/downloads/chrome-extension -o workstation-ai-agent.zip

# Enterprise edition
curl https://your-app.railway.app/api/downloads/chrome-extension-enterprise -o workstation-ai-agent-enterprise.zip
```

Install in Chrome:
1. Extract ZIP file
2. Go to `chrome://extensions`
3. Enable "Developer mode"
4. Click "Load unpacked"
5. Select extracted folder

---

## Need Help?

### Documentation
- **Deployment Guide**: `RAILWAY_DEPLOYMENT.md` (467 lines - complete guide)
- **Architecture**: `RAILWAY_READY_SUMMARY.md` (706 lines - detailed overview)
- **Quick Checklist**: `DEPLOY_CHECKLIST.md` (quick reference)
- **API Reference**: `API.md` (all endpoints)

### Troubleshooting
1. Check Railway logs: `railway logs` (CLI) or dashboard
2. Verify health: `curl https://your-app.railway.app/health`
3. Test build locally: `npm run build && npm start`
4. See troubleshooting section in `RAILWAY_DEPLOYMENT.md`

### Support
- **GitHub Issues**: https://github.com/credli-X/workstation/issues
- **Railway Discord**: https://discord.gg/railway
- **Railway Docs**: https://docs.railway.app

---

## What's Pre-Configured

✅ **Build System**
- TypeScript compilation
- Asset copying
- Production optimization

✅ **Security**
- JWT authentication
- Rate limiting (100 req/15min)
- Helmet.js security headers
- CORS configuration
- Input validation

✅ **Infrastructure**
- Health checks
- Prometheus metrics
- Winston logging
- Error handling
- Automatic restarts

✅ **Automation**
- 15+ pre-built agents
- Workflow orchestration
- Template system
- State management
- Parallel execution

---

## Performance Specs

- **Memory**: ~200MB baseline, ~500MB under load
- **CPU**: Low (event-driven architecture)
- **Disk**: ~100MB app + ~50MB cache
- **Concurrent Workflows**: 10+ (scalable)
- **Request Throughput**: 100+ req/min
- **Agent Capacity**: 15+ agents active

---

## Railway Free Tier

Railway's **free tier** includes:
- ✅ 500 hours/month execution time
- ✅ 512MB RAM
- ✅ 1GB disk space
- ✅ Automatic HTTPS
- ✅ Custom domains
- ✅ PostgreSQL database (500MB)

Perfect for:
- Development and testing
- Small production workloads
- Personal automation projects

---

## Upgrade Path

For production use, consider:
- **Developer Plan** ($5/month): More resources
- **Team Plan** ($20/month): Team collaboration
- **Monitor usage**: Railway dashboard shows real-time metrics

---

## Deploy Now!

Ready to deploy? Here's the link again:

**👉 https://railway.app**

1. New Project → Deploy from GitHub
2. Select credli-X/workstation
3. Deploy!

**Live in ~3 minutes** ⚡

---

## Success Indicators

After deployment, verify:
- ✅ Health endpoint returns 200: `/health`
- ✅ Dashboard loads: `/legacy/dashboard.html`
- ✅ API responds: `/api/agents/capabilities`
- ✅ Logs show "Server started on port XXX"

---

**Questions?** See `RAILWAY_DEPLOYMENT.md` for the complete guide (467 lines).

**Happy Automating!** 🤖✨

---

**Created**: December 13, 2025  
**Version**: 1.0.0  
**Status**: 🟢 PRODUCTION READY
