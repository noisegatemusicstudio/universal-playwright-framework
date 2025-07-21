# 🚀 Quick Start Guide

Get your E2E tests running in **5 minutes** with this universal Playwright framework!

## 🏃‍♂️ Super Quick Setup

### For Any Web App

```bash
# 1. Add framework to your project
git submodule add https://github.com/universal-testing/playwright-framework.git test-frameworks/playwright-framework

# 2. Initialize framework
cd test-frameworks/playwright-framework
chmod +x scripts/init.sh
./scripts/init.sh

# 3. Back to your app root
cd ../..

# 4. Create your Playwright config
cat > playwright.config.ts << 'EOF'
import { defineConfig } from '@playwright/test';
import baseConfig from './test-frameworks/playwright-framework/playwright.config';

export default defineConfig({
  ...baseConfig,
  use: {
    ...baseConfig.use,
    baseURL: 'http://localhost:3000', // 👈 Your app URL
  },
  testDir: './tests', // 👈 Your tests directory
  webServer: {
    command: 'npm run dev', // 👈 Your dev server command
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
EOF

# 5. Create your first test
mkdir -p tests/pages tests/e2e

# Create a simple page object
cat > tests/pages/home-page.ts << 'EOF'
import { BasePage } from '../../test-frameworks/playwright-framework/src/pages/base-page';
import { Page, Locator } from '@playwright/test';

export class HomePage extends BasePage {
  private readonly title: Locator;

  constructor(page: Page) {
    super(page, '/');
    this.title = page.locator('h1'); // 👈 Adjust for your app
  }

  async getTitle(): Promise<string> {
    return await this.getElementText(this.title);
  }
}
EOF

# Create your first test
cat > tests/e2e/homepage.spec.ts << 'EOF'
import { test, expect } from '@playwright/test';
import { HomePage } from '../pages/home-page';

test.describe('Homepage Tests', () => {
  test('should display homepage title', async ({ page }) => {
    const homePage = new HomePage(page);
    
    await homePage.goto();
    const title = await homePage.getTitle();
    
    expect(title).toBeTruthy();
  });
});
EOF

# 6. Add test scripts to package.json
npm pkg set scripts.test:e2e="playwright test"
npm pkg set scripts.test:e2e:ui="playwright test --ui"
npm pkg set scripts.test:e2e:headed="playwright test --headed"

# 7. Install Playwright in your project
npm install -D @playwright/test

# 8. Run your first test!
npm run test:e2e
```

## 🎯 What You Get

After running the above commands, you'll have:

✅ **Complete E2E testing setup**  
✅ **Page Object Model structure**  
✅ **Multi-browser support**  
✅ **Screenshot/video recording**  
✅ **Rich reporting**  
✅ **TypeScript support**  
✅ **CI/CD ready configuration**  

## 🔧 Customize for Your App

### 1. Update Your Page Objects
```typescript
// tests/pages/login-page.ts
import { BasePage } from '../../test-frameworks/playwright-framework/src/pages/base-page';

export class LoginPage extends BasePage {
  constructor(page: Page) {
    super(page, '/login');
    // Add your app-specific selectors here
  }
  
  async login(email: string, password: string): Promise<void> {
    // Add your app-specific login logic
  }
}
```

### 2. Create Your Test Data
```typescript
// tests/fixtures/app-data.ts
import { TestDataFactory } from '../../test-frameworks/playwright-framework/fixtures/test-data-factory';

export class AppDataFactory extends TestDataFactory {
  static generateProduct() {
    return {
      name: 'Test Product',
      price: 99.99,
      // Add your app-specific fields
    };
  }
}
```

### 3. Write Your Tests
```typescript
// tests/e2e/user-flow.spec.ts
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/login-page';
import { AppDataFactory } from '../fixtures/app-data';

test.describe('User Flow', () => {
  test('should complete user journey', async ({ page }) => {
    const userData = AppDataFactory.generateUser();
    const loginPage = new LoginPage(page);
    
    await loginPage.goto();
    await loginPage.login(userData.email, userData.password);
    
    // Add your test steps
    await expect(page).toHaveURL('/dashboard');
  });
});
```

## 🚀 Next Steps

1. **📚 Read the docs**: Check `test-frameworks/playwright-framework/docs/`
2. **🎯 Add more tests**: Create page objects for your app's key pages
3. **⚙️ Configure environments**: Set up staging/production configs
4. **🔄 Set up CI/CD**: Use the included GitHub Actions workflow
5. **📊 Explore reporting**: Try Allure reports with `npm run report:allure`

## 💡 Pro Tips

- **Use data-testid attributes** for reliable selectors
- **Keep page objects simple** and focused
- **Generate test data** instead of hardcoding
- **Run tests in parallel** for faster feedback
- **Take screenshots** for debugging failures

## 🆘 Need Help?

- 📖 **Documentation**: `test-frameworks/playwright-framework/docs/`
- 🐛 **Issues**: Create an issue in the framework repository
- 💬 **Community**: Join our discussions

---

**🎉 You're all set! Start building awesome E2E tests!**
