import * as React from 'react';

export interface IconButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Lucide icon name. */
  icon: string;
  /** Required accessible name — the icon carries the meaning. */
  label: string;
  variant?: 'ghost' | 'filled' | 'accent';
  /** Button box size in px; never below 44. */
  size?: number;
  iconSize?: number;
}
export declare function IconButton(props: IconButtonProps): JSX.Element;
