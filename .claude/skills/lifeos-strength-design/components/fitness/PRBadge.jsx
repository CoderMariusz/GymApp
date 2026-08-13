import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function PRBadge({ label = 'PR', detail, style, ...rest }) {
  return (
    <span
      style={{
        display: 'inline-flex', alignItems: 'center', gap: 6, height: 28, padding: '0 10px',
        background: 'var(--feedback-success-quiet)', color: 'var(--feedback-success)',
        border: '1px solid var(--border-accent)', borderRadius: 'var(--radius-pill)',
        fontFamily: 'var(--font-ui)', fontSize: 11, fontWeight: 'var(--fw-extrabold)',
        letterSpacing: '.08em', textTransform: 'uppercase', whiteSpace: 'nowrap', ...style,
      }}
      {...rest}
    >
      <Icon name="trophy" size={13} />
      {label}
      {detail && <span style={{ opacity: .8, letterSpacing: 0, textTransform: 'none', fontWeight: 'var(--fw-bold)' }}>{detail}</span>}
    </span>
  );
}
