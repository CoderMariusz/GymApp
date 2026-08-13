import * as React from 'react';

export interface TrendChartProps extends React.HTMLAttributes<HTMLElement> {
  /** Series values, oldest first. */
  data: number[];
  height?: number;
  /** Y-axis ticks, top to bottom. */
  yTicks?: Array<string | number>;
  xLabels?: string[];
}
export declare function TrendChart(props: TrendChartProps): JSX.Element;
