import * as React from 'react';

export interface PRBadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** Defaults to "PR". Polish: "Rekord". */
  label?: string;
  /** Optional qualifier, e.g. "+5 kg". */
  detail?: string;
}
export declare function PRBadge(props: PRBadgeProps): JSX.Element;
