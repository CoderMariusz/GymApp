import React from 'react';
import { Icon } from './Icon.jsx';

export function Stepper({ value = 0, step = 2.5, unit = 'kg', min = 0, onChange, size = 'md', style, ...rest }) {
  const big = size === 'lg';
  const set = (v) => onChange && onChange(Math.max(min, Math.round(v * 100) / 100));
  const btn = (icon, delta, label) => (
    <button
      aria-label={label}
      onClick={() => set(value + delta)}
      style={{
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        width: big ? 56 : 44, height: big ? 56 : 44, flex: '0 0 auto',
        background: 'var(--surface-raised)', color: 'var(--text-primary)',
        border: '1px solid var(--border-default)', borderRadius: 'var(--radius-pill)', cursor: 'pointer',
        transition: 'background var(--dur-fast) var(--ease-standard)',
      }}
    >
      <Icon name={icon} size={big ? 22 : 18} color="var(--action-primary)" />
    </button>
  );
  return (
    <div
      style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12,
        padding: big ? '10px 12px' : '6px 8px', background: 'var(--surface-card)',
        border: '1px solid var(--border-subtle)', borderRadius: 'var(--radius-lg)', ...style,
      }}
      {...rest}
    >
      {btn('minus', -step, `Decrease by ${step} ${unit}`)}
      <span style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', lineHeight: 1 }}>
        <span
          className="num"
          style={{
            fontFamily: 'var(--font-numeric)', fontVariantNumeric: 'tabular-nums',
            fontSize: big ? 'var(--type-metric-hero-size)' : 'var(--type-metric-size)',
            fontWeight: 'var(--fw-bold)', color: 'var(--text-primary)', letterSpacing: '-.02em',
          }}
        >
          {value}
        </span>
        <span style={{ marginTop: 4, fontSize: 11, letterSpacing: '.08em', textTransform: 'uppercase', color: 'var(--text-tertiary)', fontWeight: 'var(--fw-bold)' }}>{unit}</span>
      </span>
      {btn('plus', step, `Increase by ${step} ${unit}`)}
    </div>
  );
}
