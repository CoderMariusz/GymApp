import * as React from 'react';

export interface BannerProps extends React.HTMLAttributes<HTMLDivElement> {
  title: React.ReactNode;
  description?: React.ReactNode;
  /** Lucide icon name. Pick the icon that names the state: "cloud-off", "download", "wifi-off". */
  icon?: string;
  tone?: 'neutral' | 'info' | 'warning' | 'danger';
  /** Trailing control; a chevron appears instead when the whole banner is tappable. */
  action?: React.ReactNode;
}
export declare function Banner(props: BannerProps): JSX.Element;
