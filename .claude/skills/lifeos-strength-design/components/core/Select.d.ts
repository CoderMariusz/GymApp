import * as React from 'react';

export interface SelectProps extends Omit<React.SelectHTMLAttributes<HTMLSelectElement>, 'onChange'> {
  label?: string;
  value?: string;
  options: Array<string | { value: string; label: string }>;
  onChange?: (value: string) => void;
}
export declare function Select(props: SelectProps): JSX.Element;
