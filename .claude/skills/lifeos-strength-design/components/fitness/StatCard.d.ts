import * as React from 'react';

export interface StatCardProps extends React.HTMLAttributes<HTMLDivElement> {
  label: string;
  value: React.ReactNode;
  unit?: string;
  /** Signed change, e.g. "+8%". */
  delta?: string;
  deltaTone?: 'accent' | 'danger' | 'neutral';
  /** Lucide icon name, top-right. */
  icon?: string;
  /** Comparison basis, e.g. "vs last week". */
  footnote?: string;
}
export declare function StatCard(props: StatCardProps): JSX.Element;
