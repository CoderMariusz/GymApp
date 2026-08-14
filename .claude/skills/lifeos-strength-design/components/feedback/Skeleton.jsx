import React from 'react';

/** Loading placeholder. Shape mirrors the content that will land, so nothing shifts on arrival. */
export function Skeleton({ width = '100%', height = 12, radius = 8, circle, lines, gap = 8, style, ...rest }) {
  const base = {
    background: 'var(--surface-raised)',
    animation: 'lifeos-skeleton 1.4s var(--ease-standard) infinite',
  };
  if (lines) {
    return (
      <span style={{ display: 'flex', flexDirection: 'column', gap, ...style }} {...rest}>
        {Array.from({ length: lines }, (_, i) => (
          <span key={i} style={{ ...base, display: 'block', width: i === lines - 1 ? '62%' : '100%', height, borderRadius: radius }} />
        ))}
      </span>
    );
  }
  return <span style={{ ...base, display: 'block', width: circle ? height : width, height, borderRadius: circle ? 'var(--radius-pill)' : radius, ...style }} {...rest} />;
}
