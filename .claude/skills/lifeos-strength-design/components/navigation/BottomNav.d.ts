import * as React from 'react';

/**
 * The five-destination app shell bar with a centred start-workout action.
 * The destination count is fixed at five (DESIGN-BRIEF C-1); Settings is not a tab (C-2).
 * @startingPoint section="Navigation" subtitle="Five-tab shell with centre action" viewport="700x140"
 */
export interface BottomNavProps extends React.HTMLAttributes<HTMLElement> {
  /** Four flanking tabs; the centre action is the fifth destination. */
  items?: Array<{ key: string; label: string; icon: string }>;
  active?: string;
  onSelect?: (key: string) => void;
  onAdd?: () => void;
  /** Accessible name for the centre action. */
  addLabel?: string;
}
export declare function BottomNav(props: BottomNavProps): JSX.Element;
export declare const NAV_ITEMS: Array<{ key: string; label: string; icon: string }>;
