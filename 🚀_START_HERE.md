# 🚀 START HERE - WorkStation Setup Guide

## What This Is
A complete browser automation platform with:
- ✅ Chrome extension with visual UI
- ✅ 32 pre-built workflow templates
- ✅ Visual drag-and-drop workflow builder
- ✅ Backend API server (Node.js/Express)
- ✅ 25+ AI agents for automation

---

## Step 1 – Open Terminal (Mac, Windows, Linux)

### On macOS (either way is fine):

**Option A (keyboard – easiest):**
1. Press **Command + Space** to open Spotlight
2. Type **Terminal**
3. Press **Enter**

**Option B (mouse):**
1. Click the **magnifying glass** at the top-right (Spotlight)
2. Type **Terminal**
3. Click the **Terminal** app

### On Windows (PowerShell):

**Option A (keyboard – easiest):**
1. Press the **Windows key**
2. Type **PowerShell**
3. Press **Enter**

**Option B (mouse):**
1. Click the **Start button**
2. Type **PowerShell**
3. Click **Windows PowerShell**

### On Linux:

**Option A (keyboard – easiest):**
1. Press **Ctrl + Alt + T**

**Option B (mouse):**
1. Open your applications menu
2. Search for **Terminal**
3. Click it

### Verify Your Terminal is Ready

In the terminal window, look at the last line:
- If it ends with **$**, **%**, or **>**, it is ready
- If it looks stuck or half-typed, press **Ctrl + C** once

**Leave the terminal open at the prompt, with nothing typed.**

You are now ready for Step 2.

---

## Step 2 – Run the Setup Script

### Prerequisites
Make sure the terminal window from Step 1 is open and active, and you see a prompt ending with **$**, **%**, or **>**.

### Copy and Run the Script

1. In this browser window, select all of the text inside the gray box below:
   - Click just before the first **#**
   - Hold and drag down to the very bottom of the box so everything is highlighted
   - Copy it (**Command + C** on macOS, **Ctrl + C** on Windows/Linux)

2. Click back into your terminal window so the cursor is active there

3. Paste the script into the terminal:
   - **macOS:** Command + V
   - **Windows (PowerShell):** right-click, then Paste, or Ctrl + V if enabled
   - **Linux:** Ctrl + Shift + V

4. Press **Enter** once (if it does not start automatically), then wait until it finishes

**This may take several minutes the first time.**

```bash
###############################################################################
# WORKSTATION SETUP SCRIPT (macOS & Linux: Bash, Windows: PowerShell-compatible)
# Copy this whole block, paste into your terminal, and press Enter once.
###############################################################################

# Detect shell and OS
if [ -n "$PSModulePath" ] && command -v powershell.exe >/dev/null 2>&1; then
  SHELL_TYPE="powershell"
else
  SHELL_TYPE="bash"
fi

OS_TYPE="unknown"
case "$(uname | tr '[:upper:]' '[:lower:]')" in
  darwin*) OS_TYPE="mac";;
  linux*)  OS_TYPE="linux";;
  msys*|mingw*|cygwin*) OS_TYPE="windows";;
esac

echo "Detected shell type: $SHELL_TYPE"
echo "Detected OS type:    $OS_TYPE"

# Normalize home directory
if [ "$OS_TYPE" = "windows" ] && [ -n "$USERPROFILE" ]; then
  HOME_DIR="$USERPROFILE"
else
  HOME_DIR="$HOME"
fi

echo
echo "=== Step 2.1: Using home folder: $HOME_DIR ==="
cd "$HOME_DIR" || { echo "ERROR: Cannot enter home directory: $HOME_DIR"; exit 1; }

# Create projects directory
echo
echo "=== Step 2.2: Creating/using project folder ==="
PROJECTS_DIR="$HOME_DIR/workStation-projects"
mkdir -p "$PROJECTS_DIR" || { echo "ERROR: Cannot create $PROJECTS_DIR"; exit 1; }
cd "$PROJECTS_DIR" || { echo "ERROR: Cannot enter $PROJECTS_DIR"; exit 1; }
echo "Projects will be stored in: $PROJECTS_DIR"

# Check/install tools per OS
echo
echo "=== Step 2.3: Checking required tools (Node.js, npm, git) ==="

check_or_install_mac() {
  TOOL_NAME="$1"
  BREW_NAME="$2"
  if ! command -v "$TOOL_NAME" >/dev/null 2>&1; then
    echo "$TOOL_NAME not found. Attempting to install with Homebrew..."
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew not found. Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "ERROR: Failed to install Homebrew. Please install Homebrew manually from brew.sh and re-run this script."
        exit 1
      }
      eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
    fi
    brew install "$BREW_NAME" || {
      echo "ERROR: Failed to install $TOOL_NAME with Homebrew."
      exit 1
    }
  fi
}

check_or_install_linux_apt() {
  TOOL_NAME="$1"
  APT_NAME="$2"
  if ! command -v "$TOOL_NAME" >/dev/null 2>&1; then
    echo "$TOOL_NAME not found. Attempting to install with apt (you may be asked for your password)..."
    if command -v sudo >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y "$APT_NAME" || {
        echo "ERROR: Failed to install $TOOL_NAME with apt."
        exit 1
      }
    else
      echo "ERROR: sudo not available. Please install $APT_NAME using your package manager and re-run this script."
      exit 1
    fi
  fi
}

check_or_install_windows_hint() {
  TOOL_NAME="$1"
  if ! command -v "$TOOL_NAME" >/dev/null 2>&1; then
    echo "ERROR: $TOOL_NAME is not installed."
    echo "On Windows, you can install it with:"
    echo "  - Node.js: download from https://nodejs.org (LTS version)"
    echo "  - Git:     download from https://git-scm.com"
    echo "After installing, open PowerShell again and re-run this script."
    exit 1
  fi
}

case "$OS_TYPE" in
  mac)
    check_or_install_mac node node
    check_or_install_mac npm node
    check_or_install_mac git git
    ;;
  linux)
    if command -v apt-get >/dev/null 2>&1; then
      check_or_install_linux_apt node nodejs
      check_or_install_linux_apt npm npm
      check_or_install_linux_apt git git
    else
      echo "Non-apt Linux detected. Please ensure node, npm, and git are installed using your distro's package manager, then re-run this script."
      exit 1
    fi
    ;;
  windows)
    check_or_install_windows_hint node
    check_or_install_windows_hint npm
    check_or_install_windows_hint git
    ;;
  *)
    echo "ERROR: Unsupported or unknown OS. Please ensure node, npm, and git are installed, then re-run this script."
    exit 1
    ;;
esac

echo "All required tools are available."
echo "Node version: $(node -v 2>/dev/null || echo 'unknown')"
echo "npm version:  $(npm -v 2>/dev/null || echo 'unknown')"

# Clone or update repo
echo
echo "=== Step 2.4: Downloading or updating WorkStation program ==="
REPO_URL="https://github.com/credli-X/workStation.git"
REPO_DIR="$PROJECTS_DIR/workStation"

if [ -d "$REPO_DIR/.git" ]; then
  echo "Existing WorkStation folder found at: $REPO_DIR"
  cd "$REPO_DIR" || { echo "ERROR: Cannot enter $REPO_DIR"; exit 1; }
  echo "Updating existing copy..."
  git pull || echo "Warning: git pull failed; continuing with existing version."
else
  echo "No existing WorkStation folder found. Cloning into: $REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR" || { echo "ERROR: git clone failed"; exit 1; }
  cd "$REPO_DIR" || { echo "ERROR: Cannot enter $REPO_DIR after clone"; exit 1; }
fi

echo
echo "Repository contents:"
ls

# Create .env if missing
echo
echo "=== Step 2.5: Creating configuration file (.env) if needed ==="
ENV_FILE="$REPO_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  echo ".env already exists at: $ENV_FILE"
else
  echo "Creating default .env at: $ENV_FILE"
  cat > "$ENV_FILE" << 'EOF'
NODE_ENV=development
PORT=3000

JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters-here
SESSION_SECRET=different-session-secret-minimum-32-characters
ENCRYPTION_KEY=encryption-key-exactly-32-characters

# For simplest setup, keep this commented so WorkStation uses SQLite
# DATABASE_URL=postgresql://user:password@localhost:5432/workstation
EOF
fi
echo ".env is ready."

# Install and build
echo
echo "=== Step 2.6: Installing dependencies (npm install) ==="
npm install || { echo "ERROR: npm install failed"; exit 1; }

echo
echo "=== Step 2.7: Building WorkStation (npm run build) ==="
npm run build || { echo "ERROR: npm run build failed"; exit 1; }

# Prepare extension
echo
echo "=== Step 2.8: Preparing Chrome extension files ==="
DIST_DIR="$REPO_DIR/dist"
UNPACKED_DIR="$DIST_DIR/chrome-extension-unpacked"
ZIP_FILE="$DIST_DIR/workstation-ai-agent-enterprise-v2.1.0.zip"

mkdir -p "$UNPACKED_DIR"

if [ -f "$ZIP_FILE" ]; then
  echo "Found extension ZIP at: $ZIP_FILE"
  unzip -o "$ZIP_FILE" -d "$UNPACKED_DIR" || { echo "ERROR: unzip failed"; exit 1; }
else
  echo "Extension ZIP not found. Building enterprise Chrome extension..."
  bash ./scripts/build-enterprise-chrome-extension.sh || { echo "ERROR: build script failed"; exit 1; }
  unzip -o "$ZIP_FILE" -d "$UNPACKED_DIR" || { echo "ERROR: unzip failed"; exit 1; }
fi

echo "Extension unpacked to: $UNPACKED_DIR"

echo
echo "=== Step 2.9: Starting backend server (npm start) ==="
echo "Keep this terminal window open while you use WorkStation."
npm start
```

### What Success Looks Like

You should see:
- ✅ Node.js and npm versions displayed
- ✅ Repository cloned to **~/workStation-projects/workStation**
- ✅ Dependencies installed successfully
- ✅ Build completed with no errors
- ✅ Chrome extension unpacked
- ✅ Server starting with message: **"Server running at http://localhost:3000"**

**Keep this terminal window open!** The server needs to run continuously.

---

## Step 3 – Install and Connect the Chrome Extension

### Open Google Chrome

- **macOS:** Press **Command + Space**, type **Chrome**, press **Enter**
- **Windows:** Press the **Windows key**, type **Chrome**, press **Enter**
- **Linux:** Press **Super (Windows key)**, type **Chrome**, press **Enter**

### Open the Extensions Page

1. Click the **address bar** at the top
2. Type **chrome://extensions/** and press **Enter**
3. Turn on **Developer mode** (toggle in the top-right of the page)

### Load the WorkStation Extension

1. On the **chrome://extensions/** page, click **"Load unpacked"**

2. In the folder dialog, navigate to:
   - Your home folder → **workStation-projects** → **workStation** → **dist** → **chrome-extension-unpacked**

3. Click the **chrome-extension-unpacked** folder once to select it

4. Click **"Open"** or **"Select Folder"**

The WorkStation extension will appear in the list of extensions.

### Pin the WorkStation Icon

1. In Chrome's top-right corner, click the **puzzle-piece icon** (Extensions)
2. Find **"WorkStation"** in the list
3. Click the **pin icon** next to WorkStation so its icon stays visible in the toolbar

### Connect the Extension to Your Backend Server

1. Click the **WorkStation icon** in the Chrome toolbar
2. In the popup, go to the **"Settings"** tab
3. Find **"Backend URL"** and enter exactly:
   ```
   http://localhost:3000
   ```
4. Save or close the popup (depending on the UI)

**Note:** This URL must match **PORT=3000** in your **.env** file, which the setup script created by default.

### Optional Quick Health Check

Open a new terminal window and run:

```bash
cd ~/workStation-projects/workStation
curl http://localhost:3000/health/live
```

If you see a small response (status message), your backend is reachable and the extension is correctly pointed at it.

### What Success Looks Like

You should see:
- ✅ WorkStation extension loaded in Chrome
- ✅ WorkStation icon pinned to toolbar
- ✅ Settings show Backend URL: http://localhost:3000
- ✅ Health check returns JSON response

---

## Step 4 – Run a Template Workflow

### Execute a Pre-Built Template

1. Make sure the terminal window from Step 2 (running **npm start**) is still open and showing log messages

2. In Google Chrome, click the **WorkStation icon** in the toolbar

3. In the popup, click the **"Templates"** tab

4. Browse the list of templates (for example: **Web Scraping**, **Form Filling**, **Lead Capture**)

5. Click one template to select it

6. Review any fields or options the template shows (such as URL or text inputs)

7. Click the **Execute** or **Run** button (depending on the UI)

8. Watch the browser: it should begin to perform the actions defined by the template (navigate, click, type, extract, etc.)

### What Success Looks Like

- ✅ The workflow runs without an error message in the extension
- ✅ You see automated behavior in the browser (page loads, clicks, form entries) matching the template's description
- ✅ The terminal shows backend logs of the workflow execution
- ✅ Results appear in the extension's History tab

### Available Templates

The WorkStation includes 32 pre-built workflow templates:
- 🔍 **Web Scraping** - Extract data from websites
- 📝 **Form Automation** - Fill and submit forms automatically
- 🎯 **Lead Capture** - Collect contact information
- 📊 **Data Extraction** - Pull structured data from pages
- 🔄 **Multi-Step Workflows** - Complex automation sequences
- And 27 more templates!

---

## Step 5 – Use the Visual Workflow Builder

### Open the Workflow Builder

**Method 1 (via Extension):**
1. In Chrome, click the **WorkStation icon** again
2. In the popup, click the **"Builder"** tab
3. Click the button labeled **"Open Builder"**

**Method 2 (directly in browser):**
1. In Chrome's address bar, type:
   ```
   http://localhost:3000/workflow-builder.html
   ```
2. Press **Enter** to open the builder directly

### Build Your First Workflow

1. **In the visual builder page**, you will see a canvas where you can drag blocks (nodes)

2. **Add a Navigate node:**
   - On the left (or in the node list), find a node called **"Navigate"**
   - Drag it onto the canvas

3. **Add an Extract Data node:**
   - Find a node called **"Extract Data"** (or similar)
   - Drag it onto the canvas

4. **Connect the nodes:**
   - Click on the small connector from the **Navigate** node
   - Drag it to the **Extract Data** node to connect them in order

5. **Configure the Navigate node:**
   - Click the **Navigate** node
   - Set the **URL** of the page you want to visit (e.g., `https://example.com`)

6. **Configure the Extract Data node:**
   - Click the **Extract Data** node
   - Configure what information you want it to collect (such as text, tables, or specific elements)
   - Use CSS selectors or XPath to target specific elements

7. **Execute the workflow:**
   - When both nodes are configured, click the **Execute** or **Run** button in the builder interface

8. **Watch the automation:**
   - The browser should open the specified page and then extract the data as configured

### What Success Looks Like

- ✅ The builder shows the workflow as running/completed
- ✅ The browser opens the specified page
- ✅ Data appears in the output area or logs according to your Extract Data node configuration
- ✅ The terminal shows backend processing logs
- ✅ You can save the workflow for future use

### Available Workflow Nodes

The Visual Workflow Builder includes these node types:
- 🌐 **Navigate** - Go to a URL
- 📊 **Extract Data** - Pull data from page elements
- 🖱️ **Click** - Click buttons, links, or elements
- ⌨️ **Type** - Enter text into form fields
- 🔍 **Wait** - Wait for elements or conditions
- 🔄 **Loop** - Repeat actions multiple times
- 🔀 **Conditional** - Make decisions based on data
- 💾 **Store** - Save data to variables
- 📤 **Export** - Output data to files
- And many more!

---

## Troubleshooting

### Extension shows "Backend offline"
- Make sure backend is running: **npm start** in the terminal
- Check server: `curl http://localhost:3000/health/live`
- In extension Settings tab, verify Backend URL is **http://localhost:3000**

### "File does not exist" error
- You're missing **.env** file - see Step 2 above
- Or copy from template: `cp .env.example .env` then edit values

### Templates not loading
- Backend must be running
- Check console: **F12** → Console tab
- Verify: `curl http://localhost:3000/api/workflow-templates`

### Build script fails
- Install ImageMagick: `brew install imagemagick` (Mac) or `apt-get install imagemagick` (Linux)
- Or use pre-built ZIP files in **dist/** (skip build step)

### Port 3000 already in use
- Change **PORT** in **.env** file
- Update Backend URL in extension Settings tab

### Database connection error
- For quick start, comment out **DATABASE_URL** in **.env**
- App uses SQLite by default (no setup needed)
- For PostgreSQL, ensure database exists and credentials are correct

### Terminal shows errors during npm install
- Try: `rm -rf node_modules package-lock.json`
- Then: `npm install`

### Chrome extension won't load
- Make sure you selected the **chrome-extension-unpacked** folder, not the zip file
- Check that Developer mode is enabled
- Try removing and re-adding the extension

---

## What Each Part Does

| Component | Purpose | Location |
|-----------|---------|----------|
| **Chrome Extension** | UI, browser automation | `chrome-extension/` |
| **Backend Server** | API, workflow execution, agents | `src/` |
| **Workflow Builder** | Visual editor | `public/workflow-builder.html` |
| **Templates** | 32 pre-built workflows | `src/workflow-templates/` |
| **Playwright Features** | Auto-wait, self-healing | `chrome-extension/playwright/` |

---

## Architecture Overview

```
┌─────────────────────┐
│  Chrome Extension   │  ← You click here
│  (Browser UI)       │
└──────────┬──────────┘
           │
           │ WebSocket/REST API
           │
┌──────────▼──────────┐
│  Backend Server     │  ← npm start
│  (Port 3000)        │
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
┌────▼────┐ ┌───▼────┐
│Workflow │ │Browser │
│Builder  │ │Agent   │
└─────────┘ └────────┘
```

---

## Quick Commands Reference

```bash
# Backend Server
npm install              # Install dependencies
npm run build           # Compile TypeScript
npm start               # Start server (production)
npm run dev             # Start server (development)
npm test                # Run tests
npm run lint            # Check code quality

# Chrome Extension
bash ./scripts/build-enterprise-chrome-extension.sh  # Build ZIP
bash ./scripts/build-chrome-extension.sh             # Build simple version
npm run build:chrome:enterprise                      # Build via npm

# All-in-One
npm run start:all       # Shows complete setup instructions
```

---

## Next Steps

### Learn More
- Browse the 32 workflow templates in the extension
- Read the [Workflow Templates Guide](WORKFLOW_TEMPLATES.md)
- Check out [example workflows](examples/workflows/)

### Build Your First Workflow
1. Open the Visual Workflow Builder
2. Drag "Navigate" node onto canvas
3. Drag "Extract Data" node onto canvas
4. Connect them together
5. Configure each node
6. Click "Execute"

### Deploy to Production
- See: [Deployment Guide](docs/guides/DEPLOYMENT.md)
- Railway: [![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/stackbrowseragent)
- Docker: `docker-compose up -d`
- Kubernetes: `kubectl apply -f k8s/`

---

## Additional Documentation

- **Chrome Extension:** `chrome-extension/README.md` or `🚀_START_HERE_CHROME_EXTENSION.md`
- **Workflow Templates:** `WORKFLOW_TEMPLATES.md`
- **API Endpoints:** `docs/API_DOCUMENTATION.md` or `API.md`
- **Architecture:** `ARCHITECTURE.md`
- **Getting Started Guide:** `GETTING_STARTED.md`
- **Quick Run:** `QUICK_RUN.md`

---

## Need Help?

- 📖 [Complete Documentation Index](docs/DOCUMENTATION_INDEX.md)
- 🐛 [Report Issues](https://github.com/credli-X/workStation/issues)
- 💬 [Ask Questions](https://github.com/credli-X/workStation/discussions)
- 📧 Check the comprehensive [Getting Started Guide](GETTING_STARTED.md)

---

**NOW GO BUILD SOME WORKFLOWS!** 🚀
