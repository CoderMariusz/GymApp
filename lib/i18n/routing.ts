import { defineRouting } from 'next-intl/routing';

/**
 * ARCHITECTURE.md §3.1 — locale-prefixed static paths only.
 * Static export has no middleware, so locale detection cannot live there.
 * `localePrefix: 'always'` keeps every route statically generable.
 */
export const routing = defineRouting({
  locales: ['en', 'pl'],
  defaultLocale: 'en',
  localePrefix: 'always',
});

export type Locale = (typeof routing.locales)[number];
