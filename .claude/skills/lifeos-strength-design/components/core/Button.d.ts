import * as React from 'react';

/**
 * Primary action control. Lime fill is reserved for the single most important
 * action on screen — usually "Complete set".
 * @startingPoint section="Core" subtitle="Button variants, sizes and states" viewport="700x220"
 */
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  /** sm 36px · md 44px (the hit-target minimum) · lg 52px (set confirmation). */
  size?: 'sm' | 'md' | 'lg';
  shape?: 'rounded' | 'pill';
  /** Stretch to the container width. */
  block?: boolean;
  /** Lucide icon name rendered before the label. */
  iconLeft?: string;
  /** Lucide icon name rendered after the label. */
  iconRight?: string;
  /** Uppercase + tracking. Used on set confirmation and resume actions. */
  uppercase?: boolean;
}
export declare function Button(props: ButtonProps): JSX.Element;
