import * as React from 'react';

export interface RadioOption {
  value: string;
  label: string;
  /** Lucide icon name — theme and language options carry one. */
  icon?: string;
  /** One short line stating the consequence of the choice. */
  description?: string;
}
export interface RadioGroupProps extends React.HTMLAttributes<HTMLDivElement> {
  options: Array<string | RadioOption>;
  value?: string;
  onChange?: (value: string) => void;
}
export declare function RadioGroup(props: RadioGroupProps): JSX.Element;
