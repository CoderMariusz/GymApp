import * as React from 'react';

export interface ExerciseRowProps extends React.HTMLAttributes<HTMLDivElement> {
  name: string;
  /** Secondary line: equipment, muscle group, or last-session recall. */
  meta?: React.ReactNode;
  /** Lucide icon name for the leading tile. Defaults to "dumbbell". */
  thumb?: string;
  /** Replaces the trailing chevron — a value, Badge, or control. */
  right?: React.ReactNode;
  badge?: React.ReactNode;
}
export declare function ExerciseRow(props: ExerciseRowProps): JSX.Element;
