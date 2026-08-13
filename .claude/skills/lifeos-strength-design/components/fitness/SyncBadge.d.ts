import * as React from 'react';

/**
 * The six-state sync indicator. Sync state is a first-class visual element,
 * never only a toast (DESIGN-BRIEF C-3).
 * @startingPoint section="Fitness" subtitle="All six sync states" viewport="700x160"
 */
export interface SyncBadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** draft_local · queued · syncing · saved · failed · conflict. */
  state?: 'draft_local' | 'queued' | 'syncing' | 'saved' | 'failed' | 'conflict';
  /** Override the default English label (Polish strings run 20–30% longer). */
  label?: string;
  compact?: boolean;
}
export declare function SyncBadge(props: SyncBadgeProps): JSX.Element;
export declare const SYNC_STATES: Record<string, { label: string; icon: string; fg: string; bg: string }>;
