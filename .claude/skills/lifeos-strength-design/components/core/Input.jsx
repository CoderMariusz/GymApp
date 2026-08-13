import React from 'react';
import { Icon } from './Icon.jsx';

export function Input({ label, hint, error, icon, suffix, align = 'left', numeric, style, ...rest }) {
  const [focus, setFocus] = React.useState(false);
  return (
    <label style={{ display: 'flex', flexDirection: 'column', gap: 6, ...style }}>
      {label && (
        <span style={{ fontSize: 'var(--type-label-size)', fontWeight: 'var(--fw-bold)', color: 'var(--text-secondary)' }}>{label}</span>
      )}
      <span
        style={{
          display: 'flex', alignItems: 'center', gap: 8, height: 'var(--hit-min)', padding: '0 14px',
          background: 'var(--surface-raised)',
          border: `1px solid ${error ? 'var(--feedback-danger)' : focus ? 'var(--border-accent)' : 'var(--border-default)'}`,
          borderRadius: 'var(--radius-sm)',
          transition: 'border-color var(--dur-fast) var(--ease-standard)',
        }}
      >
        {icon && <Icon name={icon} size={16} color="var(--text-tertiary)" />}
        <input
          onFocus={() => setFocus(true)} onBlur={() => setFocus(false)}
          style={{
            flex: 1, minWidth: 0, background: 'transparent', border: 'none', outline: 'none',
            color: 'var(--text-primary)', textAlign: align,
            fontFamily: numeric ? 'var(--font-numeric)' : 'var(--font-ui)',
            fontVariantNumeric: numeric ? 'tabular-nums' : 'normal',
            fontSize: numeric ? 'var(--type-metric-sm-size)' : 'var(--type-body-size)',
            fontWeight: numeric ? 'var(--fw-bold)' : 'var(--fw-medium)',
          }}
          {...rest}
        />
        {suffix && <span style={{ fontSize: 12, color: 'var(--text-tertiary)', fontWeight: 'var(--fw-bold)' }}>{suffix}</span>}
      </span>
      {(error || hint) && (
        <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 12, color: error ? 'var(--feedback-danger)' : 'var(--text-tertiary)' }}>
          {error && <Icon name="circle-alert" size={13} />}
          {error || hint}
        </span>
      )}
    </label>
  );
}
