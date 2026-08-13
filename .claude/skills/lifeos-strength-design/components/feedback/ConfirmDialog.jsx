import React from 'react';
import { Button } from '../core/Button.jsx';
import { Icon } from '../core/Icon.jsx';

export function ConfirmDialog({ title, description, recovery, confirmLabel = 'Delete', cancelLabel = 'Cancel', tone = 'danger', onConfirm, onCancel, style, ...rest }) {
  return (
    <div
      role="dialog" aria-modal="true"
      style={{
        width: '100%', maxWidth: 340, padding: 'var(--space-5)',
        background: 'var(--surface-raised)', border: '1px solid var(--border-default)',
        borderRadius: 'var(--radius-xl)', boxShadow: 'var(--shadow-float)', ...style,
      }}
      {...rest}
    >
      <span style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 40, height: 40, marginBottom: 12, background: tone === 'danger' ? 'var(--feedback-danger-quiet)' : 'var(--surface-inset)', borderRadius: 'var(--radius-pill)' }}>
        <Icon name={tone === 'danger' ? 'trash-2' : 'circle-alert'} size={20} color={tone === 'danger' ? 'var(--feedback-danger)' : 'var(--text-secondary)'} />
      </span>
      <div style={{ fontFamily: 'var(--font-display)', fontSize: 'var(--type-title-size)', lineHeight: 'var(--type-title-lh)', fontWeight: 'var(--fw-bold)' }}>{title}</div>
      {description && <p style={{ margin: '8px 0 0', fontSize: 13, lineHeight: '19px', color: 'var(--text-secondary)' }}>{description}</p>}
      {recovery && (
        <p style={{ margin: '10px 0 0', padding: '10px 12px', background: 'var(--surface-inset)', borderRadius: 'var(--radius-sm)', fontSize: 12, lineHeight: '17px', color: 'var(--text-tertiary)' }}>{recovery}</p>
      )}
      <div style={{ display: 'flex', gap: 8, marginTop: 'var(--space-5)' }}>
        <Button variant="secondary" block onClick={onCancel}>{cancelLabel}</Button>
        <Button variant={tone === 'danger' ? 'danger' : 'primary'} block onClick={onConfirm}>{confirmLabel}</Button>
      </div>
    </div>
  );
}
