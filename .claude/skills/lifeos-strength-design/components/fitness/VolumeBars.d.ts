import * as React from 'react';

export interface VolumeBarsProps extends React.HTMLAttributes<HTMLElement> {
  /** Raw values; scaled against the series maximum. */
  data: number[];
  height?: number;
  /** Axis labels spread across the bottom. */
  labels?: string[];
  highlightLast?: boolean;
}
export declare function VolumeBars(props: VolumeBarsProps): JSX.Element;
