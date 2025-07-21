/**
 * Development environment configuration
 */

import { PlaywrightTestConfig } from '@playwright/test';
import baseConfig from '../playwright.config';

const config: PlaywrightTestConfig = {
  ...baseConfig,
  
  use: {
    ...baseConfig.use,
    baseURL: 'http://localhost:3000',
  },

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },

  projects: [
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
    },
    {
      name: 'dev-chromium',
      use: { 
        ...baseConfig.projects?.[1]?.use,
        baseURL: 'http://localhost:3000',
      },
      dependencies: ['setup'],
    }
  ],

  // Enable debug mode in development
  workers: 1,
  retries: 0,
  reporter: [
    ['list'],
    ['html', { open: 'on-failure' }]
  ],
};

export default config;
