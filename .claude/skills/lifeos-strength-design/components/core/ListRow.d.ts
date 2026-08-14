import * as React from 'react';

export interface ListRowProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Leading Lucide icon name. */
  icon?: string;
  label: React.ReactNode;
  /** One line naming the consequence of the setting, not marketing copy. */
  description?: React.ReactNode;
  /** Current value, right-aligned — a navigating row states its value here. */
  value?: React.ReactNode;
  /** Trailing control: a Switch, a Badge, a Button. Suppresses the chevron. */
  control?: React.ReactNode;
  chevron?: boolean;
  tone?: 'default' | 'danger';
  disabled?: boolean;
}
export declare function ListRow(props: ListRowProps): JSX.Element;
