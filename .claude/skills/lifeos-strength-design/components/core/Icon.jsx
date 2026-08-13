import React from 'react';

const CDN = 'https://unpkg.com/lucide-static/icons/';
const cache = {};

/* Lucide, fetched once per glyph and injected inline so the icon survives
   DOM-rerender capture (thumbnails, PNG/PDF/PPTX export). A CSS mask of the
   same file stands in for the frame or two before the fetch resolves.
   SUBSTITUTION: the source repo ships no icon assets; Lucide matches the
   2px-stroke line icons in the v1.0 mockups. */
function useGlyph(name) {
  const [markup, setMarkup] = React.useState(cache[name] && cache[name].markup);
  React.useEffect(() => {
    if (!name) return;
    if (cache[name] && cache[name].markup) { setMarkup(cache[name].markup); return; }
    if (!cache[name]) {
      cache[name] = {
        promise: fetch(CDN + name + '.svg')
          .then((r) => (r.ok ? r.text() : ''))
          .then((t) => {
            const i = t ? t.indexOf('<svg') : -1;
            /* Strip width/height on the ROOT tag only — .ds-icon>svg sizes the glyph.
               Stripping globally would delete <rect width height> geometry. */
            const svg = i >= 0
              ? t.slice(i).replace(/^<svg[^>]*>/, (m) => m.replace(/\s(width|height)="[^"]*"/g, ''))
              : '';
            cache[name].markup = svg;
            return svg;
          })
          .catch(() => ''),
      };
    }
    let alive = true;
    cache[name].promise.then((t) => { if (alive) setMarkup(t); });
    return () => { alive = false; };
  }, [name]);
  return markup;
}

export function Icon({ name, size = 20, color = 'currentColor', title, style, ...rest }) {
  const markup = useGlyph(name);
  const url = CDN + name + '.svg';
  const box = {
    display: 'inline-block', width: size, height: size, flex: '0 0 auto',
    color, lineHeight: 0, ...style,
  };
  const a11y = {
    role: title ? 'img' : undefined,
    'aria-label': title || undefined,
    'aria-hidden': title ? undefined : 'true',
  };
  if (markup) {
    return <span className="ds-icon" {...a11y} style={box} dangerouslySetInnerHTML={{ __html: markup }} {...rest} />;
  }
  return (
    <span
      className="ds-icon"
      {...a11y}
      style={{
        ...box,
        background: color,
        WebkitMaskImage: `url(${url})`, maskImage: `url(${url})`,
        WebkitMaskRepeat: 'no-repeat', maskRepeat: 'no-repeat',
        WebkitMaskPosition: 'center', maskPosition: 'center',
        WebkitMaskSize: 'contain', maskSize: 'contain',
      }}
      {...rest}
    />
  );
}
