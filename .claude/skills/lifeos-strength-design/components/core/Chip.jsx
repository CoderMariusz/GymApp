import React from 'react';
import { Icon } from './Icon.jsx';

export function Chip({ children, selected, icon, onClick, style, ...rest }) {
  const [hover, setHover] = React.useState(false);
  return (
    <button
      aria-pressed={!!selected}
      onClick={onClick}
      onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)}
      style={{
        display: 'inline-flex', alignItems: 'center', gap: 6,
        minHeight: 34, padding: '0 14px',
        background: selected ? 'var(--action-primary)' : hover ? 'var(--action-secondary-hover)' : 'var(--action-secondary)',
        color: selected ? 'var(--action-primary-text)' : 'var(--text-secondary)',
        border: `1px solid ${selected ? 'transparent' : 'var(--border-subtle)'}`,
        borderRadius: 'var(--radius-pill)', cursor: 'pointer',
        fontFamily: 'var(--font-ui)', fontSize: 13, fontWeight: 'var(--fw-bold)',
        whiteSpace: 'nowrap',
        transition: 'background var(--dur-fast) var(--ease-standard)',
        ...style,
      }}
      {...rest}
    >
      {icon && <Icon name={icon} size={14} />}
      {children}
    </button>
  );
}
