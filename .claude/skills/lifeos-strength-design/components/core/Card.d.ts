import * as React from 'react';

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  /** default graphite · raised (one step up) · sunken · accent (lime-tinted, active) · plain. */
  tone?: 'default' | 'raised' | 'sunken' | 'accent' | 'plain';
  pad?: 'none' | 'tight' | 'default' | 'loose';
  radius?: 'md' | 'lg' | 'xl';
  /** Adds pointer + hover surface lift for tappable rows. */
  interactive?: boolean;
}
export declare function Card(props: CardProps): JSX.Element;
