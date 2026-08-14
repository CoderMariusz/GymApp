import { describe, expect, it } from 'vitest';
import en from '../../messages/en.json';
import pl from '../../messages/pl.json';

/** PRD CORE-07 — the six states the UI must distinguish, by their exact names. */
const CORE_07_SYNC_STATES = [
  'draft_local',
  'saved',
  'queued',
  'syncing',
  'failed',
  'conflict',
] as const;

function flatten(obj: object, prefix = ''): string[] {
  return Object.entries(obj).flatMap(([k, v]) =>
    typeof v === 'object' && v !== null ? flatten(v, `${prefix}${k}.`) : [`${prefix}${k}`],
  );
}

describe('message catalogs', () => {
  it('EN and PL declare exactly the same keys', () => {
    expect(flatten(pl).sort()).toEqual(flatten(en).sort());
  });

  it.each(['en', 'pl'])('%s covers all six CORE-07 sync states', (locale) => {
    const messages = (locale === 'en' ? en : pl) as { sync: Record<string, string> };
    expect(Object.keys(messages.sync).sort()).toEqual([...CORE_07_SYNC_STATES].sort());
  });

  it('no sync state is left untranslated in PL', () => {
    for (const state of CORE_07_SYNC_STATES) {
      expect(pl.sync[state]).not.toBe(en.sync[state]);
    }
  });
});
