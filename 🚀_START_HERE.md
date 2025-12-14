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

## Step 2 – Create Your Project Folder

### Step 2.1: Navigate to Your Home Directory

In your terminal window, copy the command below, paste it, and press **Enter**:

```bash
cd ~
```

**What this does:** Takes you to your home directory (the starting point for all users).

**Success:** You should see the prompt appear again after pressing Enter (no error messages).

---

### Step 2.2: Create and Enter the Projects Folder

Copy this command, paste it into your terminal, and press **Enter**:

```bash
mkdir -p workStation-projects && cd workStation-projects
```

**What this does:** Creates a folder called `workStation-projects` (if it doesn't exist) and moves into it.

**Success:** You should see the prompt again. Type `pwd` and press Enter - you should see a path ending in `/workStation-projects`.

---

## Step 3 – Download WorkStation

### Step 3.1: Clone the Repository

Copy this command, paste it into your terminal, and press **Enter**:

```bash
git clone https://github.com/credli-X/workStation.git
```

**What this does:** Downloads the complete WorkStation program from GitHub to your computer.

**Success:** You should see messages like "Cloning into 'workStation'..." and eventually "done." This may take 1-2 minutes.

**If you see an error:**
- **"git: command not found"** → You need to install Git first:
  - **Mac:** Type `brew install git` and press Enter (or install Homebrew first from https://brew.sh)
  - **Windows:** Download from https://git-scm.com and install, then open PowerShell again
  - **Linux:** Type `sudo apt-get install git` and press Enter

---

### Step 3.2: Enter the WorkStation Folder

Copy this command, paste it, and press **Enter**:

```bash
cd workStation
```

**What this does:** Moves you into the WorkStation folder that was just downloaded.

**Success:** Your prompt should now show `workStation` in the path. Type `ls` and press Enter - you should see files like `package.json`, `README.md`, etc.

---

## Step 4 – Install Required Tools

### Step 4.1: Check if Node.js is Installed

Copy this command, paste it, and press **Enter**:

```bash
node -v
```

**What this does:** Checks if Node.js is installed and shows the version.

**If you see a version number** (like `v18.17.0` or `v20.10.0`): ✅ Great! Continue to Step 4.2.

**If you see "command not found":** You need to install Node.js:

**On Mac:**
```bash
brew install node
```
Then press Enter and wait (may take 5-10 minutes). If "brew: command not found", install Homebrew first from https://brew.sh

**On Windows:**
1. Visit https://nodejs.org
2. Download the LTS version (green button)
3. Run the installer
4. After installation, close PowerShell and open it again
5. Re-run `node -v` to verify

**On Linux (Ubuntu/Debian):**
```bash
sudo apt-get update && sudo apt-get install -y nodejs npm
```
Then press Enter and type your password when asked.

After installing Node.js, verify by running `node -v` again - you should see a version number.

---

### Step 4.2: Verify npm is Installed

Copy this command, paste it, and press **Enter**:

```bash
npm -v
```

**What this does:** Checks if npm (Node Package Manager) is installed.

**Success:** You should see a version number (like `9.8.1` or `10.2.0`).

**If you see "command not found":** npm should have been installed with Node.js. Try installing Node.js again from Step 4.1.

---

## Step 5 – Set Up Configuration

### Step 5.1: Create the Configuration File

Copy this entire block, paste it into your terminal, and press **Enter**:

```bash
cat > .env << 'EOF'
NODE_ENV=development
PORT=3000

JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters-here
SESSION_SECRET=different-session-secret-minimum-32-characters
ENCRYPTION_KEY=encryption-key-exactly-32-characters

# For simplest setup, keep this commented so WorkStation uses SQLite
# DATABASE_URL=postgresql://user:password@localhost:5432/workstation
EOF
```

**What this does:** Creates a `.env` configuration file with default settings for local development.

**Success:** The prompt should appear again with no error messages.

**Verify:** Type `ls -la .env` and press Enter - you should see the file listed.

---

## Step 6 – Install Dependencies

### Step 6.1: Install All Required Packages

Copy this command, paste it, and press **Enter**:

```bash
npm install
```

**What this does:** Downloads and installs all the software packages WorkStation needs to run.

**This will take 2-5 minutes.** You'll see lots of text scrolling by - this is normal!

**Success:** You should see messages like "added X packages" and no error messages at the end.

**If you see errors:**
- **"package.json not found"** → Make sure you're in the `workStation` folder (run `cd ~/workStation-projects/workStation`)
- **"EACCES: permission denied"** → On Mac/Linux, never use `sudo npm install` - this causes problems. Fix permissions first.
- Other errors: Wait for it to finish, then try running `npm install` again - it often works the second time.

---

## Step 7 – Build the Application

### Step 7.1: Compile TypeScript to JavaScript

Copy this command, paste it, and press **Enter**:

```bash
npm run build
```

**What this does:** Converts the TypeScript source code into JavaScript that Node.js can run.

**This will take 30-60 seconds.**

**Success:** You should see no error messages, and the command should complete successfully.

**Verify:** Type `ls dist` and press Enter - you should see JavaScript files in the `dist` folder.

---

## Step 8 – Prepare the Chrome Extension

### Step 8.1: Create the Extension Folder

Copy this command, paste it, and press **Enter**:

```bash
mkdir -p dist/chrome-extension-unpacked
```

**What this does:** Creates a folder where we'll extract the Chrome extension files.

**Success:** The prompt appears again with no errors.

---

### Step 8.2: Extract the Chrome Extension

Copy this command, paste it, and press **Enter**:

```bash
unzip -o dist/workstation-ai-agent-enterprise-v2.1.0.zip -d dist/chrome-extension-unpacked
```

**What this does:** Extracts the Chrome extension from the ZIP file so Chrome can load it.

**Success:** You should see messages listing files being extracted.

**If you see "unzip: command not found":**
- **Mac:** Type `brew install unzip` and press Enter
- **Linux:** Type `sudo apt-get install unzip` and press Enter
- **Windows:** Unzip should be built-in; if not, install 7-Zip from https://7-zip.org

After installing unzip, run the command again.

---

### Step 8.3: Verify Extension Files

Copy this command, paste it, and press **Enter**:

```bash
ls dist/chrome-extension-unpacked
```

**What this does:** Shows the files in the extension folder.

**Success:** You should see files like `manifest.json`, `popup.html`, `background.js`, etc.

---

## Step 9 – Start the Backend Server

### Step 9.1: Start the Server

Copy this command, paste it, and press **Enter**:

```bash
npm start
```

**What this does:** Starts the WorkStation backend server on port 3000.

**Success:** You should see messages like:
```
✅ Server running on port 3000
Server started
```

**IMPORTANT:** Keep this terminal window open! The server needs to stay running while you use WorkStation.

**To stop the server later:** Press **Ctrl + C** in this terminal window.

---

### Step 9.2: Verify the Server is Running

Open a **NEW** terminal window (don't close the one running the server), then copy, paste, and press **Enter**:

```bash
curl http://localhost:3000/health/live
```

**What this does:** Checks if the server is responding.

**Success:** You should see a JSON response like `{"status":"healthy"}` or similar.

**If it doesn't work:**
- Make sure the server is still running in the first terminal window
- Check for error messages in that window
- Make sure port 3000 isn't being used by another program

After verification, you can close this second terminal window. Keep the server terminal open!

---

## Step 10 – Install the Chrome Extension

### Step 10.1: Open Google Chrome

**On macOS:**
1. Press **Command + Space** on your keyboard
2. Type **Chrome**
3. Press **Enter**

**On Windows:**
1. Press the **Windows key** on your keyboard
2. Type **Chrome**
3. Press **Enter**

**On Linux:**
1. Press **Super** (Windows key) on your keyboard
2. Type **Chrome**
3. Press **Enter**

**Success:** The Chrome browser window should open.

---

### Step 10.2: Open the Chrome Extensions Page

**In the Chrome window:**

1. Click in the **address bar** at the very top (where you normally type website addresses)
2. Type exactly: `chrome://extensions/`
3. Press **Enter**

**Success:** You should see a page titled "Extensions" with a list of installed extensions (or an empty list if none are installed yet).

---

### Step 10.3: Enable Developer Mode

**On the Extensions page:**

1. Look at the **top-right corner** of the page
2. Find the toggle switch labeled **"Developer mode"**
3. Click it so it turns **ON** (usually turns blue)

**Success:** After enabling Developer mode, you should see three new buttons appear: "Load unpacked", "Pack extension", and "Update".

---

### Step 10.4: Click "Load unpacked"

1. Click the **"Load unpacked"** button (it's near the top-left after enabling Developer mode)

**What happens:** A file browser window will open asking you to select a folder.

---

### Step 10.5: Navigate to the Extension Folder

**In the file browser window that just opened:**

1. **Go to your home folder:**
   - **Mac:** Look for your username in the sidebar (or press Command + Shift + H)
   - **Windows:** Look for "This PC" or your username folder
   - **Linux:** Look for "Home" in the sidebar

2. **Open the workStation-projects folder:**
   - Find and double-click the folder named **workStation-projects**

3. **Open the workStation folder:**
   - Inside workStation-projects, find and double-click the folder named **workStation**

4. **Open the dist folder:**
   - Inside workStation, find and double-click the folder named **dist**

5. **Select the chrome-extension-unpacked folder:**
   - Inside dist, find the folder named **chrome-extension-unpacked**
   - Click it ONCE to select it (don't double-click to open it)

6. **Click the "Select Folder" or "Open" button** at the bottom of the file browser

**Success:** The file browser closes, and you should now see the WorkStation extension appear in your list of extensions on the chrome://extensions/ page.

**Full path you should navigate to:**
- **Mac/Linux:** `/Users/YourUsername/workStation-projects/workStation/dist/chrome-extension-unpacked`
- **Windows:** `C:\Users\YourUsername\workStation-projects\workStation\dist\chrome-extension-unpacked`

---

### Step 10.6: Verify Extension is Loaded

**On the chrome://extensions/ page:**

Look for a card that says **"WorkStation"** or **"WorkStation AI Agent"**.

**Success:** You should see:
- ✅ The extension name
- ✅ A version number
- ✅ A toggle switch that is **ON** (blue)
- ✅ An ID below the name

---

### Step 10.7: Pin the Extension to Your Toolbar

**To make the WorkStation icon always visible:**

1. Look at the **top-right corner** of Chrome (near the minimize button)
2. Click the **puzzle piece icon** (Extensions icon)
3. A menu drops down showing your extensions
4. Find **"WorkStation"** in the list
5. Click the **pin icon** next to WorkStation (it looks like a pushpin 📌)

**Success:** The pin icon should turn blue/solid, and you should now see the WorkStation icon appear in your Chrome toolbar (top-right area).

---

## Step 11 – Connect the Extension to the Backend

### Step 11.1: Open the Extension Popup

1. Look at your Chrome toolbar (top-right area)
2. Find and click the **WorkStation icon** (it should be there after pinning in Step 10.7)

**Success:** A small popup window should appear with the WorkStation interface.

---

### Step 11.2: Go to Settings

**In the WorkStation popup:**

1. Look at the top of the popup for tabs
2. Click the **"Settings"** tab

**Success:** You should see various configuration options.

---

### Step 11.3: Enter the Backend URL

**In the Settings tab:**

1. Look for a field labeled **"Backend URL"** or **"Server URL"**
2. Click in that text field
3. If there's any existing text, delete it completely
4. Type exactly: `http://localhost:3000`
5. Make sure there are NO spaces before or after
6. Click **"Save"** (if there's a Save button) or just close the popup

**Success:** The URL should be saved. You may see a green checkmark or "Connected" message.

**IMPORTANT:** The URL `http://localhost:3000` must match the PORT number (3000) in your `.env` file from Step 5.

---

### Step 11.4: Verify Connection

**To test if the extension can reach your backend:**

1. Make sure your backend server is still running (check the terminal window from Step 9 - it should still be showing logs)
2. In the WorkStation popup, look for a connection status indicator
3. It should say **"Connected"** or show a green dot

**If it says "Disconnected" or shows a red dot:**
- Make sure the backend server is running (go back to Step 9)
- Double-check the Backend URL is exactly `http://localhost:3000`
- Try closing and reopening the popup

**Alternative verification:** Open a new terminal and type:
```bash
curl http://localhost:3000/health/live
```
If you see JSON output like `{"status":"healthy"}`, your backend is running correctly.

---

## Step 12 – Test with a Template Workflow

### Step 12.1: Verify Server is Still Running

1. Look at the terminal window where you started the server in Step 9
2. It should still be showing logs and not have stopped

**If the server stopped:**
- Go back to that terminal
- Type `npm start` and press Enter to restart it

---

### Step 12.2: Open the Extension

1. In Chrome, click the **WorkStation icon** in your toolbar (top-right corner)

**Success:** The WorkStation popup should open.

---

### Step 12.3: Go to the Templates Tab

**In the WorkStation popup:**

1. Look at the top of the popup for tabs
2. Click the **"Templates"** tab

**Success:** You should see a list of pre-built workflow templates.

---

### Step 12.4: Browse Available Templates

**In the Templates tab, you'll see options like:**

- 🔍 **Web Scraping** - Extract data from websites
- 📝 **Form Automation** - Fill and submit forms automatically
- 🎯 **Lead Capture** - Collect contact information
- 📊 **Data Extraction** - Pull structured data from pages
- 🔄 **Multi-Step Workflows** - Complex automation sequences
- And 27 more templates!

**For your first test, we recommend:** Pick a simple one like "Web Scraping" or "Data Extraction"

---

### Step 12.5: Select a Template

1. Click on one template name to select it
2. The template details should appear

**Success:** You should see a description of what the template does, and possibly some input fields.

---

### Step 12.6: Fill in Any Required Fields

**If the template has input fields:**

1. Look for fields like "URL", "Search Query", or "Data to Extract"
2. Fill them in with appropriate values
3. Example: For a web scraping template, you might enter `https://example.com`

**Success:** All required fields should be filled in (marked with * or in red if empty).

---

### Step 12.7: Execute the Template

1. Find and click the **"Execute"** or **"Run"** button (usually at the bottom of the template)

**What happens:** The workflow starts running immediately.

**Success:** You should see:
- A loading indicator or progress message
- The browser may open a new tab or window
- Automated actions begin (page loading, clicking, typing, etc.)

---

### Step 12.8: Watch the Automation Run

**While the workflow is running:**

1. **Watch the browser:** You'll see the template perform actions automatically (clicking buttons, filling forms, extracting data)
2. **Watch the extension popup:** It may show progress updates
3. **Watch the terminal:** The backend server will log what's happening

**Success:** The workflow completes without error messages.

---

### Step 12.9: View the Results

**After the workflow finishes:**

1. In the WorkStation popup, click the **"History"** tab
2. Your template execution should appear at the top of the list
3. Click on it to see details and results

**Success:** You should see:
- ✅ Execution status: "Completed" or "Success"
- ✅ Any data that was extracted
- ✅ Screenshots (if the template captured any)
- ✅ No error messages

---

## Step 13 – Use the Visual Workflow Builder

### Step 13.1: Open the Workflow Builder (Method 1 - Via Extension)

1. In Chrome, click the **WorkStation icon** in your toolbar
2. In the popup, click the **"Builder"** tab
3. Click the button labeled **"Open Builder"** or **"Launch Builder"**

**Success:** A new browser tab or window should open showing the Workflow Builder interface.

---

### Step 13.1 Alternative: Open the Workflow Builder (Method 2 - Direct URL)

**If Method 1 doesn't work, try this:**

1. In Chrome, click in the **address bar** at the top
2. Type exactly: `http://localhost:3000/workflow-builder.html`
3. Press **Enter**

**Success:** The Workflow Builder should load in your browser.

---

### Step 13.2: Understand the Builder Interface

**When the builder opens, you'll see:**

- **Left side:** A panel with available node types (building blocks)
- **Center:** A blank canvas (workspace where you'll build)
- **Right side:** Properties panel (appears when you select a node)
- **Top:** Toolbar with Save, Run, and other buttons

**Success:** You can see these three main areas clearly.

---

### Step 13.3: Add Your First Node (Navigate)

**To add a Navigate node to your workflow:**

1. Look at the **left panel** for the list of node types
2. Find the node called **"Navigate"** (it may have a 🌐 icon)
3. Click and hold on the "Navigate" node
4. Drag it onto the center canvas
5. Release the mouse button to drop it

**Success:** A "Navigate" node should now appear on your canvas with a box/card shape.

---

### Step 13.4: Add a Second Node (Extract Data)

**Now add a node to extract data:**

1. In the **left panel**, find the node called **"Extract Data"** (may have a 📊 icon)
2. Click and hold on the "Extract Data" node
3. Drag it onto the canvas (place it to the right of or below the Navigate node)
4. Release the mouse button to drop it

**Success:** You should now have TWO nodes on your canvas: "Navigate" and "Extract Data"

---

### Step 13.5: Connect the Two Nodes

**To make the nodes run in sequence:**

1. Look at the **Navigate node** on your canvas
2. Find a small circle or connector point on its right side or bottom (often called an "output port")
3. Click and hold on that connector point
4. Drag your mouse toward the **Extract Data node**
5. Find the connector point on the left side or top of the Extract Data node (the "input port")
6. Release the mouse when you're over that input port

**Success:** A line or arrow should appear connecting the two nodes, showing the flow from Navigate → Extract Data.

---

### Step 13.6: Configure the Navigate Node

**Tell the Navigate node which website to visit:**

1. Click once on the **Navigate node** (the box itself, not the connectors)
2. The **right panel** should update to show properties for this node
3. Find the field labeled **"URL"** or **"Target URL"**
4. Click in that field
5. Type a website URL, for example: `https://example.com`
6. Press Enter or click outside the field to save

**Success:** The Navigate node now knows which website to open.

---

### Step 13.7: Configure the Extract Data Node

**Tell the Extract Data node what information to collect:**

1. Click once on the **Extract Data node**
2. The **right panel** updates to show properties for this node
3. You'll see fields like:
   - **Selector:** A CSS selector or XPath to target specific elements
   - **Data Type:** What kind of data (text, attribute, etc.)
   - **Field Name:** What to call this extracted data

**Simple example:**
- **Selector:** `h1` (extracts the main heading)
- **Data Type:** `text`
- **Field Name:** `pageTitle`

4. Fill in these fields with what you want to extract
5. Click outside or press Enter to save

**Success:** The Extract Data node now knows what to grab from the page.

---

### Step 13.8: Save Your Workflow (Optional but Recommended)

**To save your workflow for later:**

1. Look at the **top toolbar**
2. Find and click the **"Save"** button (may have a 💾 icon)
3. If prompted, give your workflow a name like "My First Workflow"
4. Click "OK" or "Save"

**Success:** You should see a confirmation message that your workflow was saved.

---

### Step 13.9: Execute Your Workflow

**Now run your workflow to see it in action:**

1. Find the **"Execute"**, **"Run"**, or **"Play"** button in the top toolbar (may have a ▶️ icon)
2. Click it

**What happens:**
- A new browser tab may open
- The workflow starts running
- You'll see it navigate to your URL
- Then it extracts the data you specified

**Success:** The workflow completes without errors.

---

### Step 13.10: View the Results

**After execution finishes:**

1. Look for a **"Results"** or **"Output"** panel (may be at the bottom or right side of the builder)
2. It should show the data that was extracted
3. Example: `{ "pageTitle": "Example Domain" }`

**Success:** You can see the extracted data displayed as JSON or in a table.

---

### Available Workflow Nodes (Reference)

**When you're ready to build more complex workflows, explore these node types:**

- 🌐 **Navigate** - Go to a URL
- 📊 **Extract Data** - Pull data from page elements
- 🖱️ **Click** - Click buttons, links, or elements
- ⌨️ **Type** - Enter text into form fields
- 🔍 **Wait** - Wait for elements or conditions
- 🔄 **Loop** - Repeat actions multiple times
- 🔀 **Conditional** - Make decisions based on data
- 💾 **Store** - Save data to variables
- 📤 **Export** - Output data to files (CSV, JSON, etc.)
- 📸 **Screenshot** - Capture images of the page
- 🔄 **Refresh** - Reload the current page
- ⬅️ **Go Back** - Navigate to previous page
- ➡️ **Go Forward** - Navigate to next page in history

**To use these:** Just drag them onto the canvas, connect them, and configure their properties!

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
