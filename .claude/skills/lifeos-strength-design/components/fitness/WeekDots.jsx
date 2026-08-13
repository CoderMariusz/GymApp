import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function WeekDots({ days = [], style, ...rest }) {
  return (
    <div style={{ display: 'flex', gap: 8, justifyContent: 'space-between', ...style }} {...rest}>
      {days.map((d, i) => {
        const done = d.done;
        return (
          <span key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
            <span
              aria-label={`${d.label}: ${done ? 'trained' : 'no session'}`}
              style={{
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 30, height: 30,
                borderRadius: 'var(--radius-pill)',
                background: done ? 'var(--feedback-success-quiet)' : 'transparent',
                border: `1.5px solid ${done ? 'var(--action-primary)' : 'var(--border-default)'}`,
                color: 'var(--action-primary)',
              }}
            >
              {done && <Icon name="check" size={15} />}
            </span>
            <span style={{ fontSize: 11, color: 'var(--text-tertiary)', fontWeight: 'var(--fw-bold)' }}>{d.label}</span>
          </span>
        );
      })}
    </div>
  );
}
