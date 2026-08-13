import * as React from 'react';

export interface ConfirmDialogProps extends React.HTMLAttributes<HTMLDivElement> {
  title: React.ReactNode;
  description?: React.ReactNode;
  /** What the user can do afterwards. Every destructive action names a recovery path (DESIGN-BRIEF C-8). */
  recovery?: React.ReactNode;
  confirmLabel?: string;
  cancelLabel?: string;
  tone?: 'danger' | 'neutral';
  onConfirm?: () => void;
  onCancel?: () => void;
}
export declare function ConfirmDialog(props: ConfirmDialogProps): JSX.Element;
