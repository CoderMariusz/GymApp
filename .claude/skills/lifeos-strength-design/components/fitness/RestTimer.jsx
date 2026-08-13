import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function RestTimer({ remaining = '1:45', running = true, nextLabel, nextValue, onToggle, onSkip, style, ...rest }) {
  return (
    <div style={{ display: 'flex', alignItems: 'stretch', gap: 8, ...style }} {...rest}>
      <div style={{ flex: 1, padding: '10px 14px', background: 'var(--surface-card)', border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-lg)' }}>
        <div style={{ fontSize: 10, letterSpacing: '.1em', textTransform: 'uppercase', color: 'var(--text-tertiary)', fontWeight: 'var(--fw-bold)' }}>Rest timer</div>
        <div className="num" style={{ marginTop: 2, fontFamily: 'var(--font-numeric)', fontVariantNumeric: 'tabular-nums', fontSize: 'var(--type-timer-size)', lineHeight: 'var(--type-timer-lh)', fontWeight: 'var(--fw-bold)', color: 'var(--action-primary)' }}>{remaining}</div>
      </div>
      <button
        aria-label={running ? 'Pause rest timer' : 'Resume rest timer'} onClick={onToggle}
        style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 56, minHeight: 'var(--hit-min)', background: 'var(--surface-raised)', color: 'var(--text-primary)', border: '1px solid var(--border-default)', borderRadius: 'var(--radius-lg)', cursor: 'pointer' }}
      >
        <Icon name={running ? 'pause' : 'play'} size={20} />
      </button>
      {nextLabel && (
        <button
          onClick={onSkip}
          style={{ flex: 1.2, display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8, padding: '10px 12px', textAlign: 'left', background: 'var(--surface-card)', border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-lg)', cursor: 'pointer', color: 'var(--text-primary)' }}
        >
          <span>
            <span style={{ display: 'block', fontSize: 10, letterSpacing: '.1em', textTransform: 'uppercase', color: 'var(--text-tertiary)', fontWeight: 'var(--fw-bold)' }}>{nextLabel}</span>
            <span style={{ display: 'block', marginTop: 3, fontSize: 13, fontWeight: 'var(--fw-extrabold)' }}>{nextValue}</span>
          </span>
          <Icon name="chevron-right" size={18} color="var(--text-tertiary)" />
        </button>
      )}
    </div>
  );
}
