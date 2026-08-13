import React from 'react';
import { Icon } from './Icon.jsx';

export function Select({ label, value, options = [], onChange, style, ...rest }) {
  return (
    <label style={{ display: 'flex', flexDirection: 'column', gap: 6, ...style }}>
      {label && <span style={{ fontSize: 'var(--type-label-size)', fontWeight: 'var(--fw-bold)', color: 'var(--text-secondary)' }}>{label}</span>}
      <span style={{ position: 'relative', display: 'flex', alignItems: 'center' }}>
        <select
          value={value} onChange={(e) => onChange && onChange(e.target.value)}
          style={{
            appearance: 'none', width: '100%', height: 'var(--hit-min)', padding: '0 40px 0 14px',
            background: 'var(--surface-raised)', color: 'var(--text-primary)',
            border: '1px solid var(--border-default)', borderRadius: 'var(--radius-sm)',
            fontFamily: 'var(--font-ui)', fontSize: 'var(--type-body-size)', fontWeight: 'var(--fw-semibold)',
            cursor: 'pointer',
          }}
          {...rest}
        >
          {options.map((o) => {
            const v = typeof o === 'string' ? o : o.value;
            const l = typeof o === 'string' ? o : o.label;
            return <option key={v} value={v}>{l}</option>;
          })}
        </select>
        <Icon name="chevron-down" size={18} color="var(--text-tertiary)" style={{ position: 'absolute', right: 14, pointerEvents: 'none' }} />
      </span>
    </label>
  );
}
