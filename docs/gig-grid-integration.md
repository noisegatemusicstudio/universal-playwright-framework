# Gig Grid App - E2E Testing Setup

This guide shows how to integrate the universal Playwright framework with the Gig Grid application.

## Quick Setup

### 1. Add Framework as Submodule (Recommended)

```bash
# Navigate to your Gig Grid project root
cd /path/to/gig-grid-app

# Add the framework as a submodule
git submodule add https://github.com/your-org/universal-playwright-framework.git test-frameworks/playwright-framework

# Initialize and update submodules
git submodule update --init --recursive
```

### 2. Install Dependencies

```bash
# Navigate to the framework directory
cd test-frameworks/playwright-framework

# Install dependencies
npm install

# Install Playwright browsers
npx playwright install
```

### 3. Configure for Gig Grid

Create `tests/gig-grid/` directory for Gig Grid specific tests:

```bash
mkdir -p tests/gig-grid
```

### 4. Create Gig Grid Page Objects

**`tests/gig-grid/pages/fan-registration-page.ts`**

```typescript
import { BasePage } from '../../src/pages/base-page';
import { Page } from '@playwright/test';

export class FanRegistrationPage extends BasePage {
  constructor(page: Page) {
    super(page, '/fan/register');
  }

  async fillRegistrationForm(userData: any): Promise<void> {
    await this.fillInput('[data-testid="first-name-input"]', userData.firstName);
    await this.fillInput('[data-testid="last-name-input"]', userData.lastName);
    await this.fillInput('[data-testid="email-input"]', userData.email);
    await this.fillInput('[data-testid="password-input"]', userData.password);
    await this.fillInput('[data-testid="confirm-password-input"]', userData.password);
  }

  async selectPreferences(genres: string[]): Promise<void> {
    for (const genre of genres) {
      await this.clickElement(`[data-testid="genre-${genre.toLowerCase()}"]`);
    }
  }

  async submitRegistration(): Promise<void> {
    await this.clickElement('[data-testid="register-submit-btn"]');
  }

  async getErrorMessage(): Promise<string> {
    return await this.getElementText('[data-testid="error-message"]');
  }
}
```

**`tests/gig-grid/pages/artist-registration-page.ts`**

```typescript
import { BasePage } from '../../src/pages/base-page';
import { Page } from '@playwright/test';

export class ArtistRegistrationPage extends BasePage {
  constructor(page: Page) {
    super(page, '/artist/register');
  }

  async fillBasicInfo(userData: any): Promise<void> {
    await this.fillInput('[data-testid="artist-name-input"]', userData.artistName);
    await this.fillInput('[data-testid="first-name-input"]', userData.firstName);
    await this.fillInput('[data-testid="last-name-input"]', userData.lastName);
    await this.fillInput('[data-testid="email-input"]', userData.email);
    await this.fillInput('[data-testid="password-input"]', userData.password);
  }

  async fillArtistProfile(profileData: any): Promise<void> {
    await this.fillInput('[data-testid="bio-textarea"]', profileData.bio);
    await this.selectOption('[data-testid="genre-select"]', profileData.primaryGenre);
    await this.fillInput('[data-testid="location-input"]', profileData.location);
  }

  async uploadProfilePicture(imagePath: string): Promise<void> {
    await this.uploadFile('[data-testid="profile-picture-upload"]', imagePath);
  }

  async submitRegistration(): Promise<void> {
    await this.clickElement('[data-testid="artist-register-submit-btn"]');
  }
}
```

### 5. Create Gig Grid Test Data Factory

**`tests/gig-grid/fixtures/gig-grid-test-data.ts`**

```typescript
import { TestDataFactory } from '../../fixtures/test-data-factory';

export class GigGridTestData extends TestDataFactory {
  static generateFan(overrides?: any) {
    const baseUser = this.generateUser('fan');
    return {
      ...baseUser,
      preferences: {
        genres: ['rock', 'jazz', 'electronic'],
        notifications: {
          newGigs: true,
          artistUpdates: true,
          recommendations: false
        },
        location: 'Singapore'
      },
      ...overrides
    };
  }

  static generateArtist(overrides?: any) {
    const baseUser = this.generateUser('artist');
    return {
      ...baseUser,
      artistName: `${baseUser.firstName} ${baseUser.lastName} Band`,
      profile: {
        bio: 'Passionate musician creating amazing experiences for fans.',
        primaryGenre: 'rock',
        location: 'Singapore',
        socialMedia: {
          instagram: `@${baseUser.username}music`,
          spotify: `artist/${baseUser.username}`,
          youtube: `@${baseUser.username}music`
        }
      },
      ...overrides
    };
  }

  static generateGig(artistId?: string) {
    return {
      id: this.generateId(),
      title: 'Live Concert Experience',
      description: 'An unforgettable night of music and entertainment.',
      artistId: artistId || this.generateId(),
      venue: {
        name: 'Singapore Music Hall',
        address: '123 Music Street, Singapore',
        capacity: 500
      },
      dateTime: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
      ticketPrice: {
        standard: 50,
        vip: 100
      },
      genres: ['rock', 'alternative']
    };
  }
}
```

### 6. Create Gig Grid Test Specifications

**`tests/gig-grid/fan-registration.spec.ts`**

```typescript
import { test, expect } from '@playwright/test';
import { FanRegistrationPage } from './pages/fan-registration-page';
import { GigGridTestData } from './fixtures/gig-grid-test-data';

test.describe('Fan Registration', () => {
  test('should register a new fan successfully', async ({ page }) => {
    const fanData = GigGridTestData.generateFan();
    const fanRegistrationPage = new FanRegistrationPage(page);

    await fanRegistrationPage.goto();
    await fanRegistrationPage.fillRegistrationForm(fanData);
    await fanRegistrationPage.selectPreferences(fanData.preferences.genres);
    await fanRegistrationPage.submitRegistration();

    // Verify successful registration
    await expect(page).toHaveURL('/fan/dashboard');
    await expect(page.locator('[data-testid="welcome-message"]')).toContainText(fanData.firstName);
  });

  test('should show validation errors for invalid data', async ({ page }) => {
    const fanRegistrationPage = new FanRegistrationPage(page);

    await fanRegistrationPage.goto();
    await fanRegistrationPage.submitRegistration(); // Submit without filling form

    const errorMessage = await fanRegistrationPage.getErrorMessage();
    expect(errorMessage).toContain('required');
  });
});
```

**`tests/gig-grid/artist-registration.spec.ts`**

```typescript
import { test, expect } from '@playwright/test';
import { ArtistRegistrationPage } from './pages/artist-registration-page';
import { GigGridTestData } from './fixtures/gig-grid-test-data';

test.describe('Artist Registration', () => {
  test('should register a new artist successfully', async ({ page }) => {
    const artistData = GigGridTestData.generateArtist();
    const artistRegistrationPage = new ArtistRegistrationPage(page);

    await artistRegistrationPage.goto();
    await artistRegistrationPage.fillBasicInfo(artistData);
    await artistRegistrationPage.fillArtistProfile(artistData.profile);
    await artistRegistrationPage.submitRegistration();

    // Verify successful registration
    await expect(page).toHaveURL('/artist/dashboard');
    await expect(page.locator('[data-testid="artist-welcome"]')).toContainText(artistData.artistName);
  });
});
```

### 7. Update Playwright Configuration

**`playwright.config.ts`** (customize for Gig Grid):

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    // Gig Grid specific test projects
    {
      name: 'gig-grid-chromium',
      testDir: './tests/gig-grid',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'gig-grid-mobile',
      testDir: './tests/gig-grid',
      use: { ...devices['iPhone 12'] },
    },
  ],

  // Development server configuration
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### 8. Add NPM Scripts

Update your main `package.json`:

```json
{
  "scripts": {
    "test:e2e": "cd test-frameworks/playwright-framework && npm run test",
    "test:e2e:gig-grid": "cd test-frameworks/playwright-framework && npx playwright test tests/gig-grid",
    "test:e2e:headed": "cd test-frameworks/playwright-framework && npm run test:headed",
    "test:e2e:ui": "cd test-frameworks/playwright-framework && npm run test:ui"
  }
}
```

## Running Tests

```bash
# Run all Gig Grid tests
npm run test:e2e:gig-grid

# Run tests in headed mode
npm run test:e2e:headed

# Run tests with UI mode
npm run test:e2e:ui

# Run specific test file
cd test-frameworks/playwright-framework
npx playwright test tests/gig-grid/fan-registration.spec.ts
```

## CI/CD Integration

The framework will automatically work with your existing GitHub Actions. Make sure to:

1. Install dependencies in CI:
   ```yaml
   - name: Install E2E test dependencies
     run: |
       cd test-frameworks/playwright-framework
       npm ci
       npx playwright install
   ```

2. Run tests in CI:
   ```yaml
   - name: Run E2E tests
     run: npm run test:e2e:gig-grid
   ```

## Benefits of This Setup

✅ **Reusable Framework**: The core framework can be used by other projects  
✅ **Gig Grid Specific**: App-specific tests are cleanly separated  
✅ **Version Control**: Framework updates via submodule  
✅ **Type Safety**: Full TypeScript support  
✅ **Page Object Model**: Maintainable test structure  
✅ **CI/CD Ready**: Works with existing pipelines  

## Framework Updates

To update the framework:

```bash
cd test-frameworks/playwright-framework
git pull origin main
cd ../..
git add test-frameworks/playwright-framework
git commit -m "Update Playwright framework"
```

This setup gives you a professional, maintainable E2E testing solution that scales with your project!
