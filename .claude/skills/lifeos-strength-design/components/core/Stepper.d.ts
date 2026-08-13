import * as React from 'react';

/**
 * Keyboard-free numeric adjustment — the fast path in the set editor.
 * @startingPoint section="Core" subtitle="Keyboard-free weight stepper" viewport="700x180"
 */
export interface StepperProps extends React.HTMLAttributes<HTMLDivElement> {
  value?: number;
  /** Increment. 2.5 for barbell weight, 1 for reps, 5 for machine plates. */
  step?: number;
  unit?: string;
  min?: number;
  onChange?: (value: number) => void;
  /** lg is the in-workout size: 56px targets, 44px numerals. */
  size?: 'md' | 'lg';
}
export declare function Stepper(props: StepperProps): JSX.Element;
