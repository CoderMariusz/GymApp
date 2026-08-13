import React from 'react';
import { Icon } from './Icon.jsx';

const tones = {
  neutral: { fg: 'var(--text-secondary)', bg: 'var(--surface-inset)' },
  accent: { fg: 'var(--feedback-success)', bg: 'var(--feedback-success-quiet)' },
  info: { fg: 'var(--feedback-info)', bg: 'var(--feedback-info-quiet)' },
  warning: { fg: 'var(--feedback-warning)', bg: 'var(--feedback-warning-quiet)' },
  danger: { fg: 'var(--feedback-danger)', bg: 'var(--feedback-danger-quiet)' },
  solid: { fg: 'var(--action-primary-text)', bg: 'var(--action-primary)' },
};

export function Badge({ children, tone = 'neutral', icon, size = 'md', style, ...rest }) {
  const t = tones[tone] || tones.neutral;
  const sm = size === 'sm';
  return (
    <span
      style={{
        display: 'inline-flex', alignItems: 'center', gap: sm ? 4 : 6,
        height: sm ? 20 : 26, padding: sm ? '0 7px' : '0 10px',
        background: t.bg, color: t.fg, borderRadius: 'var(--radius-pill)',
        fontFamily: 'var(--font-ui)', fontSize: sm ? 10 : 11, fontWeight: 'var(--fw-extrabold)',
        letterSpacing: '.06em', textTransform: 'uppercase', whiteSpace: 'nowrap',
        ...style,
      }}
      {...rest}
    >
      {icon && <Icon name={icon} size={sm ? 11 : 13} />}
      {children}
    </span>
  );
}
