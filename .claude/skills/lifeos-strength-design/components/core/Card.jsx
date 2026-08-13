import React from 'react';

const pads = { none: 0, tight: 'var(--card-pad-tight)', default: 'var(--card-pad)', loose: 'var(--space-5)' };

export function Card({ children, tone = 'default', pad = 'default', radius = 'lg', interactive, style, ...rest }) {
  const [hover, setHover] = React.useState(false);
  const tones = {
    default: { bg: 'var(--surface-card)', bd: 'var(--border-subtle)' },
    raised: { bg: 'var(--surface-raised)', bd: 'var(--border-default)' },
    sunken: { bg: 'var(--surface-sunken)', bd: 'var(--border-subtle)' },
    accent: { bg: 'var(--set-active-bg)', bd: 'var(--border-accent)' },
    plain: { bg: 'transparent', bd: 'transparent' },
  };
  const t = tones[tone] || tones.default;
  return (
    <div
      onMouseEnter={() => interactive && setHover(true)} onMouseLeave={() => setHover(false)}
      style={{
        background: hover ? 'var(--surface-raised)' : t.bg,
        border: `1px solid ${t.bd}`,
        borderRadius: radius === 'xl' ? 'var(--radius-xl)' : radius === 'md' ? 'var(--radius-md)' : 'var(--radius-lg)',
        padding: pads[pad], boxShadow: 'var(--shadow-card)',
        cursor: interactive ? 'pointer' : undefined,
        transition: 'background var(--dur-fast) var(--ease-standard)',
        ...style,
      }}
      {...rest}
    >
      {children}
    </div>
  );
}
