import * as React from 'react';

export interface ScreenHeaderProps extends React.HTMLAttributes<HTMLElement> {
  title: React.ReactNode;
  subtitle?: React.ReactNode;
  /** Renders a back chevron and centres the title. */
  onBack?: () => void;
  /** Leading slot — the avatar on Home. */
  left?: React.ReactNode;
  /** Trailing slot — IconButtons, a timer, a SyncBadge. */
  right?: React.ReactNode;
  sticky?: boolean;
}
export declare function ScreenHeader(props: ScreenHeaderProps): JSX.Element;
