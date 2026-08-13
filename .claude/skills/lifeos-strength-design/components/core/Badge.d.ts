import * as React from 'react';

export interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  tone?: 'neutral' | 'accent' | 'info' | 'warning' | 'danger' | 'solid';
  /** Lucide icon name — pair with the label so colour is never the only signal. */
  icon?: string;
  size?: 'sm' | 'md';
}
export declare function Badge(props: BadgeProps): JSX.Element;
