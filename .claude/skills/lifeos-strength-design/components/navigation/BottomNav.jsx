import React from 'react';
import { Icon } from '../core/Icon.jsx';

export const NAV_ITEMS = [
  { key: 'home', label: 'Home', icon: 'house' },
  { key: 'workout', label: 'Workout', icon: 'dumbbell' },
  { key: 'exercises', label: 'Exercises', icon: 'list' },
  { key: 'progress', label: 'Progress', icon: 'chart-column' },
];

export function BottomNav({ items = NAV_ITEMS, active = 'home', onSelect, onAdd, addLabel = 'Start workout', style, ...rest }) {
  const left = items.slice(0, 2), right = items.slice(2);
  const tab = (it) => {
    const on = it.key === active;
    return (
      <button
        key={it.key} aria-current={on ? 'page' : undefined} onClick={() => onSelect && onSelect(it.key)}
        style={{
          flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 4,
          minHeight: 'var(--hit-min)', padding: '6px 0', background: 'transparent', border: 'none', cursor: 'pointer',
          color: on ? 'var(--action-primary)' : 'var(--text-tertiary)',
        }}
      >
        <Icon name={it.icon} size={22} />
        <span style={{ fontSize: 10, fontWeight: on ? 'var(--fw-extrabold)' : 'var(--fw-semibold)', letterSpacing: '.01em' }}>{it.label}</span>
      </button>
    );
  };
  return (
    <nav
      style={{
        position: 'relative', display: 'flex', alignItems: 'center',
        height: 'var(--nav-h)', paddingBottom: 'var(--safe-bottom)',
        background: 'var(--surface-nav)', backdropFilter: 'var(--blur-nav)', WebkitBackdropFilter: 'var(--blur-nav)',
        borderTop: '1px solid var(--border-subtle)', ...style,
      }}
      {...rest}
    >
      {left.map(tab)}
      <span style={{ width: 72, flex: '0 0 auto' }} />
      {right.map(tab)}
      <button
        aria-label={addLabel} onClick={onAdd}
        style={{
          position: 'absolute', left: '50%', top: -4, transform: 'translateX(-50%)',
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          width: 'var(--fab-size)', height: 'var(--fab-size)',
          background: 'var(--action-primary)', color: 'var(--action-primary-text)',
          border: 'none', borderRadius: 'var(--radius-pill)', cursor: 'pointer',
          boxShadow: 'var(--shadow-fab)',
        }}
      >
        <Icon name="plus" size={26} />
      </button>
    </nav>
  );
}
