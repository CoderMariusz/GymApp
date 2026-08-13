import React from 'react';

export function TrendChart({ data = [], height = 150, yTicks = [], xLabels = [], style, ...rest }) {
  const max = Math.max(...data, 1), min = Math.min(...data, 0);
  const span = max - min || 1;
  const pts = data.map((v, i) => [(i / Math.max(1, data.length - 1)) * 100, 100 - ((v - min) / span) * 88 - 6]);
  const line = pts.map((p, i) => `${i ? 'L' : 'M'}${p[0].toFixed(2)},${p[1].toFixed(2)}`).join(' ');
  const area = `${line} L100,100 L0,100 Z`;
  const id = React.useId ? React.useId().replace(/:/g, '') : 'tc';
  return (
    <figure style={{ margin: 0, display: 'flex', gap: 10, ...style }} {...rest}>
      {yTicks.length > 0 && (
        <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between', height, fontSize: 11, color: 'var(--chart-axis-text)', fontFamily: 'var(--font-numeric)' }}>
          {yTicks.map((t) => <span key={t}>{t}</span>)}
        </div>
      )}
      <div style={{ flex: 1 }}>
        <svg viewBox="0 0 100 100" preserveAspectRatio="none" style={{ width: '100%', height, display: 'block' }}>
          <defs>
            <linearGradient id={'g' + id} x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="var(--action-primary)" stopOpacity="0.28" />
              <stop offset="100%" stopColor="var(--action-primary)" stopOpacity="0" />
            </linearGradient>
          </defs>
          {[25, 50, 75].map((y) => <line key={y} x1="0" y1={y} x2="100" y2={y} stroke="var(--chart-grid)" strokeWidth="0.4" vectorEffect="non-scaling-stroke" />)}
          <path d={area} fill={'url(#g' + id + ')'} />
          <path d={line} fill="none" stroke="var(--chart-line)" strokeWidth="2" vectorEffect="non-scaling-stroke" strokeLinejoin="round" strokeLinecap="round" />
          {pts.map((p, i) => <circle key={i} cx={p[0]} cy={p[1]} r="1.1" fill="var(--chart-line)" vectorEffect="non-scaling-stroke" />)}
        </svg>
        {xLabels.length > 0 && (
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, fontSize: 11, color: 'var(--chart-axis-text)' }}>
            {xLabels.map((l) => <span key={l}>{l}</span>)}
          </div>
        )}
      </div>
    </figure>
  );
}
