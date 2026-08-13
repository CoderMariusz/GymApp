import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function ExerciseRow({ name, meta, thumb, right, badge, onClick, style, ...rest }) {
  const [hover, setHover] = React.useState(false);
  return (
    <div
      onClick={onClick}
      onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)}
      style={{
        display: 'flex', alignItems: 'center', gap: 12, minHeight: 60, padding: '10px 14px',
        background: hover ? 'var(--surface-raised)' : 'var(--surface-card)',
        border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-lg)',
        cursor: onClick ? 'pointer' : 'default',
        transition: 'background var(--dur-fast) var(--ease-standard)', ...style,
      }}
      {...rest}
    >
      <span style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 40, height: 40, flex: '0 0 auto', background: 'var(--surface-inset)', borderRadius: 'var(--radius-md)' }}>
        <Icon name={thumb || 'dumbbell'} size={20} color="var(--text-secondary)" />
      </span>
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontSize: 'var(--type-body-size)', fontWeight: 'var(--fw-extrabold)', color: 'var(--text-primary)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{name}</span>
          {badge}
        </span>
        {meta && <span style={{ display: 'block', marginTop: 2, fontSize: 12, color: 'var(--text-tertiary)' }}>{meta}</span>}
      </span>
      {right || <Icon name="chevron-right" size={18} color="var(--text-tertiary)" />}
    </div>
  );
}
