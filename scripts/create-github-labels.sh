#!/bin/bash
#
# GitHub Labels Creation Script
# Purpose: Create missing labels required by Dependabot configuration
# Usage: ./scripts/create-github-labels.sh
#
# This script creates the following labels:
# - dependencies: Pull requests that update a dependency file
# - github-actions: Pull requests that update GitHub Actions code
# - production: Production dependencies
# - automated: Automated updates
#
# Prerequisites:
# - GitHub CLI (gh) installed
# - Authenticated with: gh auth login
# - Write access to the repository
#

set -euo pipefail

# Configuration
# Auto-detect repository from git remote, or use provided argument
REPO="${1:-$(git remote get-url origin 2>/dev/null | sed -e 's/.*github.com[:/]\(.*\)\.git/\1/' -e 's/.*github.com[:/]\(.*\)/\1/')}"
if [ -z "$REPO" ] || [ "$REPO" = "origin" ]; then
    REPO="credli-X/workStation"
    print_warning "Could not auto-detect repository, using default: $REPO"
fi
COLOR_BLUE="0366d6"
COLOR_BLACK="000000"
COLOR_RED="d73a4a"
COLOR_GRAY="ededed"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    print_error "Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

print_info "Creating GitHub labels for repository: $REPO"
echo ""

# Function to create label
create_label() {
    local name="$1"
    local color="$2"
    local description="$3"
    
    print_info "Creating label: $name"
    
    if gh label create "$name" \
        --repo "$REPO" \
        --color "$color" \
        --description "$description" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Created label: $name"
        return 0
    else
        # Check if it already exists (exact match using tab separator)
        if gh label list --repo "$REPO" --limit 1000 | grep -q "^$name[[:space:]]"; then
            print_warning "Label '$name' already exists"
            return 0
        else
            print_error "Failed to create label: $name"
            return 1
        fi
    fi
}

# Create labels
echo "Creating required labels..."
echo ""

FAILED=0

# Required by dependabot.yml for npm updates
create_label "dependencies" "$COLOR_BLUE" "Pull requests that update a dependency file" || FAILED=1

# Required by dependabot.yml for github-actions updates
create_label "github-actions" "$COLOR_BLACK" "Pull requests that update GitHub Actions code" || FAILED=1

# Additional labels referenced in dependabot.yml
create_label "production" "$COLOR_RED" "Production dependencies" || FAILED=1
create_label "automated" "$COLOR_GRAY" "Automated updates" || FAILED=1

echo ""

if [ $FAILED -eq 0 ]; then
    print_info "✅ All labels created successfully!"
    echo ""
    print_info "Verification:"
    echo "View labels at: https://github.com/$REPO/labels"
    echo ""
    print_info "Next steps:"
    echo "1. Verify labels appear in GitHub UI"
    echo "2. Trigger Dependabot: https://github.com/$REPO/network/updates"
    echo "3. Check for label warnings (should be gone)"
    exit 0
else
    print_error "❌ Some labels failed to create"
    echo ""
    echo "Manual creation steps:"
    echo "1. Go to: https://github.com/$REPO/labels"
    echo "2. Click 'New label'"
    echo "3. Create missing labels manually"
    exit 1
fi
