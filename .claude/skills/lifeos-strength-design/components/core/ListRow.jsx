import React from 'react';
import { Icon } from './Icon.jsx';

/** The Settings row. Label, optional description, a value or a control, and a chevron when it navigates. */
export function ListRow({ icon, label, description, value, control, chevron, tone = 'default', disabled, onClick, style, ...rest }) {
  const danger = tone === 'danger';
  const showChevron = chevron !== undefined ? chevron : !control;
  const fg = danger ? 'var(--feedback-danger)' : 'var(--text-primary)';
  return (
    <div
      role={onClick ? 'button' : undefined} onClick={disabled ? undefined : onClick}
      style={{
        display: 'flex', alignItems: 'center', gap: 12, minHeight: 52, padding: '10px 14px',
        background: 'var(--surface-card)', border: '1px solid var(--border-subtle)',
        borderRadius: 'var(--radius-md)', opacity: disabled ? 0.45 : 1,
        cursor: onClick && !disabled ? 'pointer' : 'default', color: 'var(--text-primary)',
        fontFamily: 'var(--font-ui)',
        ...style,
      }}
      {...rest}
    >
      {icon && <Icon name={icon} size={18} color={danger ? 'var(--feedback-danger)' : 'var(--text-secondary)'} style={{ flex: '0 0 auto' }} />}
      <span style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2, minWidth: 0 }}>
        <span style={{ fontSize: 14, fontWeight: 'var(--fw-bold)', color: fg }}>{label}</span>
        {description && <span style={{ fontSize: 11, lineHeight: '15px', color: 'var(--text-tertiary)' }}>{description}</span>}
      </span>
      {value !== undefined && <span style={{ flex: '0 0 auto', fontSize: 13, fontWeight: 'var(--fw-semibold)', color: 'var(--text-tertiary)' }}>{value}</span>}
      {control}
      {showChevron && <Icon name="chevron-right" size={17} color="var(--text-tertiary)" style={{ flex: '0 0 auto' }} />}
    </div>
  );
}
