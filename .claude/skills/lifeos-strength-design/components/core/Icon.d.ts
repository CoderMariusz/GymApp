import * as React from 'react';

export interface IconProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** Lucide icon name, kebab-case (e.g. "dumbbell", "cloud-off"). */
  name: string;
  /** Square px size. 20 default; 24 in nav, 16 inline with label text. */
  size?: number;
  /** Any CSS colour or token reference. Defaults to currentColor. */
  color?: string;
  /** Accessible name. Omit for decorative icons — they are hidden instead. */
  title?: string;
}
export declare function Icon(props: IconProps): JSX.Element;
