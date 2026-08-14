import * as React from 'react';

export interface SkeletonProps extends React.HTMLAttributes<HTMLSpanElement> {
  width?: number | string;
  height?: number | string;
  radius?: number | string;
  /** Square block rendered as a circle — avatar and icon tiles. */
  circle?: boolean;
  /** Renders n stacked text bars, the last one short. */
  lines?: number;
  gap?: number;
}
export declare function Skeleton(props: SkeletonProps): JSX.Element;
