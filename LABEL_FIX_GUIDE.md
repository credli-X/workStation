# GitHub Labels Fix Guide

## Problem Statement

Dependabot is reporting that the following labels are missing from the repository:
- `dependencies`
- `github-actions`

These labels are referenced in `.github/dependabot.yml` but don't exist in the GitHub repository.

---

## ⚡ Automated Solution (Recommended)

### Option A: GitHub Actions Workflow (Zero Setup)

1. **Trigger the automated workflow:**
   ```
   https://github.com/credli-X/workStation/actions/workflows/create-labels.yml
   ```

2. **Click "Run workflow"** button (top right)

3. **Select options:**
   - Branch: `main` (or current branch)
   - Dry run: `false` (to actually create labels)

4. **Click "Run workflow"** (green button)

5. **Wait 30 seconds** - Workflow will:
   - Check if labels exist
   - Create missing labels automatically
   - Show summary of results

6. **Verify:** Check https://github.com/credli-X/workStation/labels

### Option B: Local Script (Requires gh CLI)

If you have the repository cloned and `gh` CLI authenticated:

```bash
# From repository root
./scripts/create-github-labels.sh
```

**Prerequisites:**
- GitHub CLI installed: https://cli.github.com/
- Authenticated: `gh auth login`
- Write access to repository

---

## Manual Fix (5 minutes)

### Using GitHub Web UI

1. **Navigate to Labels Page:**
   ```
   https://github.com/credli-X/workStation/labels
   ```

2. **Click "New label"** (green button in top right)

3. **Create Label #1:**
   - **Name:** `dependencies`
   - **Description:** `Pull requests that update a dependency file`
   - **Color:** `#0366d6` (blue)
   - Click **"Create label"**

4. **Create Label #2:**
   - **Name:** `github-actions`
   - **Description:** `Pull requests that update GitHub Actions code`
   - **Color:** `#000000` (black)
   - Click **"Create label"**

5. **Verify:** Return to the labels page and confirm both labels appear

---

## Alternative: Using GitHub CLI

If you have `gh` CLI installed and authenticated:

```bash
# Create dependencies label
gh label create "dependencies" \
  --repo credli-X/workStation \
  --color "0366d6" \
  --description "Pull requests that update a dependency file"

# Create github-actions label
gh label create "github-actions" \
  --repo credli-X/workStation \
  --color "000000" \
  --description "Pull requests that update GitHub Actions code"

# Verify labels were created
gh label list --repo credli-X/workStation | grep -E "dependencies|github-actions"
```

---

## Alternative: Using GitHub API

```bash
# Set your GitHub token
export GITHUB_TOKEN="your_personal_access_token"

# Create dependencies label
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/credli-X/workStation/labels \
  -d '{
    "name": "dependencies",
    "description": "Pull requests that update a dependency file",
    "color": "0366d6"
  }'

# Create github-actions label
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/credli-X/workStation/labels \
  -d '{
    "name": "github-actions",
    "description": "Pull requests that update GitHub Actions code",
    "color": "000000"
  }'
```

---

## Why These Labels Are Important

### `dependencies` Label
- **Purpose:** Automatically tags PRs that update npm packages, Docker images, etc.
- **Used by:** Dependabot npm updates, Docker updates
- **Benefit:** Easy filtering of dependency updates in PR list

### `github-actions` Label  
- **Purpose:** Tags PRs that update GitHub Actions workflows
- **Used by:** Dependabot github-actions updates (like this PR!)
- **Benefit:** Track workflow changes separately from code changes

---

## Impact of Not Creating Labels

### Current State (Labels Missing)
- ❌ Dependabot shows warning in logs
- ❌ PRs created without labels
- ✅ PRs still function correctly
- ✅ Can be merged without issues

### After Creating Labels
- ✅ No Dependabot warnings
- ✅ PRs automatically tagged
- ✅ Better PR organization
- ✅ Easier to filter and review

---

## Other Labels Referenced in dependabot.yml

The following labels are also used but may already exist:
- `production` - Used for npm production dependency updates
- `automated` - Used for npm automated updates

**Check if these exist:** https://github.com/credli-X/workStation/labels

If missing, create them too:
```bash
gh label create "production" --color "d73a4a" --description "Production dependencies"
gh label create "automated" --color "ededed" --description "Automated updates"
```

---

## Verification Steps

After creating labels:

1. **Check Labels Page:**
   ```
   https://github.com/credli-X/workStation/labels
   ```
   Confirm all 4 labels exist: `dependencies`, `github-actions`, `production`, `automated`

2. **Trigger Dependabot Check:**
   - Go to: https://github.com/credli-X/workStation/network/updates
   - Click "Check for updates" on any ecosystem
   - Verify no label warnings appear

3. **Apply Labels to This PR:**
   - Navigate to this PR
   - In the right sidebar, click "Labels"
   - Add: `dependencies` and `github-actions`

---

## Troubleshooting

### "Label already exists" Error
If you get this error, the label exists but might have different casing:
```bash
# List all labels to find it
gh label list | grep -i dependencies

# Delete the old one if wrong
gh label delete "Dependencies" --yes

# Create the correct one
gh label create "dependencies" --color "0366d6" --description "..."
```

### Permission Denied
You need `write` access to the repository to create labels:
- **Admin:** Full label management
- **Maintain:** Can create/edit labels
- **Write:** Can create labels
- **Read:** Cannot create labels ❌

If you don't have permission, ask a repository admin to create the labels.

---

## Recommended Label Scheme (Bonus)

Consider adding these standard labels for better organization:

```bash
# Dependency types
gh label create "npm" --color "cb2431" --description "NPM package updates"
gh label create "docker" --color "0db7ed" --description "Docker image updates"

# Priority levels
gh label create "critical" --color "b60205" --description "Critical updates (security)"
gh label create "enhancement" --color "a2eeef" --description "New feature or request"

# Automation
gh label create "bot" --color "e4e669" --description "Automated bot updates"
```

---

## Next Steps

1. ✅ **Create the two missing labels** (5 minutes)
2. ✅ **Verify Dependabot warnings are gone**
3. ✅ **Apply labels to this PR**
4. ✅ **Merge this PR** (upload-artifact v6 is fully compatible)

---

## Support

- **Dependabot Docs:** https://docs.github.com/en/code-security/dependabot
- **GitHub Labels API:** https://docs.github.com/en/rest/issues/labels
- **This Repository:** https://github.com/credli-X/workStation
