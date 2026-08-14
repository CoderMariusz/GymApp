import React from 'react';
import { Icon } from './Icon.jsx';

export function RadioGroup({ options = [], value, onChange, style, ...rest }) {
  const opts = options.map((o) => (typeof o === 'string' ? { value: o, label: o } : o));
  return (
    <div role="radiogroup" style={{ display: 'flex', flexDirection: 'column', gap: 8, ...style }} {...rest}>
      {opts.map((o) => {
        const on = o.value === value;
        return (
          <button
            key={o.value} role="radio" aria-checked={on}
            onClick={() => onChange && onChange(o.value)}
            style={{
              display: 'flex', alignItems: 'center', gap: 12, minHeight: 52, padding: '0 14px',
              textAlign: 'left', cursor: 'pointer', color: 'var(--text-primary)', fontFamily: 'var(--font-ui)',
              background: on ? 'var(--surface-raised)' : 'var(--surface-card)',
              border: '1px solid ' + (on ? 'var(--border-accent)' : 'var(--border-subtle)'),
              borderRadius: 'var(--radius-md)',
              transition: 'background var(--dur-fast) var(--ease-standard)',
            }}
          >
            {o.icon && <Icon name={o.icon} size={18} color={on ? 'var(--text-accent)' : 'var(--text-secondary)'} />}
            <span style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2 }}>
              <span style={{ fontSize: 14, fontWeight: 'var(--fw-bold)' }}>{o.label}</span>
              {o.description && <span style={{ fontSize: 11, lineHeight: '15px', color: 'var(--text-tertiary)' }}>{o.description}</span>}
            </span>
            <span style={{
              flex: '0 0 auto', display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
              width: 20, height: 20, borderRadius: 'var(--radius-pill)',
              border: '2px solid ' + (on ? 'var(--action-primary)' : 'var(--border-strong)'),
            }}>
              {on && <span style={{ width: 10, height: 10, borderRadius: 'var(--radius-pill)', background: 'var(--action-primary)' }} />}
            </span>
          </button>
        );
      })}
    </div>
  );
}
