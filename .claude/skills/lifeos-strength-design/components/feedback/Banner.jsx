import React from 'react';
import { Icon } from '../core/Icon.jsx';

const tones = {
  neutral: { fg: 'var(--text-secondary)', accent: 'var(--text-secondary)', bg: 'var(--surface-card)' },
  info: { fg: 'var(--text-primary)', accent: 'var(--feedback-info)', bg: 'var(--surface-card)' },
  warning: { fg: 'var(--text-primary)', accent: 'var(--feedback-warning)', bg: 'var(--surface-card)' },
  danger: { fg: 'var(--text-primary)', accent: 'var(--feedback-danger)', bg: 'var(--surface-card)' },
};

export function Banner({ title, description, icon = 'info', tone = 'neutral', action, onClick, style, ...rest }) {
  const t = tones[tone] || tones.neutral;
  return (
    <div
      onClick={onClick}
      style={{
        display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
        background: t.bg, border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-lg)',
        cursor: onClick ? 'pointer' : 'default', ...style,
      }}
      {...rest}
    >
      <Icon name={icon} size={20} color={t.accent} />
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: 'block', fontSize: 13, fontWeight: 'var(--fw-extrabold)', color: 'var(--text-primary)' }}>{title}</span>
        {description && <span style={{ display: 'block', marginTop: 2, fontSize: 12, color: 'var(--text-tertiary)' }}>{description}</span>}
      </span>
      {action || (onClick && <Icon name="chevron-right" size={18} color="var(--text-tertiary)" />)}
    </div>
  );
}
