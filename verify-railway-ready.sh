#!/bin/bash

# Railway Readiness Verification Script
# Tests all critical components before deployment

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Workstation AI Agent - Railway Readiness Verification   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CHECKS_PASSED=0
CHECKS_FAILED=0

check_pass() {
    echo -e "${GREEN}✅ PASS${NC} - $1"
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "${RED}❌ FAIL${NC} - $1"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC} - $1"
}

echo "Running pre-deployment checks..."
echo ""

# Check 1: Node.js version
echo "1. Checking Node.js version..."
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -ge 18 ]; then
    check_pass "Node.js version $NODE_VERSION (>= 18 required)"
else
    check_fail "Node.js version $NODE_VERSION (>= 18 required)"
fi

# Check 2: Dependencies installed
echo "2. Checking dependencies..."
if [ -d "node_modules" ]; then
    check_pass "node_modules directory exists"
else
    check_warn "node_modules not found, running npm install..."
    npm install > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        check_pass "Dependencies installed successfully"
    else
        check_fail "Failed to install dependencies"
    fi
fi

# Check 3: TypeScript compilation
echo "3. Testing TypeScript build..."
npm run build > /tmp/build.log 2>&1
if [ $? -eq 0 ]; then
    check_pass "TypeScript compilation successful"
else
    check_fail "TypeScript compilation failed (see /tmp/build.log)"
    cat /tmp/build.log
fi

# Check 4: Dist directory created
echo "4. Checking build output..."
if [ -d "dist" ] && [ -f "dist/index.js" ]; then
    check_pass "dist/index.js exists"
else
    check_fail "dist/index.js not found"
fi

# Check 5: Railway configuration
echo "5. Checking Railway configuration..."
if [ -f "railway.json" ]; then
    check_pass "railway.json exists"
    
    # Validate JSON syntax
    if command -v node > /dev/null; then
        node -e "JSON.parse(require('fs').readFileSync('railway.json', 'utf8'))" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            check_pass "railway.json is valid JSON"
        else
            check_fail "railway.json is invalid JSON"
        fi
    fi
else
    check_fail "railway.json not found"
fi

# Check 6: Security audit
echo "6. Running security audit..."
npm audit --audit-level=moderate > /tmp/audit.log 2>&1
if [ $? -eq 0 ]; then
    check_pass "No security vulnerabilities found"
else
    VULN_COUNT=$(grep -c "vulnerability" /tmp/audit.log || echo "0")
    if [ "$VULN_COUNT" -gt 0 ]; then
        check_warn "$VULN_COUNT vulnerabilities found (run 'npm audit fix')"
    else
        check_pass "Security audit passed"
    fi
fi

# Check 7: UI dashboards exist
echo "7. Checking UI dashboards..."
UI_FILES=("public/dashboard.html" "public/workflow-builder.html" "public/gemini-dashboard.html" "public/setup.html")
UI_COUNT=0
for file in "${UI_FILES[@]}"; do
    if [ -f "$file" ]; then
        ((UI_COUNT++))
    fi
done

if [ $UI_COUNT -eq 4 ]; then
    check_pass "All 4 UI dashboards present"
elif [ $UI_COUNT -gt 0 ]; then
    check_warn "$UI_COUNT/4 UI dashboards found"
else
    check_fail "No UI dashboards found in public/"
fi

# Check 8: Chrome extensions
echo "8. Checking Chrome extensions..."
if [ -f "dist/workstation-ai-agent-v2.1.0.zip" ] && [ -f "dist/workstation-ai-agent-enterprise-v2.1.0.zip" ]; then
    check_pass "Chrome extensions packaged (2 files)"
else
    check_warn "Chrome extensions not found (may need rebuild)"
fi

# Check 9: Core automation agents
echo "9. Checking automation agents..."
AGENT_COUNT=$(find src/automation/agents -name "*.ts" | wc -l)
if [ "$AGENT_COUNT" -ge 15 ]; then
    check_pass "$AGENT_COUNT automation agents found"
else
    check_warn "Only $AGENT_COUNT agents found (expected 15+)"
fi

# Check 10: Documentation
echo "10. Checking documentation..."
DOC_FILES=("RAILWAY_DEPLOYMENT.md" "RAILWAY_READY_SUMMARY.md" "README.md" "API.md")
DOC_COUNT=0
for file in "${DOC_FILES[@]}"; do
    if [ -f "$file" ]; then
        ((DOC_COUNT++))
    fi
done

if [ $DOC_COUNT -eq 4 ]; then
    check_pass "All deployment documentation present"
else
    check_warn "$DOC_COUNT/4 documentation files found"
fi

# Check 11: Package.json scripts
echo "11. Checking required npm scripts..."
REQUIRED_SCRIPTS=("start" "build" "dev")
SCRIPT_COUNT=0
for script in "${REQUIRED_SCRIPTS[@]}"; do
    if grep -q "\"$script\":" package.json; then
        ((SCRIPT_COUNT++))
    fi
done

if [ $SCRIPT_COUNT -eq 3 ]; then
    check_pass "All required npm scripts present"
else
    check_warn "$SCRIPT_COUNT/3 npm scripts found"
fi

# Check 12: Environment template
echo "12. Checking environment configuration..."
if [ -f ".env.example" ]; then
    check_pass ".env.example template exists"
else
    check_warn ".env.example not found (optional)"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    Verification Summary                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Passed:${NC} $CHECKS_PASSED"
echo -e "${RED}Failed:${NC} $CHECKS_FAILED"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ ALL CHECKS PASSED - READY FOR RAILWAY DEPLOYMENT  ✅  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Push to GitHub: git push origin main"
    echo "2. Connect to Railway: https://railway.app"
    echo "3. Deploy from GitHub repo"
    echo "4. Access app at: https://your-app.railway.app"
    echo ""
    echo "For detailed instructions, see: RAILWAY_DEPLOYMENT.md"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ SOME CHECKS FAILED - PLEASE FIX BEFORE DEPLOYING  ❌  ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please address the failed checks above before deploying."
    exit 1
fi
