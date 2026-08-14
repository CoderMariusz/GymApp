import createNextIntlPlugin from 'next-intl/plugin';
import type { NextConfig } from 'next';

/**
 * ADR-02: `output: 'export'`. The app ships as static assets so Capacitor (v1.1)
 * can package them and nothing depends on a Next request-time runtime.
 *
 * Forbidden as a consequence (ARCHITECTURE.md §3): API routes needing Node at
 * runtime, middleware for locale/auth, request cookies/headers in server-rendered
 * routes, dynamic server actions, request-time image optimisation.
 */
const nextConfig: NextConfig = {
  output: 'export',
  reactStrictMode: true,
  // ARCHITECTURE.md §3.2 — no request-time optimiser under static export.
  images: { unoptimized: true },
  typescript: { ignoreBuildErrors: false },
  // Next 16 removed the `eslint` config key (and `next lint`). Linting runs as a
  // separate `npm run lint` step inside `verify` — ARCHITECTURE.md §19.1.
};

export default createNextIntlPlugin('./lib/i18n/request.ts')(nextConfig);
