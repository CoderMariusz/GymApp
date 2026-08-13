import * as React from 'react';

/**
 * One row of the set table — the product's most-used component.
 * @startingPoint section="Fitness" subtitle="Set rows: logged, active, proposed, warm-up" viewport="700x220"
 */
export interface SetRowProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Working-set number. Warm-up rows show "W" instead. */
  index: number;
  weight: React.ReactNode;
  reps: React.ReactNode;
  /** Reps in reserve / RPE. Optional column. */
  rir?: React.ReactNode;
  /** Rest value or "-". Optional column. */
  rest?: React.ReactNode;
  /** logged = recorded fact (white, ticked) · active = current row · proposed = pre-filled suggestion (grey). */
  state?: 'logged' | 'active' | 'proposed';
  /** Warm-up sets carry an amber rail and do not count toward volume or records. */
  warmup?: boolean;
  unit?: string;
  onConfirm?: () => void;
}
export declare function SetRow(props: SetRowProps): JSX.Element;
