import React from 'react';

export function VolumeBars({ data = [], height = 120, labels = [], highlightLast, style, ...rest }) {
  const max = Math.max(...data, 1);
  return (
    <figure style={{ margin: 0, ...style }} {...rest}>
      <div style={{ display: 'flex', alignItems: 'flex-end', gap: 3, height }}>
        {data.map((v, i) => (
          <span
            key={i}
            title={String(v)}
            style={{
              flex: 1, height: `${Math.max(4, (v / max) * 100)}%`, borderRadius: 3,
              background: highlightLast && i === data.length - 1 ? 'var(--action-primary)' : v / max > 0.75 ? 'var(--chart-bar)' : 'var(--chart-bar-muted)',
            }}
          />
        ))}
      </div>
      {labels.length > 0 && (
        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, fontSize: 11, color: 'var(--chart-axis-text)' }}>
          {labels.map((l, i) => <span key={i}>{l}</span>)}
        </div>
      )}
    </figure>
  );
}
