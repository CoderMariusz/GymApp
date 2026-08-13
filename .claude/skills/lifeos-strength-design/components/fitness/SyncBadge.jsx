import React from 'react';
import { Icon } from '../core/Icon.jsx';

/* The six sync states from DESIGN-BRIEF §6.2. Each carries an icon AND a word;
   `queued` is deliberately neutral — it is the normal state in a gym basement. */
export const SYNC_STATES = {
  draft_local: { label: 'Saved on device', icon: 'smartphone', fg: 'var(--sync-draft-fg)', bg: 'var(--sync-draft-bg)' },
  queued:      { label: 'Waiting for connection', icon: 'clock', fg: 'var(--sync-queued-fg)', bg: 'var(--sync-queued-bg)' },
  syncing:     { label: 'Syncing', icon: 'refresh-cw', fg: 'var(--sync-syncing-fg)', bg: 'var(--sync-syncing-bg)' },
  saved:       { label: 'Saved', icon: 'check', fg: 'var(--sync-saved-fg)', bg: 'var(--sync-saved-bg)' },
  failed:      { label: 'Will retry', icon: 'rotate-ccw', fg: 'var(--sync-failed-fg)', bg: 'var(--sync-failed-bg)' },
  conflict:    { label: 'Needs your decision', icon: 'git-merge', fg: 'var(--sync-conflict-fg)', bg: 'var(--sync-conflict-bg)' },
};

export function SyncBadge({ state = 'saved', label, compact, style, ...rest }) {
  const s = SYNC_STATES[state] || SYNC_STATES.saved;
  return (
    <span
      style={{
        display: 'inline-flex', alignItems: 'center', gap: 6,
        height: compact ? 24 : 28, padding: compact ? '0 8px' : '0 10px',
        background: s.bg, color: s.fg, borderRadius: 'var(--radius-pill)',
        fontFamily: 'var(--font-ui)', fontSize: compact ? 11 : 12,
        fontWeight: 'var(--fw-bold)', whiteSpace: 'nowrap', ...style,
      }}
      {...rest}
    >
      <Icon
        name={s.icon} size={compact ? 12 : 14}
        style={state === 'syncing' ? { animation: 'lifeos-spin 1.2s linear infinite' } : undefined}
      />
      {label || s.label}
    </span>
  );
}
