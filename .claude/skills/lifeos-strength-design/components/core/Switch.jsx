import React from 'react';
import { Icon } from './Icon.jsx';

/** On/off control. Position and the glyph carry the state, not colour alone (C-4). */
export function Switch({ checked = false, onChange, disabled, label, style, ...rest }) {
  return (
    <button
      role="switch" aria-checked={!!checked} aria-label={label} disabled={disabled}
      onClick={() => onChange && onChange(!checked)}
      style={{
        position: 'relative', flex: '0 0 auto', width: 52, height: 32, padding: 0,
        cursor: disabled ? 'not-allowed' : 'pointer', opacity: disabled ? 0.45 : 1,
        background: checked ? 'var(--action-primary)' : 'var(--action-secondary)',
        border: '1px solid ' + (checked ? 'transparent' : 'var(--border-default)'),
        borderRadius: 'var(--radius-pill)',
        transition: 'background var(--dur-fast) var(--ease-standard)',
        ...style,
      }}
      {...rest}
    >
      <span style={{
        position: 'absolute', top: 3, left: checked ? 23 : 3,
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        width: 24, height: 24, borderRadius: 'var(--radius-pill)',
        background: checked ? 'var(--action-primary-text)' : 'var(--text-secondary)',
        transition: 'left var(--dur-fast) var(--ease-standard)',
      }}>
        {checked && <Icon name="check" size={14} color="var(--action-primary)" />}
      </span>
    </button>
  );
}
