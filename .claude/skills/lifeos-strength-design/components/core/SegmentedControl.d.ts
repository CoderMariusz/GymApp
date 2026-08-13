import * as React from 'react';

export interface SegmentedControlProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Strings, or { value, label } pairs. Two to four segments; more needs a Select. */
  options: Array<string | { value: string; label: string }>;
  value?: string;
  onChange?: (value: string) => void;
  size?: 'sm' | 'md';
}
export declare function SegmentedControl(props: SegmentedControlProps): JSX.Element;
