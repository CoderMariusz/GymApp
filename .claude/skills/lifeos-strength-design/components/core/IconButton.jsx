import React from 'react';
import { Icon } from './Icon.jsx';

export function IconButton({ icon, label, variant = 'ghost', size = 44, iconSize = 20, style, ...rest }) {
  const [hover, setHover] = React.useState(false);
  const bg = variant === 'filled' ? 'var(--surface-raised)' : variant === 'accent' ? 'var(--action-primary)' : 'transparent';
  return (
    <button
      aria-label={label}
      onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)}
      style={{
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        width: size, height: size, minWidth: 'var(--hit-min)', minHeight: 'var(--hit-min)',
        background: hover && variant !== 'accent' ? 'var(--action-ghost-hover)' : bg,
        color: variant === 'accent' ? 'var(--action-primary-text)' : 'var(--text-primary)',
        border: variant === 'filled' ? '1px solid var(--border-subtle)' : '1px solid transparent',
        borderRadius: 'var(--radius-pill)', cursor: 'pointer',
        transition: 'background var(--dur-fast) var(--ease-standard)',
        ...style,
      }}
      {...rest}
    >
      <Icon name={icon} size={iconSize} />
    </button>
  );
}
