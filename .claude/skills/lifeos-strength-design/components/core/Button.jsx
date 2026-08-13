import React from 'react';
import { Icon } from './Icon.jsx';

const sizes = {
  sm: { h: 36, px: 14, fs: 13, gap: 6, ls: '.04em' },
  md: { h: 44, px: 18, fs: 14, gap: 8, ls: '.04em' },
  lg: { h: 52, px: 22, fs: 15, gap: 10, ls: '.08em' },
};

const variants = {
  primary:   { bg: 'var(--action-primary)', fg: 'var(--action-primary-text)', bd: 'transparent' },
  secondary: { bg: 'var(--action-secondary)', fg: 'var(--action-secondary-text)', bd: 'var(--border-default)' },
  ghost:     { bg: 'transparent', fg: 'var(--text-primary)', bd: 'transparent' },
  danger:    { bg: 'var(--feedback-danger)', fg: '#fff', bd: 'transparent' },
};

export function Button({
  children, variant = 'primary', size = 'md', shape = 'rounded', block,
  iconLeft, iconRight, uppercase, disabled, style, ...rest
}) {
  const s = sizes[size] || sizes.md;
  const v = variants[variant] || variants.primary;
  const [hover, setHover] = React.useState(false);
  const [press, setPress] = React.useState(false);
  let bg = v.bg;
  if (!disabled && variant === 'primary') bg = press ? 'var(--action-primary-press)' : hover ? 'var(--action-primary-hover)' : v.bg;
  if (!disabled && variant === 'secondary' && hover) bg = 'var(--action-secondary-hover)';
  if (!disabled && variant === 'ghost' && hover) bg = 'var(--action-ghost-hover)';
  return (
    <button
      disabled={disabled}
      onMouseEnter={() => setHover(true)} onMouseLeave={() => { setHover(false); setPress(false); }}
      onMouseDown={() => setPress(true)} onMouseUp={() => setPress(false)}
      style={{
        display: block ? 'flex' : 'inline-flex', width: block ? '100%' : undefined,
        alignItems: 'center', justifyContent: 'center', gap: s.gap,
        minHeight: s.h, height: s.h, padding: `0 ${s.px}px`,
        background: disabled ? 'var(--action-disabled)' : bg,
        color: disabled ? 'var(--action-disabled-text)' : v.fg,
        border: `1px solid ${disabled ? 'transparent' : v.bd}`,
        borderRadius: shape === 'pill' ? 'var(--radius-pill)' : 'var(--radius-md)',
        fontFamily: 'var(--font-ui)', fontSize: s.fs, fontWeight: 'var(--fw-extrabold)',
        letterSpacing: uppercase ? s.ls : '0',
        textTransform: uppercase ? 'uppercase' : 'none',
        cursor: disabled ? 'not-allowed' : 'pointer',
        transform: press && !disabled ? 'scale(var(--press-scale))' : 'none',
        transition: 'background var(--dur-fast) var(--ease-standard),transform var(--dur-fast) var(--ease-standard)',
        ...style,
      }}
      {...rest}
    >
      {iconLeft && <Icon name={iconLeft} size={size === 'sm' ? 16 : 18} />}
      {children}
      {iconRight && <Icon name={iconRight} size={size === 'sm' ? 16 : 18} />}
    </button>
  );
}
