import * as React from 'react';

export interface ChipProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  /** Selected chips take the lime fill. */
  selected?: boolean;
  icon?: string;
}
export declare function Chip(props: ChipProps): JSX.Element;
