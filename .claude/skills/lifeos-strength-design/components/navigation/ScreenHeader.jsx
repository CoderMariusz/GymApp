import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function ScreenHeader({ title, subtitle, onBack, left, right, sticky, style, ...rest }) {
  return (
    <header
      style={{
        display: 'flex', alignItems: 'center', gap: 8,
        minHeight: 'var(--header-h)', padding: '0 var(--gutter-mobile)',
        paddingTop: 'var(--safe-top)',
        position: sticky ? 'sticky' : undefined, top: sticky ? 0 : undefined, zIndex: sticky ? 5 : undefined,
        background: sticky ? 'var(--surface-nav)' : 'transparent',
        backdropFilter: sticky ? 'var(--blur-nav)' : undefined,
        ...style,
      }}
      {...rest}
    >
      {onBack && (
        <button aria-label="Back" onClick={onBack} style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 'var(--hit-min)', height: 'var(--hit-min)', marginLeft: -12, background: 'transparent', border: 'none', color: 'var(--text-primary)', cursor: 'pointer' }}>
          <Icon name="chevron-left" size={24} />
        </button>
      )}
      {left}
      <span style={{ flex: 1, minWidth: 0, textAlign: onBack ? 'center' : 'left' }}>
        <span style={{ display: 'block', fontFamily: 'var(--font-display)', fontSize: 'var(--type-heading-size)', fontWeight: 'var(--fw-bold)', color: 'var(--text-primary)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</span>
        {subtitle && <span style={{ display: 'block', fontSize: 12, color: 'var(--text-tertiary)' }}>{subtitle}</span>}
      </span>
      <span style={{ display: 'flex', alignItems: 'center', gap: 4, minWidth: onBack ? 'var(--hit-min)' : 0, justifyContent: 'flex-end' }}>{right}</span>
    </header>
  );
}
