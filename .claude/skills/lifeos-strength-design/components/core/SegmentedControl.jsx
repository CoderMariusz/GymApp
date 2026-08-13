import React from 'react';

export function SegmentedControl({ options = [], value, onChange, size = 'md', style, ...rest }) {
  const h = size === 'sm' ? 32 : 38;
  return (
    <div
      role="tablist"
      style={{
        display: 'flex', gap: 4, padding: 4, background: 'var(--surface-raised)',
        border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-pill)', ...style,
      }}
      {...rest}
    >
      {options.map((o) => {
        const key = typeof o === 'string' ? o : o.value;
        const label = typeof o === 'string' ? o : o.label;
        const on = key === value;
        return (
          <button
            key={key} role="tab" aria-selected={on} onClick={() => onChange && onChange(key)}
            style={{
              flex: 1, height: h, minWidth: 60, padding: '0 14px',
              background: on ? 'var(--action-primary)' : 'transparent',
              color: on ? 'var(--action-primary-text)' : 'var(--text-secondary)',
              border: 'none', borderRadius: 'var(--radius-pill)', cursor: 'pointer',
              fontFamily: 'var(--font-ui)', fontSize: 13, fontWeight: 'var(--fw-extrabold)',
              transition: 'background var(--dur-base) var(--ease-standard),color var(--dur-base) var(--ease-standard)',
            }}
          >
            {label}
          </button>
        );
      })}
    </div>
  );
}
