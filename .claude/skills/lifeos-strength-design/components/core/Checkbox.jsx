import React from 'react';
import { Icon } from './Icon.jsx';

export function Checkbox({ checked = false, indeterminate, onChange, disabled, label, description, style, ...rest }) {
  const on = checked || indeterminate;
  return (
    <button
      role="checkbox" aria-checked={indeterminate ? 'mixed' : !!checked} disabled={disabled}
      onClick={() => onChange && onChange(!checked)}
      style={{
        display: 'inline-flex', alignItems: 'flex-start', gap: 10, minHeight: 'var(--hit-min)',
        padding: '0 2px', background: 'none', border: 'none', textAlign: 'left',
        cursor: disabled ? 'not-allowed' : 'pointer', opacity: disabled ? 0.45 : 1,
        color: 'var(--text-primary)', fontFamily: 'var(--font-ui)',
        ...style,
      }}
      {...rest}
    >
      <span style={{
        marginTop: 11, flex: '0 0 auto', display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        width: 22, height: 22, borderRadius: 7,
        background: on ? 'var(--action-primary)' : 'transparent',
        border: '2px solid ' + (on ? 'var(--action-primary)' : 'var(--border-strong)'),
        transition: 'background var(--dur-fast) var(--ease-standard)',
      }}>
        {checked && !indeterminate && <Icon name="check" size={14} color="var(--action-primary-text)" />}
        {indeterminate && <Icon name="minus" size={14} color="var(--action-primary-text)" />}
      </span>
      {(label || description) && (
        <span style={{ display: 'flex', flexDirection: 'column', gap: 2, padding: '10px 0' }}>
          <span style={{ fontSize: 14, fontWeight: 'var(--fw-bold)', lineHeight: '18px' }}>{label}</span>
          {description && <span style={{ fontSize: 11, lineHeight: '15px', color: 'var(--text-tertiary)' }}>{description}</span>}
        </span>
      )}
    </button>
  );
}
