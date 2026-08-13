import React from 'react';
import { Icon } from '../core/Icon.jsx';

export function StatCard({ label, value, unit, delta, deltaTone = 'accent', icon, footnote, style, ...rest }) {
  const tone = deltaTone === 'accent' ? 'var(--feedback-success)' : deltaTone === 'danger' ? 'var(--feedback-danger)' : 'var(--text-tertiary)';
  return (
    <div
      style={{
        display: 'flex', flexDirection: 'column', gap: 6, padding: 'var(--card-pad)',
        background: 'var(--surface-card)', border: '1px solid var(--border-subtle)',
        borderRadius: 'var(--radius-lg)', ...style,
      }}
      {...rest}
    >
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
        <span style={{ fontSize: 13, color: 'var(--text-secondary)', fontWeight: 'var(--fw-semibold)' }}>{label}</span>
        {icon && <Icon name={icon} size={16} color="var(--action-primary)" />}
      </div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 5 }}>
        <span className="num" style={{ fontFamily: 'var(--font-numeric)', fontVariantNumeric: 'tabular-nums', fontSize: 'var(--type-metric-size)', lineHeight: 'var(--type-metric-lh)', fontWeight: 'var(--fw-bold)', letterSpacing: '-.02em' }}>{value}</span>
        {unit && <span style={{ fontSize: 13, color: 'var(--text-tertiary)', fontWeight: 'var(--fw-bold)' }}>{unit}</span>}
      </div>
      {(delta || footnote) && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12 }}>
          {delta && <span style={{ color: tone, fontWeight: 'var(--fw-extrabold)' }}>{delta}</span>}
          {footnote && <span style={{ color: 'var(--text-tertiary)' }}>{footnote}</span>}
        </div>
      )}
    </div>
  );
}
