import * as React from 'react';

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  hint?: string;
  /** Error message. Rendered with an icon — colour is never the only signal. */
  error?: string;
  /** Leading Lucide icon name. */
  icon?: string;
  /** Trailing unit, e.g. "kg". */
  suffix?: string;
  align?: 'left' | 'center' | 'right';
  /** Tabular figures + metric type size, for weight/rep fields. */
  numeric?: boolean;
}
export declare function Input(props: InputProps): JSX.Element;
