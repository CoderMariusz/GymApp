import type { MetadataRoute } from 'next';

/**
 * PWA manifest — ARCHITECTURE.md §16. Icons are a design deliverable and do not
 * exist yet (design system §7: no logo was provided, BRAND-01 open), so the
 * icons array is deliberately empty rather than filled with a placeholder mark.
 */
export const dynamic = 'force-static';

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'LifeOS',
    short_name: 'LifeOS',
    description: 'Strength-training log.',
    start_url: '/en',
    display: 'standalone',
    background_color: '#070a0f',
    theme_color: '#070a0f',
    icons: [],
  };
}
