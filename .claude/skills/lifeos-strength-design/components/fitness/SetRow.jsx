import React from 'react';
import { Icon } from '../core/Icon.jsx';

const cell = (flex) => ({ flex, textAlign: 'center', fontFamily: 'var(--font-numeric)', fontVariantNumeric: 'tabular-nums', fontSize: 'var(--type-metric-sm-size)', fontWeight: 'var(--fw-bold)' });

export function SetRow({ index, weight, reps, rir, rest, state = 'proposed', warmup, unit = 'kg', onConfirm, style, ...rest_ }) {
  const logged = state === 'logged';
  const active = state === 'active';
  const fg = logged ? 'var(--set-logged-text)' : 'var(--set-proposed-text)';
  return (
    <div
      style={{
        display: 'flex', alignItems: 'center', gap: 8, minHeight: 'var(--hit-min)', padding: '0 10px 0 4px',
        background: active ? 'var(--set-active-bg)' : 'transparent',
        border: `1px solid ${active ? 'var(--set-active-border)' : 'transparent'}`,
        borderRadius: 'var(--radius-md)',
        borderLeft: warmup ? '3px solid var(--set-warmup-rail)' : undefined,
        ...style,
      }}
      {...rest_}
    >
      <span style={{ width: 34, textAlign: 'center', fontFamily: 'var(--font-numeric)', fontSize: 13, fontWeight: 'var(--fw-bold)', color: warmup ? 'var(--set-warmup-text)' : 'var(--text-tertiary)' }}>
        {warmup ? 'W' : index}
      </span>
      <span style={{ ...cell(1), color: fg }}>{weight}</span>
      <span style={{ ...cell(1), color: fg }}>{reps}</span>
      {rir !== undefined && <span style={{ ...cell(1), color: 'var(--text-tertiary)', fontSize: 14 }}>{rir}</span>}
      {rest !== undefined && <span style={{ ...cell(1), color: active ? 'var(--text-accent)' : 'var(--text-tertiary)', fontSize: 14 }}>{rest}</span>}
      <button
        aria-label={logged ? `Set ${index} logged` : `Confirm set ${index}`}
        onClick={onConfirm}
        style={{
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          width: 30, height: 30, marginLeft: 2, flex: '0 0 auto', cursor: 'pointer',
          background: logged ? 'transparent' : 'transparent',
          border: `2px solid ${logged ? 'transparent' : active ? 'var(--set-active-border)' : 'var(--set-proposed-border)'}`,
          borderRadius: 'var(--radius-pill)',
        }}
      >
        {logged && <Icon name="check" size={18} color="var(--set-logged-mark)" />}
      </button>
    </div>
  );
}
