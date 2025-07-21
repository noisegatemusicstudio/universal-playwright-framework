#!/bin/bash

# Universal Playwright Framework Initialization Script
# Run this script to set up the framework for first use in any project

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BOLD}🎭 Initializing Universal Playwright Framework${NC}"
echo -e "${BLUE}   Plug-and-play E2E testing for any web application${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${YELLOW}⚠️  Please run this script from the playwright-framework directory${NC}"
    exit 1
fi

echo -e "${BOLD}1. Installing framework dependencies...${NC}"
npm install

echo -e "${BOLD}2. Installing Playwright browsers...${NC}"
npx playwright install

echo -e "${BOLD}3. Creating required directories...${NC}"
mkdir -p screenshots
mkdir -p screenshots/components
mkdir -p reports
mkdir -p playwright/.auth
mkdir -p test-results
mkdir -p allure-results

echo -e "${BOLD}4. Setting up generic environment file...${NC}"
if [ ! -f ".env" ]; then
    cat > .env << EOF
# Base URLs for different environments (update for your app)
BASE_URL_DEV=http://localhost:3000
BASE_URL_STAGING=https://staging.yourapp.com
BASE_URL_UAT=https://uat.yourapp.com
BASE_URL_PROD=https://yourapp.com

# API URLs (update for your app)
API_URL_DEV=http://localhost:3001/api
API_URL_STAGING=https://api-staging.yourapp.com
API_URL_UAT=https://api-uat.yourapp.com
API_URL_PROD=https://api.yourapp.com

# Test configuration
LOG_LEVEL=INFO
HEADLESS=true
BROWSER=chromium

# Test data configuration (update for your app)
TEST_EMAIL_DOMAIN=yourdomain.com
APP_NAME=YourAwesomeApp

# CI/CD flags
CI=false
EOF
    echo -e "${GREEN}✅ Created generic .env file${NC}"
    echo -e "${YELLOW}📝 Please update .env with your app-specific URLs and settings${NC}"
else
    echo -e "${YELLOW}⚠️  .env file already exists, skipping${NC}"
fi

echo -e "${BOLD}5. Building TypeScript...${NC}"
npm run build

echo -e "${BOLD}6. Running initial linting...${NC}"
npm run lint || echo -e "${YELLOW}⚠️  Some linting issues found, run 'npm run lint:fix' to fix them${NC}"

echo ""
echo -e "${GREEN}🎉 Universal Playwright Framework initialization complete!${NC}"
echo ""
echo -e "${BOLD}🚀 Next Steps for Your App:${NC}"
echo -e "${BLUE}1. Update .env file with your app-specific URLs${NC}"
echo -e "${BLUE}2. Create playwright.config.ts in your app root${NC}"
echo -e "${BLUE}3. Create your app-specific page objects in your tests/ directory${NC}"
echo -e "${BLUE}4. Write your first E2E test${NC}"
echo ""
echo -e "${BOLD}📚 Documentation:${NC}"
echo "• docs/quick-start.md       - 5-minute setup guide"
echo "• docs/page-object-model.md - Page Object Model guide"
echo "• docs/writing-tests.md     - How to write tests"
echo ""
echo -e "${BOLD}🧪 Framework Commands (for testing the framework itself):${NC}"
echo "• npm test                 - Run all tests"
echo "• npm run test:ui          - Open test UI"
echo "• npm run test:headed      - Run tests in headed mode"
echo "• npm run test:chromium    - Run tests in Chromium only"
echo "• npm run report           - View HTML report"
echo "• npm run lint             - Check code quality"
echo "• npm run format           - Format code"
