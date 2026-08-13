import * as React from 'react';

export interface RestTimerProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Formatted mm:ss. Rendered in tabular figures so digits do not jump. */
  remaining?: string;
  running?: boolean;
  /** Eyebrow for the adjacent "next exercise" tile, e.g. "Next exercise". */
  nextLabel?: string;
  nextValue?: string;
  onToggle?: () => void;
  onSkip?: () => void;
}
export declare function RestTimer(props: RestTimerProps): JSX.Element;
