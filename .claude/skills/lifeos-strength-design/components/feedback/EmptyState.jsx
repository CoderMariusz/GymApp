import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function EmptyState({ icon = 'dumbbell', title, description, action, style, ...rest }) {
  return (
    <div
      style={{
        display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center',
        gap: 8, padding: 'var(--space-7) var(--space-5)', ...style,
      }}
      {...rest}
    >
      <span style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 56, height: 56, marginBottom: 4, background: 'var(--surface-inset)', borderRadius: 'var(--radius-pill)' }}>
        <Icon name={icon} size={24} color="var(--text-tertiary)" />
      </span>
      <span style={{ fontFamily: 'var(--font-display)', fontSize: 'var(--type-heading-size)', fontWeight: 'var(--fw-bold)', color: 'var(--text-primary)' }}>{title}</span>
      {description && <span style={{ maxWidth: 280, fontSize: 13, lineHeight: '18px', color: 'var(--text-tertiary)' }}>{description}</span>}
      {action && <span style={{ marginTop: 8 }}>{action}</span>}
    </div>
  );
}
