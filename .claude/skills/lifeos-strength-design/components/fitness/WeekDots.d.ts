import * as React from 'react';

export interface WeekDotsProps extends React.HTMLAttributes<HTMLDivElement> {
  /** One entry per weekday: { label: 'M', done: true }. */
  days: Array<{ label: string; done?: boolean }>;
}
export declare function WeekDots(props: WeekDotsProps): JSX.Element;
