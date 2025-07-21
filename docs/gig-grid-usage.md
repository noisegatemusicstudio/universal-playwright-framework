# Gig Grid Application - Playwright Framework Usage

This document shows how to use the Playwright framework specifically for the Gig Grid application.

## Setup for Gig Grid

### 1. Install Framework Dependencies

```bash
cd test-frameworks/playwright-framework
npm install
npx playwright install
```

### 2. Configure Environment

Create `.env` file in the framework directory:

```bash
# Base URLs for different environments
BASE_URL_DEV=http://localhost:3000
BASE_URL_SIT=https://sit.gigrid.com
BASE_URL_UAT=https://uat.gigrid.com
BASE_URL_PROD=https://gigrid.com

# API URLs
API_URL_DEV=http://localhost:3001/api
API_URL_SIT=https://api-sit.gigrid.com
API_URL_UAT=https://api-uat.gigrid.com
API_URL_PROD=https://api.gigrid.com

# Test configuration
LOG_LEVEL=INFO
HEADLESS=true
BROWSER=chromium

# AWS SES Test Configuration
TEST_EMAIL_DOMAIN=example.amazonses.com
```

## Page Objects for Gig Grid

### User Registration Page

```typescript
// gig-grid-pages/user-registration-page.ts
import { BasePage } from '@/pages/base-page';
import { Page, Locator } from '@playwright/test';
import { UserData } from '@fixtures/test-data-factory';

export class GigGridUserRegistrationPage extends BasePage {
  private readonly firstNameInput: Locator;
  private readonly lastNameInput: Locator;
  private readonly emailInput: Locator;
  private readonly phoneInput: Locator;
  private readonly passwordInput: Locator;
  private readonly userTypeFan: Locator;
  private readonly userTypeBand: Locator;
  private readonly userTypeSoloArtist: Locator;
  private readonly genreSelect: Locator;
  private readonly submitButton: Locator;
  private readonly successMessage: Locator;
  private readonly errorMessage: Locator;

  constructor(page: Page) {
    super(page, '/register');
    
    this.firstNameInput = page.locator('[data-testid="first-name-input"]');
    this.lastNameInput = page.locator('[data-testid="last-name-input"]');
    this.emailInput = page.locator('[data-testid="email-input"]');
    this.phoneInput = page.locator('[data-testid="phone-input"]');
    this.passwordInput = page.locator('[data-testid="password-input"]');
    this.userTypeFan = page.locator('[data-testid="user-type-fan"]');
    this.userTypeBand = page.locator('[data-testid="user-type-band"]');
    this.userTypeSoloArtist = page.locator('[data-testid="user-type-solo-artist"]');
    this.genreSelect = page.locator('[data-testid="genre-select"]');
    this.submitButton = page.locator('[data-testid="register-submit"]');
    this.successMessage = page.locator('[data-testid="registration-success"]');
    this.errorMessage = page.locator('[data-testid="registration-error"]');
  }

  async registerUser(userData: UserData): Promise<void> {
    this.logger.step(`Registering ${userData.userType}: ${userData.email}`);
    
    await this.fillInput(this.firstNameInput, userData.firstName);
    await this.fillInput(this.lastNameInput, userData.lastName);
    await this.fillInput(this.emailInput, userData.email);
    await this.fillInput(this.phoneInput, userData.phone);
    await this.fillInput(this.passwordInput, userData.password);
    
    await this.selectUserType(userData.userType);
    
    if (userData.genre) {
      await this.selectGenres(userData.genre);
    }
    
    await this.clickElement(this.submitButton);
  }

  private async selectUserType(userType: string): Promise<void> {
    switch (userType) {
      case 'fan':
        await this.clickElement(this.userTypeFan);
        break;
      case 'band':
        await this.clickElement(this.userTypeBand);
        break;
      case 'solo_artist':
        await this.clickElement(this.userTypeSoloArtist);
        break;
    }
  }

  private async selectGenres(genres: string[]): Promise<void> {
    await this.clickElement(this.genreSelect);
    for (const genre of genres) {
      await this.clickElement(this.page.locator(`[data-value="${genre}"]`));
    }
  }

  async isRegistrationSuccessful(): Promise<boolean> {
    return await this.isElementVisible(this.successMessage);
  }

  async getErrorMessage(): Promise<string> {
    return await this.getElementText(this.errorMessage);
  }
}
```

## Example Tests

### User Registration Tests

```typescript
// tests/e2e/user-registration.spec.ts
import { test, expect } from '@playwright/test';
import { TestDataFactory, UserData } from '@fixtures/test-data-factory';
import { GigGridUserRegistrationPage } from '../pages/gig-grid-user-registration-page';

test.describe('Gig Grid User Registration', () => {
  
  test.describe('Fan Registration', () => {
    test('should register fan with valid data', async ({ page }) => {
      const fanData = TestDataFactory.generateUser('fan');
      const registrationPage = new GigGridUserRegistrationPage(page);

      await registrationPage.goto();
      await registrationPage.registerUser(fanData);

      await expect(registrationPage.successMessage).toBeVisible();
      await expect(page).toHaveURL('/dashboard');
    });

    test('should show error for duplicate email', async ({ page }) => {
      const fanData = TestDataFactory.generateUser('fan');
      
      // Use existing email from test data
      fanData.email = 'existing-fan@example.amazonses.com';
      
      const registrationPage = new GigGridUserRegistrationPage(page);
      await registrationPage.goto();
      await registrationPage.registerUser(fanData);

      await expect(registrationPage.errorMessage).toBeVisible();
      expect(await registrationPage.getErrorMessage()).toContain('email already exists');
    });
  });

  test.describe('Band Registration', () => {
    test('should register band with members', async ({ page }) => {
      const bandData = TestDataFactory.generateUser('band');
      const registrationPage = new GigGridUserRegistrationPage(page);

      await registrationPage.goto();
      await registrationPage.registerUser(bandData);

      await expect(registrationPage.successMessage).toBeVisible();
      
      // Verify band-specific fields were processed
      await expect(page.locator('[data-testid="band-profile"]')).toBeVisible();
    });
  });

  test.describe('Solo Artist Registration', () => {
    test('should register solo artist with instruments', async ({ page }) => {
      const artistData = TestDataFactory.generateUser('solo_artist');
      const registrationPage = new GigGridUserRegistrationPage(page);

      await registrationPage.goto();
      await registrationPage.registerUser(artistData);

      await expect(registrationPage.successMessage).toBeVisible();
      
      // Verify artist-specific fields
      await expect(page.locator('[data-testid="artist-profile"]')).toBeVisible();
    });
  });
});
```

### User Sign-in Tests

```typescript
// tests/e2e/user-signin.spec.ts
import { test, expect } from '@playwright/test';
import { TestDataFactory } from '@fixtures/test-data-factory';
import { GigGridLoginPage } from '../pages/gig-grid-login-page';
import { GigGridDashboardPage } from '../pages/gig-grid-dashboard-page';

test.describe('Gig Grid User Sign-in', () => {
  
  test('should login with valid credentials', async ({ page }) => {
    const userData = TestDataFactory.generateUser('fan');
    const loginPage = new GigGridLoginPage(page);

    await loginPage.goto();
    await loginPage.login(userData.email, userData.password);

    const dashboardPage = new GigGridDashboardPage(page);
    await expect(dashboardPage.welcomeMessage).toBeVisible();
    await expect(page).toHaveURL('/dashboard');
  });

  test('should show error for invalid credentials', async ({ page }) => {
    const loginPage = new GigGridLoginPage(page);

    await loginPage.goto();
    await loginPage.login('invalid@example.com', 'wrongpassword');

    await expect(loginPage.errorMessage).toBeVisible();
    expect(await loginPage.getErrorMessage()).toContain('Invalid credentials');
  });

  test('should lock account after failed attempts', async ({ page }) => {
    const loginPage = new GigGridLoginPage(page);
    const invalidData = TestDataFactory.generateUser('fan');
    invalidData.password = 'wrongpassword';

    await loginPage.goto();

    // Attempt login 3 times with wrong password
    for (let i = 0; i < 3; i++) {
      await loginPage.login(invalidData.email, invalidData.password);
      await expect(loginPage.errorMessage).toBeVisible();
    }

    // Fourth attempt should show account locked
    await loginPage.login(invalidData.email, invalidData.password);
    await expect(loginPage.errorMessage).toContainText('Account locked');
  });

  test('should allow password reset', async ({ page }) => {
    const userData = TestDataFactory.generateUser('fan');
    const loginPage = new GigGridLoginPage(page);

    await loginPage.goto();
    await loginPage.clickForgotPassword();
    await loginPage.enterResetEmail(userData.email);
    await loginPage.submitPasswordReset();

    await expect(page.locator('[data-testid="reset-email-sent"]')).toBeVisible();
  });
});
```

## API Testing Integration

```typescript
// tests/api/user-api.spec.ts
import { test, expect } from '@playwright/test';
import { ApiClient } from '@api/api-client';
import { TestDataFactory } from '@fixtures/test-data-factory';

test.describe('Gig Grid User API', () => {
  let apiClient: ApiClient;

  test.beforeAll(async () => {
    apiClient = new ApiClient(process.env.API_URL_DEV!);
    await apiClient.init();
  });

  test.afterAll(async () => {
    await apiClient.dispose();
  });

  test('should create user via API', async () => {
    const userData = TestDataFactory.generateUser('fan');

    const response = await apiClient.post('/users', userData);

    expect(response.ok).toBe(true);
    expect(response.data.email).toBe(userData.email);
    expect(response.data.userType).toBe('fan');

    // Cleanup
    await apiClient.delete(`/users/${response.data.id}`);
  });

  test('should authenticate user via API', async () => {
    const userData = TestDataFactory.generateUser('fan');
    
    // Create user
    const createResponse = await apiClient.post('/users', userData);
    expect(createResponse.ok).toBe(true);

    // Authenticate
    const authResponse = await apiClient.post('/auth/login', {
      email: userData.email,
      password: userData.password
    });

    expect(authResponse.ok).toBe(true);
    expect(authResponse.data.token).toBeDefined();

    // Cleanup
    await apiClient.delete(`/users/${createResponse.data.id}`);
  });
});
```

## Running Tests

### Development Environment

```bash
# Run all tests in development
npm test

# Run specific test suite
npm test tests/e2e/user-registration.spec.ts

# Run with UI mode for debugging
npm run test:ui

# Run in headed mode
npm run test:headed
```

### Different Environments

```bash
# Run tests against SIT environment
BASE_URL=https://sit.gigrid.com npm test

# Run tests against UAT environment
BASE_URL=https://uat.gigrid.com npm test

# Run specific browser
npm run test:firefox
npm run test:safari
```

### CI/CD Integration

The framework includes GitHub Actions workflow that will:
1. Install dependencies
2. Run all tests
3. Generate reports
4. Upload artifacts
5. Send notifications

## Best Practices for Gig Grid

1. **Use Amazon SES Test Domain**: Always use `@example.amazonses.com` for test emails
2. **Test Data Cleanup**: Clean up test users and events after tests
3. **Environment Isolation**: Use different test data for each environment
4. **Mobile Testing**: Test responsive design for mobile users
5. **Performance Testing**: Monitor page load times for events listing
6. **Visual Testing**: Validate UI components and layouts
7. **API Integration**: Combine UI and API tests for complete coverage

This framework provides a solid foundation for testing the Gig Grid application across all its features and environments.
