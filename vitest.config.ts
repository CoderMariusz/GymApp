import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';
import { fileURLToPath } from 'node:url';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    include: ['{app,features,lib,components}/**/*.{test,spec}.{ts,tsx}'],
    // ARCHITECTURE.md §18.3 — no global vanity coverage target.
    coverage: { reporter: ['text', 'lcov'], include: ['lib/**', 'features/**'] },
  },
  resolve: {
    alias: { '@': fileURLToPath(new URL('.', import.meta.url)) },
  },
});
