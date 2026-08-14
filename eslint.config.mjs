import next from 'eslint-config-next';
import boundaries from 'eslint-plugin-boundaries';

/**
 * ARCHITECTURE.md §4.1 — feature boundary.
 * A feature is reachable only through `features/<name>/index.ts`; `history`
 * must not import `features/workouts/components/*`.
 *
 * §23 — forbidden shortcuts, enforced mechanically where a linter can:
 * no Supabase writes outside the mutation gateway, no `@supabase/ssr`.
 */
const config = [
  ...next,
  {
    plugins: { boundaries },
    settings: {
      // eslint-plugin-boundaries resolves through eslint-module-utils, which needs
      // the legacy resolver interface — hence resolver v3, not v4.
      'import/resolver': {
        typescript: { alwaysTryTypes: true, project: './tsconfig.json' },
      },
      'boundaries/elements': [
        { type: 'app', pattern: 'app/**' },
        { type: 'feature', pattern: 'features/*', capture: ['name'] },
        { type: 'lib', pattern: 'lib/**' },
        { type: 'components', pattern: 'components/**' },
      ],
    },
    rules: {
      'boundaries/dependencies': [
        'error',
        {
          default: 'disallow',
          message: 'ARCHITECTURE.md §4.1: {{file.type}} must not depend on {{dependency.type}}.',
          policies: [
            {
              from: { element: { type: 'app' } },
              allow: { to: { element: { types: { anyOf: ['feature', 'lib', 'components'] } } } },
            },
            {
              from: { element: { type: 'feature' } },
              allow: { to: { element: { types: { anyOf: ['lib', 'components'] } } } },
            },
            {
              from: { element: { type: 'lib' } },
              allow: { to: { element: { type: 'lib' } } },
            },
            {
              from: { element: { type: 'components' } },
              allow: { to: { element: { types: { anyOf: ['components', 'lib'] } } } },
            },
          ],
        },
      ],
      'no-restricted-imports': [
        'error',
        {
          paths: [
            {
              name: '@supabase/ssr',
              message:
                'ADR-21: a static browser app has no SSR auth layer. Use @supabase/supabase-js.',
            },
          ],
          patterns: [
            {
              group: ['@/features/*/*', '**/features/*/*'],
              message:
                'ARCHITECTURE.md §4.1: import a feature through its index only — @/features/<name>.',
            },
            {
              group: ['@/lib/supabase/client', '**/lib/supabase/client'],
              message:
                'ARCHITECTURE.md §6: features never write to Supabase directly. Go through lib/mutations.',
            },
          ],
        },
      ],
    },
  },
  {
    // The gateway layer is the one place allowed to reach the Supabase client.
    files: ['lib/mutations/**', 'lib/supabase/**', 'lib/sync/**', 'lib/auth/**'],
    rules: { 'no-restricted-imports': 'off' },
  },
  { ignores: ['.next/**', 'out/**', 'node_modules/**', 'supabase/**', '.claude/**', 'public/**'] },
];

export default config;
