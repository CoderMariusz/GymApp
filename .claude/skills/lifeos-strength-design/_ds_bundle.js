/* @ds-bundle: {"format":4,"namespace":"LifeOSStrengthDesignSystem_576cfb","components":[{"name":"Badge","sourcePath":"components/core/Badge.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Card","sourcePath":"components/core/Card.jsx"},{"name":"Chip","sourcePath":"components/core/Chip.jsx"},{"name":"Icon","sourcePath":"components/core/Icon.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"Input","sourcePath":"components/core/Input.jsx"},{"name":"SegmentedControl","sourcePath":"components/core/SegmentedControl.jsx"},{"name":"Select","sourcePath":"components/core/Select.jsx"},{"name":"Stepper","sourcePath":"components/core/Stepper.jsx"},{"name":"Banner","sourcePath":"components/feedback/Banner.jsx"},{"name":"ConfirmDialog","sourcePath":"components/feedback/ConfirmDialog.jsx"},{"name":"EmptyState","sourcePath":"components/feedback/EmptyState.jsx"},{"name":"ExerciseRow","sourcePath":"components/fitness/ExerciseRow.jsx"},{"name":"PRBadge","sourcePath":"components/fitness/PRBadge.jsx"},{"name":"RestTimer","sourcePath":"components/fitness/RestTimer.jsx"},{"name":"SetRow","sourcePath":"components/fitness/SetRow.jsx"},{"name":"StatCard","sourcePath":"components/fitness/StatCard.jsx"},{"name":"SYNC_STATES","sourcePath":"components/fitness/SyncBadge.jsx"},{"name":"SyncBadge","sourcePath":"components/fitness/SyncBadge.jsx"},{"name":"TrendChart","sourcePath":"components/fitness/TrendChart.jsx"},{"name":"VolumeBars","sourcePath":"components/fitness/VolumeBars.jsx"},{"name":"WeekDots","sourcePath":"components/fitness/WeekDots.jsx"},{"name":"NAV_ITEMS","sourcePath":"components/navigation/BottomNav.jsx"},{"name":"BottomNav","sourcePath":"components/navigation/BottomNav.jsx"},{"name":"ScreenHeader","sourcePath":"components/navigation/ScreenHeader.jsx"}],"sourceHashes":{"components/core/Badge.jsx":"58a61b96b317","components/core/Button.jsx":"bbc1eabc21d1","components/core/Card.jsx":"270cdc4cf1c7","components/core/Chip.jsx":"f34fdbda4251","components/core/Icon.jsx":"b9719924c078","components/core/IconButton.jsx":"5f1bac230c91","components/core/Input.jsx":"a7f3b403396d","components/core/SegmentedControl.jsx":"48e854a22f5b","components/core/Select.jsx":"1ea5c6715457","components/core/Stepper.jsx":"7d0df9ba7739","components/feedback/Banner.jsx":"65b63e7c8b7c","components/feedback/ConfirmDialog.jsx":"6b447e92ce3a","components/feedback/EmptyState.jsx":"d4a2ab400c48","components/fitness/ExerciseRow.jsx":"563e31692320","components/fitness/PRBadge.jsx":"d3fc20d10535","components/fitness/RestTimer.jsx":"8bf671aabf99","components/fitness/SetRow.jsx":"e58be0953d08","components/fitness/StatCard.jsx":"1cb73d8013e5","components/fitness/SyncBadge.jsx":"71126c9fb20e","components/fitness/TrendChart.jsx":"fa94ff3dfd18","components/fitness/VolumeBars.jsx":"a7d82bed02f2","components/fitness/WeekDots.jsx":"e49b8613308f","components/navigation/BottomNav.jsx":"09b5dcf203e0","components/navigation/ScreenHeader.jsx":"241c8f51eb2b","screens/auth/Auth.jsx":"2cf788975b1d","screens/catalog/ExerciseDetail.jsx":"d5af0c75e11a","screens/desktop/DesktopScreens.jsx":"efc9db22f158","screens/history/History.jsx":"0c5df32e04c2","screens/selector/Selector.jsx":"6a70fedc7b26","ui_kits/desktop/DashboardView.jsx":"91e801a55d72","ui_kits/desktop/DesktopShell.jsx":"cdf22eb4e52f","ui_kits/desktop/ProgressView.jsx":"9039855f0820","ui_kits/desktop/WorkoutView.jsx":"dfc9f61766e2","ui_kits/mobile-app/ExercisesScreen.jsx":"b24a8b9d6f21","ui_kits/mobile-app/HomeScreen.jsx":"f713ad1f98b4","ui_kits/mobile-app/ProgressScreen.jsx":"e3a5b6c44404","ui_kits/mobile-app/SignInScreen.jsx":"d17eb296e39d","ui_kits/mobile-app/SummaryScreen.jsx":"ab1b6c5b0243","ui_kits/mobile-app/WorkoutScreen.jsx":"5d39085039d4","ui_kits/mobile-app/app.jsx":"812cd60afc28","ui_kits/mobile-app/shell.jsx":"92192093eac7"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.LifeOSStrengthDesignSystem_576cfb = window.LifeOSStrengthDesignSystem_576cfb || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/core/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const pads = {
  none: 0,
  tight: 'var(--card-pad-tight)',
  default: 'var(--card-pad)',
  loose: 'var(--space-5)'
};
function Card({
  children,
  tone = 'default',
  pad = 'default',
  radius = 'lg',
  interactive,
  style,
  ...rest
}) {
  const [hover, setHover] = React.useState(false);
  const tones = {
    default: {
      bg: 'var(--surface-card)',
      bd: 'var(--border-subtle)'
    },
    raised: {
      bg: 'var(--surface-raised)',
      bd: 'var(--border-default)'
    },
    sunken: {
      bg: 'var(--surface-sunken)',
      bd: 'var(--border-subtle)'
    },
    accent: {
      bg: 'var(--set-active-bg)',
      bd: 'var(--border-accent)'
    },
    plain: {
      bg: 'transparent',
      bd: 'transparent'
    }
  };
  const t = tones[tone] || tones.default;
  return /*#__PURE__*/React.createElement("div", _extends({
    onMouseEnter: () => interactive && setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      background: hover ? 'var(--surface-raised)' : t.bg,
      border: `1px solid ${t.bd}`,
      borderRadius: radius === 'xl' ? 'var(--radius-xl)' : radius === 'md' ? 'var(--radius-md)' : 'var(--radius-lg)',
      padding: pads[pad],
      boxShadow: 'var(--shadow-card)',
      cursor: interactive ? 'pointer' : undefined,
      transition: 'background var(--dur-fast) var(--ease-standard)',
      ...style
    }
  }, rest), children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Card.jsx", error: String((e && e.message) || e) }); }

// components/core/Icon.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
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
    if (cache[name] && cache[name].markup) {
      setMarkup(cache[name].markup);
      return;
    }
    if (!cache[name]) {
      cache[name] = {
        promise: fetch(CDN + name + '.svg').then(r => r.ok ? r.text() : '').then(t => {
          const i = t ? t.indexOf('<svg') : -1;
          /* Strip width/height on the ROOT tag only — .ds-icon>svg sizes the glyph.
             Stripping globally would delete <rect width height> geometry. */
          const svg = i >= 0 ? t.slice(i).replace(/^<svg[^>]*>/, m => m.replace(/\s(width|height)="[^"]*"/g, '')) : '';
          cache[name].markup = svg;
          return svg;
        }).catch(() => '')
      };
    }
    let alive = true;
    cache[name].promise.then(t => {
      if (alive) setMarkup(t);
    });
    return () => {
      alive = false;
    };
  }, [name]);
  return markup;
}
function Icon({
  name,
  size = 20,
  color = 'currentColor',
  title,
  style,
  ...rest
}) {
  const markup = useGlyph(name);
  const url = CDN + name + '.svg';
  const box = {
    display: 'inline-block',
    width: size,
    height: size,
    flex: '0 0 auto',
    color,
    lineHeight: 0,
    ...style
  };
  const a11y = {
    role: title ? 'img' : undefined,
    'aria-label': title || undefined,
    'aria-hidden': title ? undefined : 'true'
  };
  if (markup) {
    return /*#__PURE__*/React.createElement("span", _extends({
      className: "ds-icon"
    }, a11y, {
      style: box,
      dangerouslySetInnerHTML: {
        __html: markup
      }
    }, rest));
  }
  return /*#__PURE__*/React.createElement("span", _extends({
    className: "ds-icon"
  }, a11y, {
    style: {
      ...box,
      background: color,
      WebkitMaskImage: `url(${url})`,
      maskImage: `url(${url})`,
      WebkitMaskRepeat: 'no-repeat',
      maskRepeat: 'no-repeat',
      WebkitMaskPosition: 'center',
      maskPosition: 'center',
      WebkitMaskSize: 'contain',
      maskSize: 'contain'
    }
  }, rest));
}
Object.assign(__ds_scope, { Icon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Icon.jsx", error: String((e && e.message) || e) }); }

// components/core/Badge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const tones = {
  neutral: {
    fg: 'var(--text-secondary)',
    bg: 'var(--surface-inset)'
  },
  accent: {
    fg: 'var(--feedback-success)',
    bg: 'var(--feedback-success-quiet)'
  },
  info: {
    fg: 'var(--feedback-info)',
    bg: 'var(--feedback-info-quiet)'
  },
  warning: {
    fg: 'var(--feedback-warning)',
    bg: 'var(--feedback-warning-quiet)'
  },
  danger: {
    fg: 'var(--feedback-danger)',
    bg: 'var(--feedback-danger-quiet)'
  },
  solid: {
    fg: 'var(--action-primary-text)',
    bg: 'var(--action-primary)'
  }
};
function Badge({
  children,
  tone = 'neutral',
  icon,
  size = 'md',
  style,
  ...rest
}) {
  const t = tones[tone] || tones.neutral;
  const sm = size === 'sm';
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: sm ? 4 : 6,
      height: sm ? 20 : 26,
      padding: sm ? '0 7px' : '0 10px',
      background: t.bg,
      color: t.fg,
      borderRadius: 'var(--radius-pill)',
      fontFamily: 'var(--font-ui)',
      fontSize: sm ? 10 : 11,
      fontWeight: 'var(--fw-extrabold)',
      letterSpacing: '.06em',
      textTransform: 'uppercase',
      whiteSpace: 'nowrap',
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: sm ? 11 : 13
  }), children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Badge.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const sizes = {
  sm: {
    h: 36,
    px: 14,
    fs: 13,
    gap: 6,
    ls: '.04em'
  },
  md: {
    h: 44,
    px: 18,
    fs: 14,
    gap: 8,
    ls: '.04em'
  },
  lg: {
    h: 52,
    px: 22,
    fs: 15,
    gap: 10,
    ls: '.08em'
  }
};
const variants = {
  primary: {
    bg: 'var(--action-primary)',
    fg: 'var(--action-primary-text)',
    bd: 'transparent'
  },
  secondary: {
    bg: 'var(--action-secondary)',
    fg: 'var(--action-secondary-text)',
    bd: 'var(--border-default)'
  },
  ghost: {
    bg: 'transparent',
    fg: 'var(--text-primary)',
    bd: 'transparent'
  },
  danger: {
    bg: 'var(--feedback-danger)',
    fg: '#fff',
    bd: 'transparent'
  }
};
function Button({
  children,
  variant = 'primary',
  size = 'md',
  shape = 'rounded',
  block,
  iconLeft,
  iconRight,
  uppercase,
  disabled,
  style,
  ...rest
}) {
  const s = sizes[size] || sizes.md;
  const v = variants[variant] || variants.primary;
  const [hover, setHover] = React.useState(false);
  const [press, setPress] = React.useState(false);
  let bg = v.bg;
  if (!disabled && variant === 'primary') bg = press ? 'var(--action-primary-press)' : hover ? 'var(--action-primary-hover)' : v.bg;
  if (!disabled && variant === 'secondary' && hover) bg = 'var(--action-secondary-hover)';
  if (!disabled && variant === 'ghost' && hover) bg = 'var(--action-ghost-hover)';
  return /*#__PURE__*/React.createElement("button", _extends({
    disabled: disabled,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => {
      setHover(false);
      setPress(false);
    },
    onMouseDown: () => setPress(true),
    onMouseUp: () => setPress(false),
    style: {
      display: block ? 'flex' : 'inline-flex',
      width: block ? '100%' : undefined,
      alignItems: 'center',
      justifyContent: 'center',
      gap: s.gap,
      minHeight: s.h,
      height: s.h,
      padding: `0 ${s.px}px`,
      background: disabled ? 'var(--action-disabled)' : bg,
      color: disabled ? 'var(--action-disabled-text)' : v.fg,
      border: `1px solid ${disabled ? 'transparent' : v.bd}`,
      borderRadius: shape === 'pill' ? 'var(--radius-pill)' : 'var(--radius-md)',
      fontFamily: 'var(--font-ui)',
      fontSize: s.fs,
      fontWeight: 'var(--fw-extrabold)',
      letterSpacing: uppercase ? s.ls : '0',
      textTransform: uppercase ? 'uppercase' : 'none',
      cursor: disabled ? 'not-allowed' : 'pointer',
      transform: press && !disabled ? 'scale(var(--press-scale))' : 'none',
      transition: 'background var(--dur-fast) var(--ease-standard),transform var(--dur-fast) var(--ease-standard)',
      ...style
    }
  }, rest), iconLeft && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: iconLeft,
    size: size === 'sm' ? 16 : 18
  }), children, iconRight && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: iconRight,
    size: size === 'sm' ? 16 : 18
  }));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/Chip.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Chip({
  children,
  selected,
  icon,
  onClick,
  style,
  ...rest
}) {
  const [hover, setHover] = React.useState(false);
  return /*#__PURE__*/React.createElement("button", _extends({
    "aria-pressed": !!selected,
    onClick: onClick,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      minHeight: 34,
      padding: '0 14px',
      background: selected ? 'var(--action-primary)' : hover ? 'var(--action-secondary-hover)' : 'var(--action-secondary)',
      color: selected ? 'var(--action-primary-text)' : 'var(--text-secondary)',
      border: `1px solid ${selected ? 'transparent' : 'var(--border-subtle)'}`,
      borderRadius: 'var(--radius-pill)',
      cursor: 'pointer',
      fontFamily: 'var(--font-ui)',
      fontSize: 13,
      fontWeight: 'var(--fw-bold)',
      whiteSpace: 'nowrap',
      transition: 'background var(--dur-fast) var(--ease-standard)',
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 14
  }), children);
}
Object.assign(__ds_scope, { Chip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Chip.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function IconButton({
  icon,
  label,
  variant = 'ghost',
  size = 44,
  iconSize = 20,
  style,
  ...rest
}) {
  const [hover, setHover] = React.useState(false);
  const bg = variant === 'filled' ? 'var(--surface-raised)' : variant === 'accent' ? 'var(--action-primary)' : 'transparent';
  return /*#__PURE__*/React.createElement("button", _extends({
    "aria-label": label,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: size,
      height: size,
      minWidth: 'var(--hit-min)',
      minHeight: 'var(--hit-min)',
      background: hover && variant !== 'accent' ? 'var(--action-ghost-hover)' : bg,
      color: variant === 'accent' ? 'var(--action-primary-text)' : 'var(--text-primary)',
      border: variant === 'filled' ? '1px solid var(--border-subtle)' : '1px solid transparent',
      borderRadius: 'var(--radius-pill)',
      cursor: 'pointer',
      transition: 'background var(--dur-fast) var(--ease-standard)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: iconSize
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/core/Input.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Input({
  label,
  hint,
  error,
  icon,
  suffix,
  align = 'left',
  numeric,
  style,
  ...rest
}) {
  const [focus, setFocus] = React.useState(false);
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 6,
      ...style
    }
  }, label && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--type-label-size)',
      fontWeight: 'var(--fw-bold)',
      color: 'var(--text-secondary)'
    }
  }, label), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      height: 'var(--hit-min)',
      padding: '0 14px',
      background: 'var(--surface-raised)',
      border: `1px solid ${error ? 'var(--feedback-danger)' : focus ? 'var(--border-accent)' : 'var(--border-default)'}`,
      borderRadius: 'var(--radius-sm)',
      transition: 'border-color var(--dur-fast) var(--ease-standard)'
    }
  }, icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 16,
    color: "var(--text-tertiary)"
  }), /*#__PURE__*/React.createElement("input", _extends({
    onFocus: () => setFocus(true),
    onBlur: () => setFocus(false),
    style: {
      flex: 1,
      minWidth: 0,
      background: 'transparent',
      border: 'none',
      outline: 'none',
      color: 'var(--text-primary)',
      textAlign: align,
      fontFamily: numeric ? 'var(--font-numeric)' : 'var(--font-ui)',
      fontVariantNumeric: numeric ? 'tabular-nums' : 'normal',
      fontSize: numeric ? 'var(--type-metric-sm-size)' : 'var(--type-body-size)',
      fontWeight: numeric ? 'var(--fw-bold)' : 'var(--fw-medium)'
    }
  }, rest)), suffix && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      fontWeight: 'var(--fw-bold)'
    }
  }, suffix)), (error || hint) && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 5,
      fontSize: 12,
      color: error ? 'var(--feedback-danger)' : 'var(--text-tertiary)'
    }
  }, error && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "circle-alert",
    size: 13
  }), error || hint));
}
Object.assign(__ds_scope, { Input });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Input.jsx", error: String((e && e.message) || e) }); }

// components/core/SegmentedControl.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function SegmentedControl({
  options = [],
  value,
  onChange,
  size = 'md',
  style,
  ...rest
}) {
  const h = size === 'sm' ? 32 : 38;
  return /*#__PURE__*/React.createElement("div", _extends({
    role: "tablist",
    style: {
      display: 'flex',
      gap: 4,
      padding: 4,
      background: 'var(--surface-raised)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-pill)',
      ...style
    }
  }, rest), options.map(o => {
    const key = typeof o === 'string' ? o : o.value;
    const label = typeof o === 'string' ? o : o.label;
    const on = key === value;
    return /*#__PURE__*/React.createElement("button", {
      key: key,
      role: "tab",
      "aria-selected": on,
      onClick: () => onChange && onChange(key),
      style: {
        flex: 1,
        height: h,
        minWidth: 60,
        padding: '0 14px',
        background: on ? 'var(--action-primary)' : 'transparent',
        color: on ? 'var(--action-primary-text)' : 'var(--text-secondary)',
        border: 'none',
        borderRadius: 'var(--radius-pill)',
        cursor: 'pointer',
        fontFamily: 'var(--font-ui)',
        fontSize: 13,
        fontWeight: 'var(--fw-extrabold)',
        transition: 'background var(--dur-base) var(--ease-standard),color var(--dur-base) var(--ease-standard)'
      }
    }, label);
  }));
}
Object.assign(__ds_scope, { SegmentedControl });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/SegmentedControl.jsx", error: String((e && e.message) || e) }); }

// components/core/Select.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Select({
  label,
  value,
  options = [],
  onChange,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 6,
      ...style
    }
  }, label && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--type-label-size)',
      fontWeight: 'var(--fw-bold)',
      color: 'var(--text-secondary)'
    }
  }, label), /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'relative',
      display: 'flex',
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement("select", _extends({
    value: value,
    onChange: e => onChange && onChange(e.target.value),
    style: {
      appearance: 'none',
      width: '100%',
      height: 'var(--hit-min)',
      padding: '0 40px 0 14px',
      background: 'var(--surface-raised)',
      color: 'var(--text-primary)',
      border: '1px solid var(--border-default)',
      borderRadius: 'var(--radius-sm)',
      fontFamily: 'var(--font-ui)',
      fontSize: 'var(--type-body-size)',
      fontWeight: 'var(--fw-semibold)',
      cursor: 'pointer'
    }
  }, rest), options.map(o => {
    const v = typeof o === 'string' ? o : o.value;
    const l = typeof o === 'string' ? o : o.label;
    return /*#__PURE__*/React.createElement("option", {
      key: v,
      value: v
    }, l);
  })), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-down",
    size: 18,
    color: "var(--text-tertiary)",
    style: {
      position: 'absolute',
      right: 14,
      pointerEvents: 'none'
    }
  })));
}
Object.assign(__ds_scope, { Select });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Select.jsx", error: String((e && e.message) || e) }); }

// components/core/Stepper.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Stepper({
  value = 0,
  step = 2.5,
  unit = 'kg',
  min = 0,
  onChange,
  size = 'md',
  style,
  ...rest
}) {
  const big = size === 'lg';
  const set = v => onChange && onChange(Math.max(min, Math.round(v * 100) / 100));
  const btn = (icon, delta, label) => /*#__PURE__*/React.createElement("button", {
    "aria-label": label,
    onClick: () => set(value + delta),
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: big ? 56 : 44,
      height: big ? 56 : 44,
      flex: '0 0 auto',
      background: 'var(--surface-raised)',
      color: 'var(--text-primary)',
      border: '1px solid var(--border-default)',
      borderRadius: 'var(--radius-pill)',
      cursor: 'pointer',
      transition: 'background var(--dur-fast) var(--ease-standard)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: big ? 22 : 18,
    color: "var(--action-primary)"
  }));
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      gap: 12,
      padding: big ? '10px 12px' : '6px 8px',
      background: 'var(--surface-card)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-lg)',
      ...style
    }
  }, rest), btn('minus', -step, `Decrease by ${step} ${unit}`), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      lineHeight: 1
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "num",
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: big ? 'var(--type-metric-hero-size)' : 'var(--type-metric-size)',
      fontWeight: 'var(--fw-bold)',
      color: 'var(--text-primary)',
      letterSpacing: '-.02em'
    }
  }, value), /*#__PURE__*/React.createElement("span", {
    style: {
      marginTop: 4,
      fontSize: 11,
      letterSpacing: '.08em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 'var(--fw-bold)'
    }
  }, unit)), btn('plus', step, `Increase by ${step} ${unit}`));
}
Object.assign(__ds_scope, { Stepper });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Stepper.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Banner.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const tones = {
  neutral: {
    fg: 'var(--text-secondary)',
    accent: 'var(--text-secondary)',
    bg: 'var(--surface-card)'
  },
  info: {
    fg: 'var(--text-primary)',
    accent: 'var(--feedback-info)',
    bg: 'var(--surface-card)'
  },
  warning: {
    fg: 'var(--text-primary)',
    accent: 'var(--feedback-warning)',
    bg: 'var(--surface-card)'
  },
  danger: {
    fg: 'var(--text-primary)',
    accent: 'var(--feedback-danger)',
    bg: 'var(--surface-card)'
  }
};
function Banner({
  title,
  description,
  icon = 'info',
  tone = 'neutral',
  action,
  onClick,
  style,
  ...rest
}) {
  const t = tones[tone] || tones.neutral;
  return /*#__PURE__*/React.createElement("div", _extends({
    onClick: onClick,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '12px 14px',
      background: t.bg,
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-lg)',
      cursor: onClick ? 'pointer' : 'default',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 20,
    color: t.accent
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 13,
      fontWeight: 'var(--fw-extrabold)',
      color: 'var(--text-primary)'
    }
  }, title), description && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      marginTop: 2,
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, description)), action || onClick && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-right",
    size: 18,
    color: "var(--text-tertiary)"
  }));
}
Object.assign(__ds_scope, { Banner });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Banner.jsx", error: String((e && e.message) || e) }); }

// components/feedback/ConfirmDialog.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function ConfirmDialog({
  title,
  description,
  recovery,
  confirmLabel = 'Delete',
  cancelLabel = 'Cancel',
  tone = 'danger',
  onConfirm,
  onCancel,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    role: "dialog",
    "aria-modal": "true",
    style: {
      width: '100%',
      maxWidth: 340,
      padding: 'var(--space-5)',
      background: 'var(--surface-raised)',
      border: '1px solid var(--border-default)',
      borderRadius: 'var(--radius-xl)',
      boxShadow: 'var(--shadow-float)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: 40,
      height: 40,
      marginBottom: 12,
      background: tone === 'danger' ? 'var(--feedback-danger-quiet)' : 'var(--surface-inset)',
      borderRadius: 'var(--radius-pill)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: tone === 'danger' ? 'trash-2' : 'circle-alert',
    size: 20,
    color: tone === 'danger' ? 'var(--feedback-danger)' : 'var(--text-secondary)'
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 'var(--type-title-size)',
      lineHeight: 'var(--type-title-lh)',
      fontWeight: 'var(--fw-bold)'
    }
  }, title), description && /*#__PURE__*/React.createElement("p", {
    style: {
      margin: '8px 0 0',
      fontSize: 13,
      lineHeight: '19px',
      color: 'var(--text-secondary)'
    }
  }, description), recovery && /*#__PURE__*/React.createElement("p", {
    style: {
      margin: '10px 0 0',
      padding: '10px 12px',
      background: 'var(--surface-inset)',
      borderRadius: 'var(--radius-sm)',
      fontSize: 12,
      lineHeight: '17px',
      color: 'var(--text-tertiary)'
    }
  }, recovery), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 'var(--space-5)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Button, {
    variant: "secondary",
    block: true,
    onClick: onCancel
  }, cancelLabel), /*#__PURE__*/React.createElement(__ds_scope.Button, {
    variant: tone === 'danger' ? 'danger' : 'primary',
    block: true,
    onClick: onConfirm
  }, confirmLabel)));
}
Object.assign(__ds_scope, { ConfirmDialog });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/ConfirmDialog.jsx", error: String((e && e.message) || e) }); }

// components/feedback/EmptyState.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function EmptyState({
  icon = 'dumbbell',
  title,
  description,
  action,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      textAlign: 'center',
      gap: 8,
      padding: 'var(--space-7) var(--space-5)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: 56,
      height: 56,
      marginBottom: 4,
      background: 'var(--surface-inset)',
      borderRadius: 'var(--radius-pill)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 24,
    color: "var(--text-tertiary)"
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 'var(--type-heading-size)',
      fontWeight: 'var(--fw-bold)',
      color: 'var(--text-primary)'
    }
  }, title), description && /*#__PURE__*/React.createElement("span", {
    style: {
      maxWidth: 280,
      fontSize: 13,
      lineHeight: '18px',
      color: 'var(--text-tertiary)'
    }
  }, description), action && /*#__PURE__*/React.createElement("span", {
    style: {
      marginTop: 8
    }
  }, action));
}
Object.assign(__ds_scope, { EmptyState });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/EmptyState.jsx", error: String((e && e.message) || e) }); }

// components/fitness/ExerciseRow.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function ExerciseRow({
  name,
  meta,
  thumb,
  right,
  badge,
  onClick,
  style,
  ...rest
}) {
  const [hover, setHover] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", _extends({
    onClick: onClick,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      minHeight: 60,
      padding: '10px 14px',
      background: hover ? 'var(--surface-raised)' : 'var(--surface-card)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-lg)',
      cursor: onClick ? 'pointer' : 'default',
      transition: 'background var(--dur-fast) var(--ease-standard)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: 40,
      height: 40,
      flex: '0 0 auto',
      background: 'var(--surface-inset)',
      borderRadius: 'var(--radius-md)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: thumb || 'dumbbell',
    size: 20,
    color: "var(--text-secondary)"
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--type-body-size)',
      fontWeight: 'var(--fw-extrabold)',
      color: 'var(--text-primary)',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, name), badge), meta && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      marginTop: 2,
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, meta)), right || /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-right",
    size: 18,
    color: "var(--text-tertiary)"
  }));
}
Object.assign(__ds_scope, { ExerciseRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fitness/ExerciseRow.jsx", error: String((e && e.message) || e) }); }

// components/fitness/PRBadge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function PRBadge({
  label = 'PR',
  detail,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      height: 28,
      padding: '0 10px',
      background: 'var(--feedback-success-quiet)',
      color: 'var(--feedback-success)',
      border: '1px solid var(--border-accent)',
      borderRadius: 'var(--radius-pill)',
      fontFamily: 'var(--font-ui)',
      fontSize: 11,
      fontWeight: 'var(--fw-extrabold)',
      letterSpacing: '.08em',
      textTransform: 'uppercase',
      whiteSpace: 'nowrap',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "trophy",
    size: 13
  }), label, detail && /*#__PURE__*/React.createElement("span", {
    style: {
      opacity: .8,
      letterSpacing: 0,
      textTransform: 'none',
      fontWeight: 'var(--fw-bold)'
    }
  }, detail));
}
Object.assign(__ds_scope, { PRBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fitness/PRBadge.jsx", error: String((e && e.message) || e) }); }

// components/fitness/RestTimer.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function RestTimer({
  remaining = '1:45',
  running = true,
  nextLabel,
  nextValue,
  onToggle,
  onSkip,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      alignItems: 'stretch',
      gap: 8,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      padding: '10px 14px',
      background: 'var(--surface-card)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-lg)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 10,
      letterSpacing: '.1em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 'var(--fw-bold)'
    }
  }, "Rest timer"), /*#__PURE__*/React.createElement("div", {
    className: "num",
    style: {
      marginTop: 2,
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 'var(--type-timer-size)',
      lineHeight: 'var(--type-timer-lh)',
      fontWeight: 'var(--fw-bold)',
      color: 'var(--action-primary)'
    }
  }, remaining)), /*#__PURE__*/React.createElement("button", {
    "aria-label": running ? 'Pause rest timer' : 'Resume rest timer',
    onClick: onToggle,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: 56,
      minHeight: 'var(--hit-min)',
      background: 'var(--surface-raised)',
      color: 'var(--text-primary)',
      border: '1px solid var(--border-default)',
      borderRadius: 'var(--radius-lg)',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: running ? 'pause' : 'play',
    size: 20
  })), nextLabel && /*#__PURE__*/React.createElement("button", {
    onClick: onSkip,
    style: {
      flex: 1.2,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      gap: 8,
      padding: '10px 12px',
      textAlign: 'left',
      background: 'var(--surface-card)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-lg)',
      cursor: 'pointer',
      color: 'var(--text-primary)'
    }
  }, /*#__PURE__*/React.createElement("span", null, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 10,
      letterSpacing: '.1em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 'var(--fw-bold)'
    }
  }, nextLabel), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      marginTop: 3,
      fontSize: 13,
      fontWeight: 'var(--fw-extrabold)'
    }
  }, nextValue)), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-right",
    size: 18,
    color: "var(--text-tertiary)"
  })));
}
Object.assign(__ds_scope, { RestTimer });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fitness/RestTimer.jsx", error: String((e && e.message) || e) }); }

// components/fitness/SetRow.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const cell = flex => ({
  flex,
  textAlign: 'center',
  fontFamily: 'var(--font-numeric)',
  fontVariantNumeric: 'tabular-nums',
  fontSize: 'var(--type-metric-sm-size)',
  fontWeight: 'var(--fw-bold)'
});
function SetRow({
  index,
  weight,
  reps,
  rir,
  rest,
  state = 'proposed',
  warmup,
  unit = 'kg',
  onConfirm,
  style,
  ...rest_
}) {
  const logged = state === 'logged';
  const active = state === 'active';
  const fg = logged ? 'var(--set-logged-text)' : 'var(--set-proposed-text)';
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      minHeight: 'var(--hit-min)',
      padding: '0 10px 0 4px',
      background: active ? 'var(--set-active-bg)' : 'transparent',
      border: `1px solid ${active ? 'var(--set-active-border)' : 'transparent'}`,
      borderRadius: 'var(--radius-md)',
      borderLeft: warmup ? '3px solid var(--set-warmup-rail)' : undefined,
      ...style
    }
  }, rest_), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 34,
      textAlign: 'center',
      fontFamily: 'var(--font-numeric)',
      fontSize: 13,
      fontWeight: 'var(--fw-bold)',
      color: warmup ? 'var(--set-warmup-text)' : 'var(--text-tertiary)'
    }
  }, warmup ? 'W' : index), /*#__PURE__*/React.createElement("span", {
    style: {
      ...cell(1),
      color: fg
    }
  }, weight), /*#__PURE__*/React.createElement("span", {
    style: {
      ...cell(1),
      color: fg
    }
  }, reps), rir !== undefined && /*#__PURE__*/React.createElement("span", {
    style: {
      ...cell(1),
      color: 'var(--text-tertiary)',
      fontSize: 14
    }
  }, rir), rest !== undefined && /*#__PURE__*/React.createElement("span", {
    style: {
      ...cell(1),
      color: active ? 'var(--text-accent)' : 'var(--text-tertiary)',
      fontSize: 14
    }
  }, rest), /*#__PURE__*/React.createElement("button", {
    "aria-label": logged ? `Set ${index} logged` : `Confirm set ${index}`,
    onClick: onConfirm,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: 30,
      height: 30,
      marginLeft: 2,
      flex: '0 0 auto',
      cursor: 'pointer',
      background: logged ? 'transparent' : 'transparent',
      border: `2px solid ${logged ? 'transparent' : active ? 'var(--set-active-border)' : 'var(--set-proposed-border)'}`,
      borderRadius: 'var(--radius-pill)'
    }
  }, logged && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "check",
    size: 18,
    color: "var(--set-logged-mark)"
  })));
}
Object.assign(__ds_scope, { SetRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fitness/SetRow.jsx", error: String((e && e.message) || e) }); }

// components/fitness/StatCard.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function StatCard({
  label,
  value,
  unit,
  delta,
  deltaTone = 'accent',
  icon,
  footnote,
  style,
  ...rest
}) {
  const tone = deltaTone === 'accent' ? 'var(--feedback-success)' : deltaTone === 'danger' ? 'var(--feedback-danger)' : 'var(--text-tertiary)';
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 6,
      padding: 'var(--card-pad)',
      background: 'var(--surface-card)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-lg)',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--text-secondary)',
      fontWeight: 'var(--fw-semibold)'
    }
  }, label), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 16,
    color: "var(--action-primary)"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 5
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "num",
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 'var(--type-metric-size)',
      lineHeight: 'var(--type-metric-lh)',
      fontWeight: 'var(--fw-bold)',
      letterSpacing: '-.02em'
    }
  }, value), unit && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--text-tertiary)',
      fontWeight: 'var(--fw-bold)'
    }
  }, unit)), (delta || footnote) && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6,
      fontSize: 12
    }
  }, delta && /*#__PURE__*/React.createElement("span", {
    style: {
      color: tone,
      fontWeight: 'var(--fw-extrabold)'
    }
  }, delta), footnote && /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-tertiary)'
    }
  }, footnote)));
}
Object.assign(__ds_scope, { StatCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fitness/StatCard.jsx", error: String((e && e.message) || e) }); }

// components/fitness/SyncBadge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* The six sync states from DESIGN-BRIEF §6.2. Each carries an icon AND a word;
   `queued` is deliberately neutral — it is the normal state in a gym basement. */
const SYNC_STATES = {
  draft_local: {
    label: 'Saved on device',
    icon: 'smartphone',
    fg: 'var(--sync-draft-fg)',
    bg: 'var(--sync-draft-bg)'
  },
  queued: {
    label: 'Waiting for connection',
    icon: 'clock',
    fg: 'var(--sync-queued-fg)',
    bg: 'var(--sync-queued-bg)'
  },
  syncing: {
    label: 'Syncing',
    icon: 'refresh-cw',
    fg: 'var(--sync-syncing-fg)',
    bg: 'var(--sync-syncing-bg)'
  },
  saved: {
    label: 'Saved',
    icon: 'check',
    fg: 'var(--sync-saved-fg)',
    bg: 'var(--sync-saved-bg)'
  },
  failed: {
    label: 'Will retry',
    icon: 'rotate-ccw',
    fg: 'var(--sync-failed-fg)',
    bg: 'var(--sync-failed-bg)'
  },
  conflict: {
    label: 'Needs your decision',
    icon: 'git-merge',
    fg: 'var(--sync-conflict-fg)',
    bg: 'var(--sync-conflict-bg)'
  }
};
function SyncBadge({
  state = 'saved',
  label,
  compact,
  style,
  ...rest
}) {
  const s = SYNC_STATES[state] || SYNC_STATES.saved;
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      height: compact ? 24 : 28,
      padding: compact ? '0 8px' : '0 10px',
      background: s.bg,
      color: s.fg,
      borderRadius: 'var(--radius-pill)',
      fontFamily: 'var(--font-ui)',
      fontSize: compact ? 11 : 12,
      fontWeight: 'var(--fw-bold)',
      whiteSpace: 'nowrap',
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: s.icon,
    size: compact ? 12 : 14,
    style: state === 'syncing' ? {
      animation: 'lifeos-spin 1.2s linear infinite'
    } : undefined
  }), label || s.label);
}
Object.assign(__ds_scope, { SYNC_STATES, SyncBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fitness/SyncBadge.jsx", error: String((e && e.message) || e) }); }

// components/fitness/TrendChart.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function TrendChart({
  data = [],
  height = 150,
  yTicks = [],
  xLabels = [],
  style,
  ...rest
}) {
  const max = Math.max(...data, 1),
    min = Math.min(...data, 0);
  const span = max - min || 1;
  const pts = data.map((v, i) => [i / Math.max(1, data.length - 1) * 100, 100 - (v - min) / span * 88 - 6]);
  const line = pts.map((p, i) => `${i ? 'L' : 'M'}${p[0].toFixed(2)},${p[1].toFixed(2)}`).join(' ');
  const area = `${line} L100,100 L0,100 Z`;
  const id = React.useId ? React.useId().replace(/:/g, '') : 'tc';
  return /*#__PURE__*/React.createElement("figure", _extends({
    style: {
      margin: 0,
      display: 'flex',
      gap: 10,
      ...style
    }
  }, rest), yTicks.length > 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'space-between',
      height,
      fontSize: 11,
      color: 'var(--chart-axis-text)',
      fontFamily: 'var(--font-numeric)'
    }
  }, yTicks.map(t => /*#__PURE__*/React.createElement("span", {
    key: t
  }, t))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("svg", {
    viewBox: "0 0 100 100",
    preserveAspectRatio: "none",
    style: {
      width: '100%',
      height,
      display: 'block'
    }
  }, /*#__PURE__*/React.createElement("defs", null, /*#__PURE__*/React.createElement("linearGradient", {
    id: 'g' + id,
    x1: "0",
    y1: "0",
    x2: "0",
    y2: "1"
  }, /*#__PURE__*/React.createElement("stop", {
    offset: "0%",
    stopColor: "var(--action-primary)",
    stopOpacity: "0.28"
  }), /*#__PURE__*/React.createElement("stop", {
    offset: "100%",
    stopColor: "var(--action-primary)",
    stopOpacity: "0"
  }))), [25, 50, 75].map(y => /*#__PURE__*/React.createElement("line", {
    key: y,
    x1: "0",
    y1: y,
    x2: "100",
    y2: y,
    stroke: "var(--chart-grid)",
    strokeWidth: "0.4",
    vectorEffect: "non-scaling-stroke"
  })), /*#__PURE__*/React.createElement("path", {
    d: area,
    fill: 'url(#g' + id + ')'
  }), /*#__PURE__*/React.createElement("path", {
    d: line,
    fill: "none",
    stroke: "var(--chart-line)",
    strokeWidth: "2",
    vectorEffect: "non-scaling-stroke",
    strokeLinejoin: "round",
    strokeLinecap: "round"
  }), pts.map((p, i) => /*#__PURE__*/React.createElement("circle", {
    key: i,
    cx: p[0],
    cy: p[1],
    r: "1.1",
    fill: "var(--chart-line)",
    vectorEffect: "non-scaling-stroke"
  }))), xLabels.length > 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      marginTop: 8,
      fontSize: 11,
      color: 'var(--chart-axis-text)'
    }
  }, xLabels.map(l => /*#__PURE__*/React.createElement("span", {
    key: l
  }, l)))));
}
Object.assign(__ds_scope, { TrendChart });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fitness/TrendChart.jsx", error: String((e && e.message) || e) }); }

// components/fitness/VolumeBars.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function VolumeBars({
  data = [],
  height = 120,
  labels = [],
  highlightLast,
  style,
  ...rest
}) {
  const max = Math.max(...data, 1);
  return /*#__PURE__*/React.createElement("figure", _extends({
    style: {
      margin: 0,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      gap: 3,
      height
    }
  }, data.map((v, i) => /*#__PURE__*/React.createElement("span", {
    key: i,
    title: String(v),
    style: {
      flex: 1,
      height: `${Math.max(4, v / max * 100)}%`,
      borderRadius: 3,
      background: highlightLast && i === data.length - 1 ? 'var(--action-primary)' : v / max > 0.75 ? 'var(--chart-bar)' : 'var(--chart-bar-muted)'
    }
  }))), labels.length > 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      marginTop: 8,
      fontSize: 11,
      color: 'var(--chart-axis-text)'
    }
  }, labels.map((l, i) => /*#__PURE__*/React.createElement("span", {
    key: i
  }, l))));
}
Object.assign(__ds_scope, { VolumeBars });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fitness/VolumeBars.jsx", error: String((e && e.message) || e) }); }

// components/fitness/WeekDots.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function WeekDots({
  days = [],
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: 'flex',
      gap: 8,
      justifyContent: 'space-between',
      ...style
    }
  }, rest), days.map((d, i) => {
    const done = d.done;
    return /*#__PURE__*/React.createElement("span", {
      key: i,
      style: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: 6
      }
    }, /*#__PURE__*/React.createElement("span", {
      "aria-label": `${d.label}: ${done ? 'trained' : 'no session'}`,
      style: {
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        width: 30,
        height: 30,
        borderRadius: 'var(--radius-pill)',
        background: done ? 'var(--feedback-success-quiet)' : 'transparent',
        border: `1.5px solid ${done ? 'var(--action-primary)' : 'var(--border-default)'}`,
        color: 'var(--action-primary)'
      }
    }, done && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "check",
      size: 15
    })), /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 11,
        color: 'var(--text-tertiary)',
        fontWeight: 'var(--fw-bold)'
      }
    }, d.label));
  }));
}
Object.assign(__ds_scope, { WeekDots });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/fitness/WeekDots.jsx", error: String((e && e.message) || e) }); }

// components/navigation/BottomNav.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const NAV_ITEMS = [{
  key: 'home',
  label: 'Home',
  icon: 'house'
}, {
  key: 'workout',
  label: 'Workout',
  icon: 'dumbbell'
}, {
  key: 'exercises',
  label: 'Exercises',
  icon: 'list'
}, {
  key: 'progress',
  label: 'Progress',
  icon: 'chart-column'
}];
function BottomNav({
  items = NAV_ITEMS,
  active = 'home',
  onSelect,
  onAdd,
  addLabel = 'Start workout',
  style,
  ...rest
}) {
  const left = items.slice(0, 2),
    right = items.slice(2);
  const tab = it => {
    const on = it.key === active;
    return /*#__PURE__*/React.createElement("button", {
      key: it.key,
      "aria-current": on ? 'page' : undefined,
      onClick: () => onSelect && onSelect(it.key),
      style: {
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 4,
        minHeight: 'var(--hit-min)',
        padding: '6px 0',
        background: 'transparent',
        border: 'none',
        cursor: 'pointer',
        color: on ? 'var(--action-primary)' : 'var(--text-tertiary)'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: it.icon,
      size: 22
    }), /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 10,
        fontWeight: on ? 'var(--fw-extrabold)' : 'var(--fw-semibold)',
        letterSpacing: '.01em'
      }
    }, it.label));
  };
  return /*#__PURE__*/React.createElement("nav", _extends({
    style: {
      position: 'relative',
      display: 'flex',
      alignItems: 'center',
      height: 'var(--nav-h)',
      paddingBottom: 'var(--safe-bottom)',
      background: 'var(--surface-nav)',
      backdropFilter: 'var(--blur-nav)',
      WebkitBackdropFilter: 'var(--blur-nav)',
      borderTop: '1px solid var(--border-subtle)',
      ...style
    }
  }, rest), left.map(tab), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 72,
      flex: '0 0 auto'
    }
  }), right.map(tab), /*#__PURE__*/React.createElement("button", {
    "aria-label": addLabel,
    onClick: onAdd,
    style: {
      position: 'absolute',
      left: '50%',
      top: -4,
      transform: 'translateX(-50%)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: 'var(--fab-size)',
      height: 'var(--fab-size)',
      background: 'var(--action-primary)',
      color: 'var(--action-primary-text)',
      border: 'none',
      borderRadius: 'var(--radius-pill)',
      cursor: 'pointer',
      boxShadow: 'var(--shadow-fab)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "plus",
    size: 26
  })));
}
Object.assign(__ds_scope, { NAV_ITEMS, BottomNav });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/BottomNav.jsx", error: String((e && e.message) || e) }); }

// components/navigation/ScreenHeader.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function ScreenHeader({
  title,
  subtitle,
  onBack,
  left,
  right,
  sticky,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("header", _extends({
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      minHeight: 'var(--header-h)',
      padding: '0 var(--gutter-mobile)',
      paddingTop: 'var(--safe-top)',
      position: sticky ? 'sticky' : undefined,
      top: sticky ? 0 : undefined,
      zIndex: sticky ? 5 : undefined,
      background: sticky ? 'var(--surface-nav)' : 'transparent',
      backdropFilter: sticky ? 'var(--blur-nav)' : undefined,
      ...style
    }
  }, rest), onBack && /*#__PURE__*/React.createElement("button", {
    "aria-label": "Back",
    onClick: onBack,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: 'var(--hit-min)',
      height: 'var(--hit-min)',
      marginLeft: -12,
      background: 'transparent',
      border: 'none',
      color: 'var(--text-primary)',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-left",
    size: 24
  })), left, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0,
      textAlign: onBack ? 'center' : 'left'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontFamily: 'var(--font-display)',
      fontSize: 'var(--type-heading-size)',
      fontWeight: 'var(--fw-bold)',
      color: 'var(--text-primary)',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, title), subtitle && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, subtitle)), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 4,
      minWidth: onBack ? 'var(--hit-min)' : 0,
      justifyContent: 'flex-end'
    }
  }, right));
}
Object.assign(__ds_scope, { ScreenHeader });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/ScreenHeader.jsx", error: String((e && e.message) || e) }); }

// screens/auth/Auth.jsx
try { (() => {
const {
  Button: ABtn,
  Input: AInput,
  Icon: AIcon,
  Card: ACard,
  ScreenHeader: AHeader,
  Badge: ABadge
} = window.LifeOSStrengthDesignSystem_576cfb;
function AuthShell({
  title,
  lead,
  children,
  back,
  hero = 'hero-dumbbell.png',
  tight
}) {
  return /*#__PURE__*/React.createElement(Screen, null, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      height: tight ? 190 : 250,
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: '../../assets/imagery/' + hero,
    alt: "",
    style: {
      width: '100%',
      height: '100%',
      objectFit: 'cover',
      objectPosition: '62% 26%'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--scrim-strong)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0
    }
  }, /*#__PURE__*/React.createElement(Bar, {
    onPhoto: true
  })), back && /*#__PURE__*/React.createElement("button", {
    "aria-label": "Back",
    style: {
      position: 'absolute',
      top: 52,
      left: 10,
      width: 44,
      height: 44,
      background: 'transparent',
      border: 'none',
      color: '#fff',
      cursor: 'pointer'
    }
  }, /*#__PURE__*/React.createElement(AIcon, {
    name: "chevron-left",
    size: 24
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 20,
      right: 20,
      bottom: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 26,
      fontWeight: 800,
      letterSpacing: '-.03em',
      color: '#fff'
    }
  }, title), lead && /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 6,
      fontSize: 13,
      lineHeight: '18px',
      color: 'var(--ink-200)',
      maxWidth: 300
    }
  }, lead))), /*#__PURE__*/React.createElement(Scroll, {
    style: {
      paddingTop: 22
    }
  }, children));
}
function SignUp({
  invalid,
  taken,
  success
}) {
  if (success) return /*#__PURE__*/React.createElement(AuthShell, {
    tight: true,
    title: "Check your email",
    lead: "We sent a confirmation link to marek@example.com. Open it to finish creating your account.",
    hero: "hero-back-rack.png"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement(ACard, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 12,
      alignItems: 'flex-start'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 36,
      height: 36,
      flex: '0 0 auto',
      borderRadius: 999,
      background: 'var(--feedback-success-quiet)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(AIcon, {
    name: "mail-check",
    size: 18,
    color: "var(--feedback-success)"
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      fontWeight: 800
    }
  }, "Link sent"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 3,
      lineHeight: '17px'
    }
  }, "It expires in 60 minutes. Nothing else is needed on this device.")))), /*#__PURE__*/React.createElement(ABtn, {
    variant: "secondary",
    block: true
  }, "Resend link"), /*#__PURE__*/React.createElement(ABtn, {
    variant: "ghost",
    block: true
  }, "Use a different email")));
  return /*#__PURE__*/React.createElement(AuthShell, {
    back: true,
    title: "Create your account",
    lead: "Email and password only. Your workouts stay on this device until you are online.",
    hero: "hero-back-rack.png"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement(AInput, {
    label: "Email",
    icon: "mail",
    defaultValue: taken ? 'marek@example.com' : invalid ? 'marek@example' : 'marek@example.com',
    error: taken ? 'That email already has an account' : invalid ? 'Enter a valid email address' : undefined
  }), /*#__PURE__*/React.createElement(AInput, {
    label: "Password",
    icon: "lock",
    type: "password",
    defaultValue: invalid ? '123' : 'trening123',
    hint: invalid ? undefined : 'At least 8 characters',
    error: invalid ? 'Use at least 8 characters' : undefined
  }), taken && /*#__PURE__*/React.createElement(ABtn, {
    variant: "secondary",
    block: true,
    iconLeft: "log-in"
  }, "Sign in instead"), /*#__PURE__*/React.createElement(ABtn, {
    variant: "primary",
    size: "lg",
    block: true,
    uppercase: true,
    disabled: invalid
  }, "Create account"), /*#__PURE__*/React.createElement("p", {
    style: {
      margin: '6px 0 0',
      fontSize: 11,
      lineHeight: '16px',
      color: 'var(--text-tertiary)',
      textAlign: 'center'
    }
  }, "By creating an account you accept the terms and the privacy notice. You can export or delete everything at any time."), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      fontSize: 13,
      color: 'var(--text-tertiary)',
      marginTop: 6
    }
  }, "Already have an account? ", /*#__PURE__*/React.createElement("a", {
    href: "#",
    onClick: e => e.preventDefault()
  }, "Sign in"))));
}
function Reset({
  stage = 'request'
}) {
  if (stage === 'sent') return /*#__PURE__*/React.createElement(AuthShell, {
    tight: true,
    back: true,
    title: "Check your email",
    lead: "If an account exists for marek@example.com, a reset link is on its way.",
    hero: "hero-core-front.png"
  }, /*#__PURE__*/React.createElement(ACard, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 12,
      alignItems: 'flex-start'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 36,
      height: 36,
      flex: '0 0 auto',
      borderRadius: 999,
      background: 'var(--surface-inset)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(AIcon, {
    name: "clock",
    size: 18,
    color: "var(--text-secondary)"
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      fontWeight: 800
    }
  }, "The link expires in 60 minutes"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 3,
      lineHeight: '17px'
    }
  }, "We do not say whether an account exists \u2014 that would leak who is registered.")))), /*#__PURE__*/React.createElement(ABtn, {
    variant: "secondary",
    block: true,
    style: {
      marginTop: 14
    }
  }, "Resend link"), /*#__PURE__*/React.createElement(ABtn, {
    variant: "ghost",
    block: true,
    style: {
      marginTop: 8
    }
  }, "Back to sign in"));
  if (stage === 'new') return /*#__PURE__*/React.createElement(AuthShell, {
    tight: true,
    title: "Set a new password",
    lead: "You are signed out on every other device once this is saved.",
    hero: "hero-core-front.png"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement(AInput, {
    label: "New password",
    icon: "lock",
    type: "password",
    defaultValue: "treningmocny",
    hint: "At least 8 characters"
  }), /*#__PURE__*/React.createElement(AInput, {
    label: "Repeat password",
    icon: "lock",
    type: "password",
    defaultValue: "treningmocny"
  }), /*#__PURE__*/React.createElement(ABtn, {
    variant: "primary",
    size: "lg",
    block: true,
    uppercase: true
  }, "Save password")));
  if (stage === 'expired') return /*#__PURE__*/React.createElement(AuthShell, {
    tight: true,
    title: "This link has expired",
    lead: "Reset links last 60 minutes. Request a new one and it will work straight away.",
    hero: "hero-core-front.png"
  }, /*#__PURE__*/React.createElement(ACard, {
    tone: "default"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 12,
      alignItems: 'flex-start'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 36,
      height: 36,
      flex: '0 0 auto',
      borderRadius: 999,
      background: 'var(--feedback-warning-quiet)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(AIcon, {
    name: "link-2-off",
    size: 18,
    color: "var(--feedback-warning)"
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      fontWeight: 800
    }
  }, "Nothing was changed"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 3,
      lineHeight: '17px'
    }
  }, "Your current password still works and your workouts are untouched.")))), /*#__PURE__*/React.createElement(ABtn, {
    variant: "primary",
    size: "lg",
    block: true,
    uppercase: true,
    style: {
      marginTop: 14
    }
  }, "Request a new link"), /*#__PURE__*/React.createElement(ABtn, {
    variant: "ghost",
    block: true,
    style: {
      marginTop: 8
    }
  }, "Back to sign in"));
  return /*#__PURE__*/React.createElement(AuthShell, {
    back: true,
    tight: true,
    title: "Reset your password",
    lead: "Enter the email you signed up with and we'll send a link.",
    hero: "hero-core-front.png"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement(AInput, {
    label: "Email",
    icon: "mail",
    defaultValue: "marek@example.com"
  }), /*#__PURE__*/React.createElement(ABtn, {
    variant: "primary",
    size: "lg",
    block: true,
    uppercase: true
  }, "Send reset link"), /*#__PURE__*/React.createElement(ABtn, {
    variant: "ghost",
    block: true
  }, "Back to sign in")));
}
Object.assign(window, {
  SignUp,
  Reset,
  AuthShell
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "screens/auth/Auth.jsx", error: String((e && e.message) || e) }); }

// screens/catalog/ExerciseDetail.jsx
try { (() => {
const {
  Card: XCard,
  Button: XBtn,
  IconButton: XIconBtn,
  Icon: XIcon,
  Chip: XChip,
  Input: XInput,
  Select: XSelect,
  Badge: XBadge,
  PRBadge: XPR,
  ScreenHeader: XHeader,
  ExerciseRow: XRow,
  ConfirmDialog: XConfirm,
  TrendChart: XTrend,
  EmptyState: XEmpty
} = window.LifeOSStrengthDesignSystem_576cfb;
function Meta({
  items
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 8
    }
  }, items.map(([k, v]) => /*#__PURE__*/React.createElement("div", {
    key: k,
    style: {
      padding: '10px 12px',
      background: 'var(--surface-card)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-md)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 10,
      letterSpacing: '.06em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, k), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      fontWeight: 800,
      marginTop: 3
    }
  }, v))));
}
function ExerciseDetail({
  minimal,
  custom
}) {
  return /*#__PURE__*/React.createElement(Screen, null, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(XHeader, {
    title: custom ? 'Farmer Carry' : 'Bench Press',
    onBack: () => {},
    right: custom ? /*#__PURE__*/React.createElement(XIconBtn, {
      icon: "pencil",
      label: "Edit exercise"
    }) : /*#__PURE__*/React.createElement(XIconBtn, {
      icon: "star",
      label: "Add to favourites"
    })
  }), /*#__PURE__*/React.createElement(Scroll, {
    style: {
      paddingTop: 6
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      marginBottom: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 56,
      height: 56,
      borderRadius: 'var(--radius-lg)',
      background: 'var(--surface-inset)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(XIcon, {
    name: "dumbbell",
    size: 26,
    color: "var(--text-secondary)"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      flexWrap: 'wrap'
    }
  }, /*#__PURE__*/React.createElement(XBadge, {
    tone: "neutral",
    size: "sm"
  }, custom ? 'Dumbbell' : 'Barbell'), /*#__PURE__*/React.createElement(XBadge, {
    tone: "neutral",
    size: "sm"
  }, custom ? 'Carry' : 'Chest'), custom && /*#__PURE__*/React.createElement(XBadge, {
    tone: "accent",
    size: "sm"
  }, "Custom")), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 6
    }
  }, "Tracks: ", custom ? 'distance · duration' : 'weight · reps'))), /*#__PURE__*/React.createElement(Meta, {
    items: custom ? [['Equipment', 'Dumbbell'], ['Pattern', 'Carry'], ['Difficulty', 'Intermediate'], ['Created', 'Jun 2, 2024']] : [['Equipment', 'Barbell'], ['Pattern', 'Push horizontal'], ['Difficulty', 'Intermediate'], ['Compound', 'Yes']]
  }), !minimal && !custom && /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Eyebrow, null, "Your progress"), /*#__PURE__*/React.createElement(XCard, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 28,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, "102.5"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "kg"), /*#__PURE__*/React.createElement(XBadge, {
    tone: "accent",
    style: {
      marginLeft: 6
    }
  }, "+12.5 kg")), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, "Estimated 1RM \xB7 24 sessions logged"), /*#__PURE__*/React.createElement(XTrend, {
    style: {
      marginTop: 14
    },
    height: 110,
    data: [62, 68, 66, 74, 80, 86, 90, 88, 94, 96, 100, 102.5],
    xLabels: ['Apr 12', 'Jun 7']
  })), /*#__PURE__*/React.createElement(XBtn, {
    variant: "secondary",
    block: true,
    iconLeft: "history",
    style: {
      marginTop: 8
    }
  }, "See all 24 sessions"), /*#__PURE__*/React.createElement(Eyebrow, null, "Last time"), /*#__PURE__*/React.createElement(XCard, {
    pad: "tight"
  }, [['1', '100 kg × 8', 'RPE 8'], ['2', '100 kg × 6', 'RPE 8.5'], ['3', '105 kg × 4', 'RPE 9']].map(([n, v, r]) => /*#__PURE__*/React.createElement("div", {
    key: n,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      minHeight: 40,
      padding: '0 8px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 26,
      textAlign: 'center',
      fontFamily: 'var(--font-numeric)',
      fontSize: 13,
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, n), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 15,
      fontWeight: 700
    }
  }, v), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, r))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '8px',
      fontSize: 11,
      color: 'var(--text-tertiary)'
    }
  }, "Jun 7, 2024 \xB7 5 days ago"))), minimal && /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Eyebrow, null, "Your progress"), /*#__PURE__*/React.createElement(XEmpty, {
    icon: "chart-column",
    title: "No sessions yet",
    description: "Log this exercise once and its trend, records and last-session recall appear here."
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '12px 14px',
      background: 'var(--surface-card)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-md)',
      fontSize: 12,
      lineHeight: '17px',
      color: 'var(--text-tertiary)'
    }
  }, /*#__PURE__*/React.createElement(XIcon, {
    name: "info",
    size: 14,
    style: {
      marginRight: 6,
      verticalAlign: '-2px'
    }
  }), "No form tips are available for this exercise. Written guidance exists for 50 key movements only.")), custom && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8,
      marginTop: 20
    }
  }, /*#__PURE__*/React.createElement(XBtn, {
    variant: "secondary",
    block: true,
    iconLeft: "pencil"
  }, "Edit exercise"), /*#__PURE__*/React.createElement(XBtn, {
    variant: "ghost",
    block: true,
    iconLeft: "trash-2",
    style: {
      color: 'var(--feedback-danger)'
    }
  }, "Delete exercise")), /*#__PURE__*/React.createElement(XBtn, {
    variant: "primary",
    size: "lg",
    shape: "pill",
    block: true,
    uppercase: true,
    style: {
      marginTop: 20
    }
  }, "Add to workout")));
}
function CustomEditor({
  mode = 'create',
  invalid,
  confirming
}) {
  return /*#__PURE__*/React.createElement(Screen, null, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(XHeader, {
    title: mode === 'create' ? 'New exercise' : 'Edit exercise',
    onBack: () => {},
    right: /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 13,
        fontWeight: 800,
        color: invalid ? 'var(--text-tertiary)' : 'var(--text-accent)',
        padding: '0 6px'
      }
    }, "Save")
  }), /*#__PURE__*/React.createElement(Scroll, {
    style: {
      paddingTop: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement(XInput, {
    label: "Name",
    placeholder: "e.g. Farmer Carry",
    defaultValue: invalid ? '' : mode === 'create' ? 'Farmer Carry' : 'Farmer Carry',
    error: invalid ? 'A name is required' : undefined
  }), /*#__PURE__*/React.createElement(XSelect, {
    label: "Equipment",
    value: "Dumbbell",
    options: ['Barbell', 'Dumbbell', 'Machine', 'Cable', 'Bodyweight', 'Kettlebell', 'Band']
  }), /*#__PURE__*/React.createElement(XSelect, {
    label: "Movement pattern",
    value: "Carry",
    options: ['Push horizontal', 'Push vertical', 'Pull horizontal', 'Pull vertical', 'Squat', 'Hinge', 'Lunge', 'Carry', 'Rotation', 'Isolation']
  }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      fontWeight: 700,
      color: 'var(--text-secondary)',
      marginBottom: 8
    }
  }, "What this exercise tracks"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      flexWrap: 'wrap'
    }
  }, /*#__PURE__*/React.createElement(XChip, null, "Weight"), /*#__PURE__*/React.createElement(XChip, null, "Reps"), /*#__PURE__*/React.createElement(XChip, {
    selected: true
  }, "Distance"), /*#__PURE__*/React.createElement(XChip, {
    selected: true
  }, "Duration")), invalid && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6,
      marginTop: 8,
      fontSize: 12,
      color: 'var(--feedback-danger)'
    }
  }, /*#__PURE__*/React.createElement(XIcon, {
    name: "circle-alert",
    size: 13
  }), " Pick at least one value to track"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 11,
      color: 'var(--text-tertiary)',
      marginTop: 8,
      lineHeight: '16px'
    }
  }, "This decides the set editor layout: distance and duration replace the weight and reps columns.")), /*#__PURE__*/React.createElement(XSelect, {
    label: "Difficulty",
    value: "Intermediate",
    options: ['Beginner', 'Intermediate', 'Advanced']
  }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      fontWeight: 700,
      color: 'var(--text-secondary)',
      marginBottom: 6
    }
  }, "Default rest"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(XChip, null, "0:60"), /*#__PURE__*/React.createElement(XChip, {
    selected: true
  }, "1:30"), /*#__PURE__*/React.createElement(XChip, null, "2:00"), /*#__PURE__*/React.createElement(XChip, null, "3:00")))), mode === 'edit' && /*#__PURE__*/React.createElement(XBtn, {
    variant: "ghost",
    block: true,
    iconLeft: "trash-2",
    style: {
      color: 'var(--feedback-danger)',
      marginTop: 24
    }
  }, "Delete exercise"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 20,
      padding: '12px 14px',
      background: 'var(--surface-card)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 'var(--radius-md)',
      fontSize: 11,
      lineHeight: '16px',
      color: 'var(--text-tertiary)'
    }
  }, "Custom exercises are yours only. They stay on this device until the next sync.")), confirming && /*#__PURE__*/React.createElement(Overlay, null, /*#__PURE__*/React.createElement(XConfirm, {
    title: "Delete Farmer Carry?",
    description: "This exercise appears in 6 logged workouts.",
    recovery: "Those workouts keep their sets, but the exercise disappears from the catalog and its progress chart. This cannot be undone.",
    confirmLabel: "Delete exercise"
  })));
}
Object.assign(window, {
  ExerciseDetail,
  CustomEditor
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "screens/catalog/ExerciseDetail.jsx", error: String((e && e.message) || e) }); }

// screens/desktop/DesktopScreens.jsx
try { (() => {
const D = window.LifeOSStrengthDesignSystem_576cfb;
const {
  Card: GCard,
  Button: GBtn,
  IconButton: GIconBtn,
  Icon: GIcon,
  Chip: GChip,
  Input: GInput,
  Select: GSelect,
  Badge: GBadge,
  PRBadge: GPR,
  SyncBadge: GSync,
  ExerciseRow: GRow,
  SetRow: GSetRow,
  ConfirmDialog: GConfirm,
  TrendChart: GTrend,
  VolumeBars: GBars,
  SegmentedControl: GSeg,
  EmptyState: GEmpty
} = D;
const NAV = [['home', 'Home', 'house'], ['workout', 'Workout', 'dumbbell'], ['exercises', 'Exercises', 'list'], ['history', 'History', 'history'], ['progress', 'Progress', 'chart-column']];
function Shell({
  active,
  children
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      height: '100%'
    }
  }, /*#__PURE__*/React.createElement("aside", {
    style: {
      width: 248,
      flex: '0 0 auto',
      padding: '24px 16px',
      borderRight: '1px solid var(--border-subtle)',
      display: 'flex',
      flexDirection: 'column',
      gap: 24,
      background: 'var(--surface-sunken)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 24,
      fontWeight: 800,
      letterSpacing: '-.03em',
      padding: '0 8px'
    }
  }, "LifeOS", /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--action-primary)'
    }
  }, ".")), /*#__PURE__*/React.createElement("nav", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 2
    }
  }, NAV.map(([k, label, icon]) => {
    const on = k === active;
    return /*#__PURE__*/React.createElement("div", {
      key: k,
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 12,
        minHeight: 44,
        padding: '0 12px',
        background: on ? 'var(--set-active-bg)' : 'transparent',
        border: '1px solid ' + (on ? 'var(--border-accent)' : 'transparent'),
        borderRadius: 'var(--radius-md)',
        color: on ? 'var(--text-accent)' : 'var(--text-secondary)',
        fontSize: 14,
        fontWeight: on ? 800 : 600
      }
    }, /*#__PURE__*/React.createElement(GIcon, {
      name: icon,
      size: 19
    }), label);
  })), /*#__PURE__*/React.createElement(GBtn, {
    variant: "primary",
    block: true,
    iconLeft: "plus"
  }, "Start workout"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'auto',
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(GSync, {
    state: "saved"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      minHeight: 44,
      padding: '0 8px',
      color: 'var(--text-secondary)',
      fontSize: 13,
      fontWeight: 700
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 32,
      height: 32,
      borderRadius: 999,
      background: 'var(--surface-raised)',
      border: '1px solid var(--border-default)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(GIcon, {
    name: "user",
    size: 16,
    color: "var(--text-tertiary)"
  })), "Mariusz", /*#__PURE__*/React.createElement(GIcon, {
    name: "settings",
    size: 16,
    style: {
      marginLeft: 'auto'
    }
  })))), /*#__PURE__*/React.createElement("main", {
    style: {
      flex: 1,
      minWidth: 0,
      padding: '28px 32px',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      maxWidth: 1160,
      margin: '0 auto',
      height: '100%'
    }
  }, children)));
}
const H1 = ({
  children
}) => /*#__PURE__*/React.createElement("h1", {
  style: {
    fontFamily: 'var(--font-display)',
    fontSize: 46,
    lineHeight: '50px',
    fontWeight: 700,
    letterSpacing: '-.02em',
    margin: 0
  }
}, children);
const Lbl = ({
  children
}) => /*#__PURE__*/React.createElement("div", {
  style: {
    fontSize: 11,
    letterSpacing: '.08em',
    textTransform: 'uppercase',
    color: 'var(--text-tertiary)',
    fontWeight: 700
  }
}, children);

/* History: master list left, selected workout right */
function HistoryDesktop({
  confirming
}) {
  const rows = [['Push Day', 'Today', '45:12 · 18 sets · 12,450 kg', 'queued', true], ['Pull Day', 'May 10, 2024', '48:04 · 14 sets · 10,980 kg', 'saved', false], ['Legs', 'May 8, 2024', '52:20 · 16 sets · 18,300 kg', 'saved', true], ['Push Day', 'May 6, 2024', '45:40 · 18 sets · 11,900 kg', 'saved', false], ['Pull Day', 'May 3, 2024', '44:12 · 14 sets · 10,240 kg', 'saved', false]];
  const sets = [{
    w: 60,
    r: 10,
    rpe: '—',
    warmup: true
  }, {
    w: 100,
    r: 8,
    rpe: 8
  }, {
    w: 100,
    r: 6,
    rpe: 8.5
  }, {
    w: 105,
    r: 4,
    rpe: 9
  }];
  return /*#__PURE__*/React.createElement(Shell, {
    active: "history"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      justifyContent: 'space-between',
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement(H1, null, "History"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 10,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(GInput, {
    icon: "search",
    placeholder: "Search workouts",
    style: {
      width: 260
    }
  }), /*#__PURE__*/React.createElement(GSelect, {
    value: "Bench Press",
    options: ['All exercises', 'Bench Press', 'Back Squat', 'Deadlift'],
    style: {
      width: 190
    }
  }), /*#__PURE__*/React.createElement(GSelect, {
    value: "Last 3 months",
    options: ['Last 30 days', 'Last 3 months', 'This year'],
    style: {
      width: 180
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '440px 1fr',
      gap: 20,
      alignItems: 'start'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 10
    }
  }, /*#__PURE__*/React.createElement(Lbl, null, "3 workouts contain Bench Press"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      fontWeight: 800,
      color: 'var(--text-accent)'
    }
  }, "Clear filters")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, rows.map(([n, d, m, s, pr], i) => /*#__PURE__*/React.createElement(GCard, {
    key: i,
    pad: "tight",
    tone: i === 0 ? 'accent' : 'default',
    interactive: true
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 44,
      height: 44,
      flex: '0 0 auto',
      borderRadius: 'var(--radius-md)',
      background: 'var(--surface-inset)',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-numeric)',
      fontSize: 15,
      fontWeight: 700,
      lineHeight: 1
    }
  }, d === 'Today' ? '12' : d.split(' ')[1].replace(',', '')), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 9,
      letterSpacing: '.06em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700,
      marginTop: 2
    }
  }, d === 'Today' ? 'Aug' : d.split(' ')[0])), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 15,
      fontWeight: 800
    }
  }, n), pr && /*#__PURE__*/React.createElement(GPR, null)), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 3
    }
  }, m)), /*#__PURE__*/React.createElement(GSync, {
    state: s,
    compact: true,
    label: s === 'saved' ? 'Saved' : 'Queued'
  })))))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(GCard, {
    pad: "loose"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 26,
      fontWeight: 700
    }
  }, "Push Day"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--text-tertiary)',
      marginTop: 3
    }
  }, "Today \xB7 09:41 \u2013 10:26")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(GSync, {
    state: "queued"
  }), /*#__PURE__*/React.createElement(GBtn, {
    variant: "secondary",
    size: "sm",
    iconLeft: "pencil"
  }, "Edit"), /*#__PURE__*/React.createElement(GBtn, {
    variant: "ghost",
    size: "sm",
    iconLeft: "trash-2",
    style: {
      color: 'var(--feedback-danger)'
    }
  }, "Delete"))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 32,
      marginTop: 20
    }
  }, [['45:12', 'Duration'], ['18', 'Working sets'], ['12,450', 'Volume kg'], ['1', 'New records']].map(([v, l]) => /*#__PURE__*/React.createElement("div", {
    key: l
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 26,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, v), /*#__PURE__*/React.createElement(Lbl, null, l))))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(GCard, {
    pad: "tight"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      padding: '2px 6px 10px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 15,
      fontWeight: 800
    }
  }, "Bench Press"), /*#__PURE__*/React.createElement(GPR, {
    detail: "+2.5 kg"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      padding: '0 10px 6px 4px',
      fontSize: 10,
      letterSpacing: '.08em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 34,
      textAlign: 'center'
    }
  }, "Set"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Kg"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Reps"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "RPE"), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 32
    }
  })), sets.map((s, i) => /*#__PURE__*/React.createElement(GSetRow, {
    key: i,
    index: sets.slice(0, i + 1).filter(x => !x.warmup).length,
    weight: s.w,
    reps: s.r,
    rir: s.rpe,
    warmup: s.warmup,
    state: "logged"
  }))), /*#__PURE__*/React.createElement(GCard, {
    pad: "tight"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      padding: '2px 6px 10px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 15,
      fontWeight: 800
    }
  }, "Incline Dumbbell Press"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, "2 sets")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      padding: '0 10px 6px 4px',
      fontSize: 10,
      letterSpacing: '.08em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 34,
      textAlign: 'center'
    }
  }, "Set"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Kg"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Reps"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "RPE"), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 32
    }
  })), /*#__PURE__*/React.createElement(GSetRow, {
    index: 1,
    weight: 24,
    reps: 10,
    rir: 8,
    state: "logged"
  }), /*#__PURE__*/React.createElement(GSetRow, {
    index: 2,
    weight: 26,
    reps: 8,
    rir: 8.5,
    state: "logged"
  }))), /*#__PURE__*/React.createElement(GCard, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 12
    }
  }, /*#__PURE__*/React.createElement(Lbl, null, "Bench Press \xB7 estimated 1RM over time"), /*#__PURE__*/React.createElement(GBadge, {
    tone: "accent"
  }, "+12.5 kg")), /*#__PURE__*/React.createElement(GTrend, {
    height: 120,
    data: [62, 68, 66, 74, 80, 86, 90, 88, 94, 96, 100, 102.5],
    yTicks: [120, 100, 80, 60],
    xLabels: ['Apr 12', 'May 10', 'Jun 7']
  })))), confirming && /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'rgba(4,6,10,.72)',
      backdropFilter: 'var(--blur-overlay)'
    }
  }, /*#__PURE__*/React.createElement(GConfirm, {
    title: "Delete this workout?",
    description: "18 sets and 12,450 kg of volume from Push Day will be removed.",
    recovery: "The Bench Press record set here is recalculated from your remaining history. This cannot be undone.",
    confirmLabel: "Delete workout"
  })));
}

/* Catalog: list left, detail right + custom editor variant */
function CatalogDesktop({
  editor,
  invalid
}) {
  const rows = [['Bench Press', 'Barbell · Chest'], ['Incline Dumbbell Press', 'Dumbbell · Chest'], ['Overhead Press', 'Barbell · Shoulders'], ['Barbell Row', 'Barbell · Back'], ['Pull-up', 'Bodyweight · Back'], ['Back Squat', 'Barbell · Legs'], ['Romanian Deadlift', 'Barbell · Legs'], ['Farmer Carry', 'Dumbbell · Carry']];
  return /*#__PURE__*/React.createElement(Shell, {
    active: "exercises"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      justifyContent: 'space-between',
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement(H1, null, "Exercises"), /*#__PURE__*/React.createElement(GBtn, {
    variant: "secondary",
    iconLeft: "plus"
  }, "New custom exercise")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '400px 1fr',
      gap: 20,
      alignItems: 'start'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(GInput, {
    icon: "search",
    placeholder: "Search 214 exercises"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      margin: '12px 0'
    }
  }, ['All', 'Barbell', 'Dumbbell', 'Custom'].map((c, i) => /*#__PURE__*/React.createElement(GChip, {
    key: c,
    selected: i === 0
  }, c))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, rows.map(([n, m], i) => /*#__PURE__*/React.createElement(GCard, {
    key: n,
    pad: "tight",
    tone: (editor ? n === 'Farmer Carry' : i === 0) ? 'accent' : 'default',
    interactive: true
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 36,
      height: 36,
      borderRadius: 'var(--radius-md)',
      background: 'var(--surface-inset)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(GIcon, {
    name: "dumbbell",
    size: 17,
    color: "var(--text-secondary)"
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 14,
      fontWeight: 800
    }
  }, n), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 2
    }
  }, m)), n === 'Farmer Carry' && /*#__PURE__*/React.createElement(GBadge, {
    tone: "neutral",
    size: "sm"
  }, "Custom")))))), editor ? /*#__PURE__*/React.createElement(GCard, {
    pad: "loose"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 26,
      fontWeight: 700
    }
  }, "Edit custom exercise"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(GBtn, {
    variant: "ghost",
    size: "sm"
  }, "Cancel"), /*#__PURE__*/React.createElement(GBtn, {
    variant: "primary",
    size: "sm",
    disabled: invalid
  }, "Save"))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(GInput, {
    label: "Name",
    defaultValue: invalid ? '' : 'Farmer Carry',
    error: invalid ? 'A name is required' : undefined
  }), /*#__PURE__*/React.createElement(GSelect, {
    label: "Equipment",
    value: "Dumbbell",
    options: ['Barbell', 'Dumbbell', 'Machine', 'Cable', 'Bodyweight']
  }), /*#__PURE__*/React.createElement(GSelect, {
    label: "Movement pattern",
    value: "Carry",
    options: ['Push horizontal', 'Pull horizontal', 'Squat', 'Hinge', 'Carry', 'Isolation']
  }), /*#__PURE__*/React.createElement(GSelect, {
    label: "Difficulty",
    value: "Intermediate",
    options: ['Beginner', 'Intermediate', 'Advanced']
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 20
    }
  }, /*#__PURE__*/React.createElement(Lbl, null, "What this exercise tracks"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 10
    }
  }, /*#__PURE__*/React.createElement(GChip, null, "Weight"), /*#__PURE__*/React.createElement(GChip, null, "Reps"), /*#__PURE__*/React.createElement(GChip, {
    selected: true
  }, "Distance"), /*#__PURE__*/React.createElement(GChip, {
    selected: true
  }, "Duration")), invalid && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6,
      marginTop: 10,
      fontSize: 12,
      color: 'var(--feedback-danger)'
    }
  }, /*#__PURE__*/React.createElement(GIcon, {
    name: "circle-alert",
    size: 13
  }), " Pick at least one value to track"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 10
    }
  }, "This decides the set editor layout: distance and duration replace the weight and reps columns.")), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 20
    }
  }, /*#__PURE__*/React.createElement(Lbl, null, "Default rest"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 10
    }
  }, /*#__PURE__*/React.createElement(GChip, null, "0:60"), /*#__PURE__*/React.createElement(GChip, {
    selected: true
  }, "1:30"), /*#__PURE__*/React.createElement(GChip, null, "2:00"), /*#__PURE__*/React.createElement(GChip, null, "3:00"))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 28,
      paddingTop: 20,
      borderTop: '1px solid var(--border-subtle)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      maxWidth: 420,
      lineHeight: '17px'
    }
  }, "Deleting keeps the sets inside logged workouts, but removes the exercise from the catalog and its progress chart."), /*#__PURE__*/React.createElement(GBtn, {
    variant: "ghost",
    size: "sm",
    iconLeft: "trash-2",
    style: {
      color: 'var(--feedback-danger)'
    }
  }, "Delete exercise"))) : /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(GCard, {
    pad: "loose"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 16,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 64,
      height: 64,
      borderRadius: 'var(--radius-lg)',
      background: 'var(--surface-inset)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(GIcon, {
    name: "dumbbell",
    size: 30,
    color: "var(--text-secondary)"
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 30,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, "Bench Press"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      marginTop: 8
    }
  }, /*#__PURE__*/React.createElement(GBadge, {
    tone: "neutral",
    size: "sm"
  }, "Barbell"), /*#__PURE__*/React.createElement(GBadge, {
    tone: "neutral",
    size: "sm"
  }, "Chest"), /*#__PURE__*/React.createElement(GBadge, {
    tone: "neutral",
    size: "sm"
  }, "Push horizontal"), /*#__PURE__*/React.createElement(GBadge, {
    tone: "neutral",
    size: "sm"
  }, "Compound")))), /*#__PURE__*/React.createElement(GBtn, {
    variant: "primary",
    iconLeft: "plus"
  }, "Add to workout"))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1.4fr 1fr',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(GCard, {
    pad: "loose"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(Lbl, null, "Estimated 1RM"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 8,
      marginTop: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 44,
      lineHeight: '44px',
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, "102.5"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 15,
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "kg"), /*#__PURE__*/React.createElement(GBadge, {
    tone: "accent"
  }, "+12.5 kg"))), /*#__PURE__*/React.createElement(GPR, {
    label: "Record",
    detail: "105 kg \xD7 4, Jun 7"
  })), /*#__PURE__*/React.createElement(GTrend, {
    style: {
      marginTop: 20
    },
    height: 170,
    data: [62, 68, 66, 74, 80, 86, 90, 88, 94, 96, 100, 102.5],
    yTicks: [120, 100, 80, 60],
    xLabels: ['Apr 12', 'Apr 26', 'May 10', 'May 24', 'Jun 7']
  })), /*#__PURE__*/React.createElement(GCard, {
    pad: "loose"
  }, /*#__PURE__*/React.createElement(Lbl, null, "Last time \xB7 Jun 7, 5 days ago"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 12
    }
  }, [['1', '100 kg × 8', 'RPE 8'], ['2', '100 kg × 6', 'RPE 8.5'], ['3', '105 kg × 4', 'RPE 9']].map(([n, v, r]) => /*#__PURE__*/React.createElement("div", {
    key: n,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      minHeight: 40,
      borderBottom: '1px solid var(--border-subtle)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 22,
      fontFamily: 'var(--font-numeric)',
      fontSize: 13,
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, n), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 15,
      fontWeight: 700
    }
  }, v), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, r)))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 16
    }
  }, /*#__PURE__*/React.createElement(Lbl, null, "Sessions logged"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-numeric)',
      fontSize: 22,
      fontWeight: 700,
      marginTop: 4
    }
  }, "24")))))));
}

/* Selector as a centred modal over the workout */
function SelectorDesktop({
  noresults
}) {
  return /*#__PURE__*/React.createElement(Shell, {
    active: "workout"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      opacity: .35,
      pointerEvents: 'none'
    }
  }, /*#__PURE__*/React.createElement(H1, null, "Push Day"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 20,
      display: 'grid',
      gridTemplateColumns: '1fr 372px',
      gap: 24
    }
  }, /*#__PURE__*/React.createElement(GCard, {
    pad: "default"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 18,
      fontWeight: 800,
      marginBottom: 10
    }
  }, "Bench Press"), /*#__PURE__*/React.createElement(GSetRow, {
    index: 1,
    weight: 100,
    reps: 8,
    rir: 8,
    state: "logged"
  }), /*#__PURE__*/React.createElement(GSetRow, {
    index: 2,
    weight: 105,
    reps: 4,
    rir: 9,
    state: "active"
  })), /*#__PURE__*/React.createElement(GCard, {
    pad: "loose"
  }, /*#__PURE__*/React.createElement(Lbl, null, "Current set")))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'rgba(4,6,10,.72)',
      backdropFilter: 'var(--blur-overlay)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 720,
      maxHeight: 640,
      display: 'flex',
      flexDirection: 'column',
      background: 'var(--surface-card)',
      border: '1px solid var(--border-default)',
      borderRadius: 'var(--radius-xl)',
      boxShadow: 'var(--shadow-float)',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '20px 24px 16px',
      borderBottom: '1px solid var(--border-subtle)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 22,
      fontWeight: 700
    }
  }, "Add exercise"), /*#__PURE__*/React.createElement(GIconBtn, {
    icon: "x",
    label: "Close"
  })), /*#__PURE__*/React.createElement(GInput, {
    icon: "search",
    placeholder: "Search 214 exercises",
    defaultValue: noresults ? 'benhc press' : ''
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 12
    }
  }, ['All', 'Barbell', 'Dumbbell', 'Bodyweight', 'Custom'].map((c, i) => /*#__PURE__*/React.createElement(GChip, {
    key: c,
    selected: i === 0
  }, c)))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: '16px 24px 24px'
    }
  }, noresults ? /*#__PURE__*/React.createElement(GEmpty, {
    icon: "search-x",
    title: "No exercises found",
    description: 'Nothing matches "benhc press". Check the spelling, or create it as a custom exercise.',
    action: /*#__PURE__*/React.createElement(GBtn, {
      variant: "secondary",
      iconLeft: "plus"
    }, "Create \"benhc press\"")
  }) : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Lbl, null, "Recent"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 8,
      margin: '10px 0 18px'
    }
  }, [['Bench Press', 'last: 100 kg × 8'], ['Incline Dumbbell Press', 'last: 26 kg × 8'], ['Overhead Press', 'last: 55 kg × 6'], ['Barbell Row', 'last: 90 kg × 8']].map(([n, m]) => /*#__PURE__*/React.createElement(GRow, {
    key: n,
    name: n,
    meta: m,
    right: /*#__PURE__*/React.createElement(GIcon, {
      name: "plus",
      size: 19,
      color: "var(--action-primary)"
    })
  }))), /*#__PURE__*/React.createElement(Lbl, null, "Most used"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 8,
      marginTop: 10
    }
  }, [['Back Squat', '42 sessions'], ['Deadlift', '31 sessions'], ['Pull-up', '28 sessions'], ['Farmer Carry', '12 sessions']].map(([n, m]) => /*#__PURE__*/React.createElement(GRow, {
    key: n,
    name: n,
    meta: m,
    right: /*#__PURE__*/React.createElement(GIcon, {
      name: "plus",
      size: 19,
      color: "var(--action-primary)"
    })
  }))))))));
}

/* Auth on desktop: split hero / form */
function AuthDesktop({
  stage = 'signup'
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      height: '100%'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '1 1 58%',
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/imagery/hero-dumbbell.png",
    alt: "",
    style: {
      width: '100%',
      height: '100%',
      objectFit: 'cover',
      objectPosition: '58% 24%'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--scrim-side)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 56,
      bottom: 56,
      maxWidth: 420
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 40,
      fontWeight: 800,
      letterSpacing: '-.03em',
      color: '#fff'
    }
  }, "LifeOS", /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--action-primary)'
    }
  }, ".")), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 12,
      fontSize: 16,
      lineHeight: '23px',
      color: 'var(--ink-200)'
    }
  }, "A fast, trustworthy ledger for the gym. Your sets save on the device first, then to the server."))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: '0 0 480px',
      padding: '56px 56px',
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'center',
      background: 'var(--surface-base)',
      borderLeft: '1px solid var(--border-subtle)'
    }
  }, stage === 'signup' ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 30,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, "Create your account"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 8,
      fontSize: 14,
      color: 'var(--text-secondary)',
      lineHeight: '20px'
    }
  }, "Email and password only. Google and Apple sign-in arrive in v1.0.1."), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 16,
      marginTop: 28
    }
  }, /*#__PURE__*/React.createElement(GInput, {
    label: "Email",
    icon: "mail",
    defaultValue: "marek@example.com"
  }), /*#__PURE__*/React.createElement(GInput, {
    label: "Password",
    icon: "lock",
    type: "password",
    defaultValue: "trening123",
    hint: "At least 8 characters"
  }), /*#__PURE__*/React.createElement(GBtn, {
    variant: "primary",
    size: "lg",
    block: true,
    uppercase: true
  }, "Create account"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      lineHeight: '17px'
    }
  }, "You can export or delete everything at any time."), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--text-tertiary)'
    }
  }, "Already have an account? ", /*#__PURE__*/React.createElement("a", {
    href: "#",
    onClick: e => e.preventDefault()
  }, "Sign in")))) : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 30,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, "This link has expired"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 8,
      fontSize: 14,
      color: 'var(--text-secondary)',
      lineHeight: '20px'
    }
  }, "Reset links last 60 minutes. Request a new one and it will work straight away."), /*#__PURE__*/React.createElement(GCard, {
    style: {
      marginTop: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 12,
      alignItems: 'flex-start'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 36,
      height: 36,
      flex: '0 0 auto',
      borderRadius: 999,
      background: 'var(--feedback-warning-quiet)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(GIcon, {
    name: "link-2-off",
    size: 18,
    color: "var(--feedback-warning)"
  })), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      fontWeight: 800
    }
  }, "Nothing was changed"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 3,
      lineHeight: '17px'
    }
  }, "Your current password still works and your workouts are untouched.")))), /*#__PURE__*/React.createElement(GBtn, {
    variant: "primary",
    size: "lg",
    block: true,
    uppercase: true,
    style: {
      marginTop: 20
    }
  }, "Request a new link"), /*#__PURE__*/React.createElement(GBtn, {
    variant: "ghost",
    block: true,
    style: {
      marginTop: 8
    }
  }, "Back to sign in"))));
}
Object.assign(window, {
  HistoryDesktop,
  CatalogDesktop,
  SelectorDesktop,
  AuthDesktop,
  Shell
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "screens/desktop/DesktopScreens.jsx", error: String((e && e.message) || e) }); }

// screens/history/History.jsx
try { (() => {
const {
  Card: HsCard,
  Button: HsBtn,
  IconButton: HsIconBtn,
  Icon: HsIcon,
  Chip: HsChip,
  Input: HsInput,
  Select: HsSelect,
  Badge: HsBadge,
  PRBadge: HsPR,
  SyncBadge: HsSync,
  ScreenHeader: HsHeader,
  SetRow: HsSetRow,
  EmptyState: HsEmpty,
  ConfirmDialog: HsConfirm,
  TrendChart: HsTrend,
  VolumeBars: HsBars,
  ExerciseRow: HsRow,
  SegmentedControl: HsSeg
} = window.LifeOSStrengthDesignSystem_576cfb;
const SESSIONS = [{
  name: 'Push Day',
  date: 'Today',
  meta: '45:12 · 18 sets · 12,450 kg',
  sync: 'queued',
  pr: 1
}, {
  name: 'Pull Day',
  date: 'May 10, 2024',
  meta: '48:04 · 14 sets · 10,980 kg',
  sync: 'saved'
}, {
  name: 'Legs',
  date: 'May 8, 2024',
  meta: '52:20 · 16 sets · 18,300 kg',
  sync: 'saved',
  pr: 1
}, {
  name: 'Push Day',
  date: 'May 6, 2024',
  meta: '45:40 · 18 sets · 11,900 kg',
  sync: 'saved'
}, {
  name: 'Pull Day',
  date: 'May 3, 2024',
  meta: '44:12 · 14 sets · 10,240 kg',
  sync: 'saved'
}];
function SessionCard({
  s,
  onClick
}) {
  return /*#__PURE__*/React.createElement(HsCard, {
    pad: "tight",
    interactive: true,
    onClick: onClick,
    style: {
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 44,
      height: 44,
      flex: '0 0 auto',
      borderRadius: 'var(--radius-md)',
      background: 'var(--surface-inset)',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-numeric)',
      fontSize: 15,
      fontWeight: 700,
      lineHeight: 1
    }
  }, s.date === 'Today' ? '12' : s.date.split(' ')[1].replace(',', '')), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 9,
      letterSpacing: '.06em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700,
      marginTop: 2
    }
  }, s.date === 'Today' ? 'Aug' : s.date.split(' ')[0])), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 15,
      fontWeight: 800
    }
  }, s.name), s.pr && /*#__PURE__*/React.createElement(HsPR, null)), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 3
    }
  }, s.meta)), /*#__PURE__*/React.createElement(HsSync, {
    state: s.sync,
    compact: true,
    label: s.sync === 'saved' ? 'Saved' : 'Queued'
  })));
}
function HistoryList({
  filtered
}) {
  return /*#__PURE__*/React.createElement(Screen, null, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(HsHeader, {
    title: "History",
    right: /*#__PURE__*/React.createElement(HsIconBtn, {
      icon: "sliders-horizontal",
      label: "Filter"
    })
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px var(--gutter-mobile) 0',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement(HsInput, {
    icon: "search",
    placeholder: "Search workouts"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 12,
      overflowX: 'auto',
      paddingBottom: 4
    }
  }, /*#__PURE__*/React.createElement(HsChip, {
    selected: !filtered,
    icon: filtered ? undefined : 'check'
  }, "All"), /*#__PURE__*/React.createElement(HsChip, {
    selected: filtered,
    icon: filtered ? 'x' : undefined
  }, "Bench Press"), /*#__PURE__*/React.createElement(HsChip, null, "Last 30 days"), /*#__PURE__*/React.createElement(HsChip, null, "With records"))), /*#__PURE__*/React.createElement(Scroll, {
    style: {
      paddingTop: 14
    }
  }, filtered && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--text-secondary)'
    }
  }, "3 workouts contain ", /*#__PURE__*/React.createElement("strong", {
    style: {
      color: 'var(--text-primary)'
    }
  }, "Bench Press")), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      fontWeight: 800,
      color: 'var(--text-accent)'
    }
  }, "Clear")), (filtered ? SESSIONS.filter(s => s.name === 'Push Day') : SESSIONS).map((s, i) => /*#__PURE__*/React.createElement(SessionCard, {
    key: i,
    s: s
  })), !filtered && /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Eyebrow, null, "April"), [{
    name: 'Legs',
    date: 'Apr 29, 2024',
    meta: '50:10 · 16 sets · 17,600 kg',
    sync: 'saved'
  }, {
    name: 'Push Day',
    date: 'Apr 26, 2024',
    meta: '46:02 · 18 sets · 11,450 kg',
    sync: 'saved'
  }].map((s, i) => /*#__PURE__*/React.createElement(SessionCard, {
    key: i,
    s: s
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 8,
      padding: '14px 0',
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, /*#__PURE__*/React.createElement(HsIcon, {
    name: "loader",
    size: 14
  }), " Loading more\u2026"))));
}
function HistoryEmpty() {
  return /*#__PURE__*/React.createElement(Screen, null, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(HsHeader, {
    title: "History"
  }), /*#__PURE__*/React.createElement(Scroll, {
    style: {
      paddingTop: 60
    }
  }, /*#__PURE__*/React.createElement(HsEmpty, {
    icon: "history",
    title: "No workouts yet",
    description: "Finished sessions land here with volume, duration, records and where the data is stored.",
    action: /*#__PURE__*/React.createElement(HsBtn, {
      size: "lg",
      shape: "pill",
      uppercase: true
    }, "Start workout")
  })));
}
function WorkoutDetail({
  editing,
  confirming
}) {
  const sets = [{
    w: 60,
    r: 10,
    rpe: '—',
    warmup: true
  }, {
    w: 100,
    r: 8,
    rpe: 8
  }, {
    w: 100,
    r: 6,
    rpe: 8.5
  }, {
    w: 105,
    r: 4,
    rpe: 9,
    pr: true
  }];
  return /*#__PURE__*/React.createElement(Screen, null, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(HsHeader, {
    title: "Push Day",
    subtitle: "Today \xB7 09:41 \u2013 10:26",
    onBack: () => {},
    right: editing ? /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 13,
        fontWeight: 800,
        color: 'var(--text-accent)',
        padding: '0 6px'
      }
    }, "Save") : /*#__PURE__*/React.createElement(HsIconBtn, {
      icon: "ellipsis",
      label: "Workout options"
    })
  }), /*#__PURE__*/React.createElement(Scroll, {
    style: {
      paddingTop: 8
    }
  }, /*#__PURE__*/React.createElement(HsCard, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'flex-start'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 20
    }
  }, [['45:12', 'Duration'], ['18', 'Sets'], ['12,450', 'Volume kg']].map(([v, l]) => /*#__PURE__*/React.createElement("div", {
    key: l
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 22,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, v), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 10,
      letterSpacing: '.06em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700,
      marginTop: 3
    }
  }, l)))), /*#__PURE__*/React.createElement(HsSync, {
    state: "queued",
    compact: true,
    label: "Queued"
  }))), /*#__PURE__*/React.createElement(Eyebrow, null, "Exercises"), /*#__PURE__*/React.createElement(HsCard, {
    pad: "tight"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      padding: '2px 6px 10px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 15,
      fontWeight: 800
    }
  }, "Bench Press"), /*#__PURE__*/React.createElement(HsPR, {
    detail: "+2.5 kg"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      padding: '0 10px 6px 4px',
      fontSize: 10,
      letterSpacing: '.08em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 34,
      textAlign: 'center'
    }
  }, "Set"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Kg"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Reps"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "RPE"), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 32
    }
  })), sets.map((s, i) => /*#__PURE__*/React.createElement(HsSetRow, {
    key: i,
    index: sets.slice(0, i + 1).filter(x => !x.warmup).length,
    weight: editing && i === 3 ? /*#__PURE__*/React.createElement("span", {
      style: {
        color: 'var(--text-accent)',
        borderBottom: '2px solid var(--action-primary)'
      }
    }, "107.5") : s.w,
    reps: s.r,
    rir: s.rpe,
    warmup: s.warmup,
    state: "logged"
  })), editing && /*#__PURE__*/React.createElement("button", {
    style: {
      width: '100%',
      minHeight: 40,
      marginTop: 4,
      background: 'transparent',
      border: 'none',
      color: 'var(--text-accent)',
      fontSize: 13,
      fontWeight: 800,
      cursor: 'pointer'
    }
  }, "+ Add set")), /*#__PURE__*/React.createElement(HsCard, {
    pad: "tight",
    style: {
      marginTop: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      padding: '2px 6px 8px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 15,
      fontWeight: 800
    }
  }, "Incline Dumbbell Press"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, "2 sets")), /*#__PURE__*/React.createElement(HsSetRow, {
    index: 1,
    weight: 24,
    reps: 10,
    rir: 8,
    state: "logged"
  }), /*#__PURE__*/React.createElement(HsSetRow, {
    index: 2,
    weight: 26,
    reps: 8,
    rir: 8.5,
    state: "logged"
  })), !editing && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8,
      marginTop: 20
    }
  }, /*#__PURE__*/React.createElement(HsBtn, {
    variant: "secondary",
    block: true,
    iconLeft: "pencil"
  }, "Edit workout"), /*#__PURE__*/React.createElement(HsBtn, {
    variant: "ghost",
    block: true,
    iconLeft: "trash-2",
    style: {
      color: 'var(--feedback-danger)'
    }
  }, "Delete workout"))), confirming && /*#__PURE__*/React.createElement(Overlay, null, /*#__PURE__*/React.createElement(HsConfirm, {
    title: "Delete this workout?",
    description: "18 sets and 12,450 kg of volume from Push Day will be removed.",
    recovery: "The Bench Press record set here is recalculated from your remaining history. This cannot be undone.",
    confirmLabel: "Delete workout"
  })));
}
function ExerciseHistory() {
  const [range, setRange] = React.useState('Last 3 months');
  return /*#__PURE__*/React.createElement(Screen, null, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(HsHeader, {
    title: "Bench Press",
    subtitle: "History \xB7 24 sessions",
    onBack: () => {}
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px var(--gutter-mobile) 0',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement(HsSeg, {
    options: ['1RM', 'Volume', 'Top set'],
    value: "1RM",
    onChange: () => {}
  })), /*#__PURE__*/React.createElement(Scroll, {
    style: {
      paddingTop: 12
    }
  }, /*#__PURE__*/React.createElement(HsSelect, {
    value: range,
    options: ['Last 30 days', 'Last 3 months', 'This year', 'All time'],
    onChange: setRange
  }), /*#__PURE__*/React.createElement(HsCard, {
    style: {
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 28,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, "102.5"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "kg")), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, "Estimated 1RM \xB7 best 105 kg \xD7 4")), /*#__PURE__*/React.createElement(HsBadge, {
    tone: "accent"
  }, "+12.5 kg")), /*#__PURE__*/React.createElement(HsTrend, {
    style: {
      marginTop: 16
    },
    height: 150,
    data: [62, 68, 66, 74, 80, 86, 90, 88, 94, 96, 100, 102.5],
    yTicks: [120, 100, 80, 60],
    xLabels: ['Apr 12', 'May 10', 'Jun 7']
  }), /*#__PURE__*/React.createElement("details", {
    style: {
      marginTop: 10
    }
  }, /*#__PURE__*/React.createElement("summary", {
    style: {
      fontSize: 12,
      color: 'var(--text-accent)',
      fontWeight: 800,
      cursor: 'pointer'
    }
  }, "View as table"), /*#__PURE__*/React.createElement("table", {
    style: {
      width: '100%',
      marginTop: 8,
      borderCollapse: 'collapse',
      fontSize: 12,
      color: 'var(--text-secondary)'
    }
  }, /*#__PURE__*/React.createElement("thead", null, /*#__PURE__*/React.createElement("tr", null, /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'left',
      padding: '4px 0',
      color: 'var(--text-tertiary)'
    }
  }, "Date"), /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'right',
      color: 'var(--text-tertiary)'
    }
  }, "Top set"), /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'right',
      color: 'var(--text-tertiary)'
    }
  }, "Est. 1RM"))), /*#__PURE__*/React.createElement("tbody", null, [['Jun 7', '105 × 4', '102.5'], ['May 24', '102.5 × 5', '96'], ['May 10', '100 × 6', '90'], ['Apr 26', '90 × 5', '74']].map(r => /*#__PURE__*/React.createElement("tr", {
    key: r[0]
  }, /*#__PURE__*/React.createElement("td", {
    style: {
      padding: '4px 0'
    }
  }, r[0]), /*#__PURE__*/React.createElement("td", {
    style: {
      textAlign: 'right',
      fontFamily: 'var(--font-numeric)'
    }
  }, r[1]), /*#__PURE__*/React.createElement("td", {
    style: {
      textAlign: 'right',
      fontFamily: 'var(--font-numeric)'
    }
  }, r[2]))))))), /*#__PURE__*/React.createElement(Eyebrow, null, "Every session"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, [['Jun 7', '105 kg × 4', '102.5 kg', true], ['May 24', '102.5 kg × 5', '96.0 kg', false], ['May 10', '100 kg × 6', '90.0 kg', false], ['Apr 26', '90 kg × 5', '74.0 kg', false]].map(([d, top, orm, pr]) => /*#__PURE__*/React.createElement(HsRow, {
    key: d,
    thumb: "calendar",
    name: d,
    meta: `Top set ${top}`,
    badge: pr ? /*#__PURE__*/React.createElement(HsPR, null) : null,
    right: /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--font-numeric)',
        fontVariantNumeric: 'tabular-nums',
        fontSize: 15,
        fontWeight: 700
      }
    }, orm)
  })))));
}
Object.assign(window, {
  HistoryList,
  HistoryEmpty,
  WorkoutDetail,
  ExerciseHistory,
  SESSIONS,
  SessionCard
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "screens/history/History.jsx", error: String((e && e.message) || e) }); }

// screens/selector/Selector.jsx
try { (() => {
const {
  Card: SlCard,
  Button: SlBtn,
  IconButton: SlIconBtn,
  Icon: SlIcon,
  Chip: SlChip,
  Input: SlInput,
  Badge: SlBadge,
  ExerciseRow: SlRow,
  EmptyState: SlEmpty,
  ScreenHeader: SlHeader,
  SetRow: SlSetRow
} = window.LifeOSStrengthDesignSystem_576cfb;
const RECENT = [['Bench Press', 'Barbell · last: 100 kg × 8'], ['Incline Dumbbell Press', 'Dumbbell · last: 26 kg × 8'], ['Overhead Press', 'Barbell · last: 55 kg × 6']];
const FREQUENT = [['Back Squat', 'Barbell · 42 sessions'], ['Deadlift', 'Barbell · 31 sessions'], ['Pull-up', 'Bodyweight · 28 sessions'], ['Barbell Row', 'Barbell · 24 sessions']];
const RESULTS = [['Bench Press', 'Barbell · Chest'], ['Close-Grip Bench Press', 'Barbell · Chest'], ['Dumbbell Bench Press', 'Dumbbell · Chest'], ['Incline Bench Press', 'Barbell · Chest']];

/* The workout underneath, so the sheet reads in context */
function WorkoutBackdrop() {
  return /*#__PURE__*/React.createElement(Screen, null, /*#__PURE__*/React.createElement(Bar, null), /*#__PURE__*/React.createElement(SlHeader, {
    title: "Push Day",
    subtitle: "3 of 18 working sets",
    onBack: () => {}
  }), /*#__PURE__*/React.createElement(Scroll, {
    style: {
      paddingTop: 12,
      opacity: .5
    }
  }, /*#__PURE__*/React.createElement(SlCard, {
    pad: "tight"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px 6px 10px',
      fontSize: 16,
      fontWeight: 800
    }
  }, "Bench Press"), /*#__PURE__*/React.createElement(SlSetRow, {
    index: 1,
    weight: 100,
    reps: 8,
    rir: 8,
    state: "logged"
  }), /*#__PURE__*/React.createElement(SlSetRow, {
    index: 2,
    weight: 100,
    reps: 6,
    rir: 8.5,
    state: "logged"
  }), /*#__PURE__*/React.createElement(SlSetRow, {
    index: 3,
    weight: 105,
    reps: 4,
    rir: 9,
    state: "active"
  }))));
}
function SelectorSheet({
  mode = 'recent'
}) {
  const q = mode === 'search' || mode === 'noresults';
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(WorkoutBackdrop, null), /*#__PURE__*/React.createElement(Sheet, {
    height: "80%"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '8px var(--gutter-mobile) 12px',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      minHeight: 36
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 19,
      fontWeight: 700
    }
  }, "Add exercise"), /*#__PURE__*/React.createElement(SlIconBtn, {
    icon: "x",
    label: "Close"
  })), /*#__PURE__*/React.createElement(SlInput, {
    icon: "search",
    placeholder: "Search 214 exercises",
    defaultValue: mode === 'search' ? 'bench' : mode === 'noresults' ? 'benhc press' : '',
    style: {
      marginTop: 10
    }
  }), mode === 'filtered' ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 12,
      overflowX: 'auto',
      paddingBottom: 2
    }
  }, /*#__PURE__*/React.createElement(SlChip, null, "All"), /*#__PURE__*/React.createElement(SlChip, {
    selected: true,
    icon: "x"
  }, "Barbell"), /*#__PURE__*/React.createElement(SlChip, {
    selected: true,
    icon: "x"
  }, "Chest"), /*#__PURE__*/React.createElement(SlChip, null, "Bodyweight")) : /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 12,
      overflowX: 'auto',
      paddingBottom: 2
    }
  }, /*#__PURE__*/React.createElement(SlChip, {
    selected: true
  }, "All"), /*#__PURE__*/React.createElement(SlChip, null, "Barbell"), /*#__PURE__*/React.createElement(SlChip, null, "Dumbbell"), /*#__PURE__*/React.createElement(SlChip, null, "Bodyweight"), /*#__PURE__*/React.createElement(SlChip, null, "Custom"))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: '0 var(--gutter-mobile) 20px'
    }
  }, mode === 'noresults' ? /*#__PURE__*/React.createElement(SlEmpty, {
    icon: "search-x",
    title: "No exercises found",
    description: 'Nothing matches "benhc press". Check the spelling, or create it as a custom exercise.',
    action: /*#__PURE__*/React.createElement(SlBtn, {
      variant: "secondary",
      iconLeft: "plus"
    }, "Create \"benhc press\"")
  }) : mode === 'search' ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Eyebrow, null, "4 results"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, RESULTS.map(([n, m]) => /*#__PURE__*/React.createElement(SlRow, {
    key: n,
    name: n,
    meta: m,
    right: /*#__PURE__*/React.createElement(SlIcon, {
      name: "plus",
      size: 20,
      color: "var(--action-primary)"
    })
  })))) : mode === 'filtered' ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Eyebrow, null, "Barbell \xB7 Chest \xB7 6 exercises"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, [['Bench Press', 'Barbell · Chest'], ['Close-Grip Bench Press', 'Barbell · Chest'], ['Incline Bench Press', 'Barbell · Chest'], ['Decline Bench Press', 'Barbell · Chest'], ['Floor Press', 'Barbell · Chest'], ['Guillotine Press', 'Barbell · Chest']].map(([n, m]) => /*#__PURE__*/React.createElement(SlRow, {
    key: n,
    name: n,
    meta: m,
    right: /*#__PURE__*/React.createElement(SlIcon, {
      name: "plus",
      size: 20,
      color: "var(--action-primary)"
    })
  })))) : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(Eyebrow, null, "Recent"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, RECENT.map(([n, m]) => /*#__PURE__*/React.createElement(SlRow, {
    key: n,
    name: n,
    meta: m,
    right: /*#__PURE__*/React.createElement(SlIcon, {
      name: "plus",
      size: 20,
      color: "var(--action-primary)"
    })
  }))), /*#__PURE__*/React.createElement(Eyebrow, null, "Most used"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, FREQUENT.map(([n, m]) => /*#__PURE__*/React.createElement(SlRow, {
    key: n,
    name: n,
    meta: m,
    right: /*#__PURE__*/React.createElement(SlIcon, {
      name: "plus",
      size: 20,
      color: "var(--action-primary)"
    })
  }))), /*#__PURE__*/React.createElement(SlBtn, {
    variant: "secondary",
    block: true,
    iconLeft: "plus",
    style: {
      marginTop: 16
    }
  }, "Create custom exercise")))));
}
Object.assign(window, {
  SelectorSheet,
  WorkoutBackdrop
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "screens/selector/Selector.jsx", error: String((e && e.message) || e) }); }

// ui_kits/desktop/DashboardView.jsx
try { (() => {
const {
  Card: DCard,
  Button: DBtn,
  StatCard: DStat,
  WeekDots: DWeek,
  VolumeBars: DBars,
  SyncBadge: DSync,
  Icon: DIc,
  Banner: DBan,
  ExerciseRow: DRow,
  PRBadge: DPR
} = window.LifeOSStrengthDesignSystem_576cfb;
function DashboardView({
  onStart
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 20
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      justifyContent: 'space-between',
      gap: 24
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 46,
      lineHeight: '50px',
      fontWeight: 700,
      letterSpacing: '-.02em',
      margin: 0
    }
  }, "Good morning,", /*#__PURE__*/React.createElement("br", null), /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--action-primary)'
    }
  }, "Mariusz")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(DSync, {
    state: "queued"
  }), /*#__PURE__*/React.createElement(DBtn, {
    variant: "secondary",
    iconLeft: "plus"
  }, "Add exercise"))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1.5fr 1fr',
      gap: 20
    }
  }, /*#__PURE__*/React.createElement(DCard, {
    pad: "none",
    radius: "xl",
    style: {
      position: 'relative',
      overflow: 'hidden',
      minHeight: 260
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/imagery/hero-dumbbell.png",
    alt: "",
    style: {
      position: 'absolute',
      inset: 0,
      width: '100%',
      height: '100%',
      objectFit: 'cover',
      objectPosition: '62% 22%'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--scrim-side)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      padding: 28,
      maxWidth: 460
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "dlbl",
    style: {
      color: 'var(--action-primary)'
    }
  }, "Repeat last workout"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 34,
      lineHeight: '38px',
      fontWeight: 700,
      letterSpacing: '-.02em',
      marginTop: 8
    }
  }, "Push Day"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 8,
      fontSize: 14,
      color: 'var(--ink-200)'
    }
  }, "6 exercises \xB7 18 sets \xB7 ~45 min \xB7 last done 2 days ago"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      marginTop: 16,
      flexWrap: 'wrap'
    }
  }, ['Bench Press', 'Incline DB Press', 'Overhead Press', 'Lateral Raise', 'Triceps Pushdown', 'Dips'].map(n => /*#__PURE__*/React.createElement("span", {
    key: n,
    style: {
      fontSize: 12,
      fontWeight: 700,
      color: 'var(--text-secondary)',
      background: 'rgba(255,255,255,.06)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 999,
      padding: '5px 10px'
    }
  }, n))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 10,
      marginTop: 22
    }
  }, /*#__PURE__*/React.createElement(DBtn, {
    variant: "primary",
    size: "lg",
    shape: "pill",
    uppercase: true,
    onClick: onStart
  }, "Repeat workout"), /*#__PURE__*/React.createElement(DBtn, {
    variant: "secondary",
    size: "lg",
    onClick: onStart
  }, "Start empty")), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 14,
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, "Values pre-fill from that session. No template is created."))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(DStat, {
    label: "Volume",
    value: "12,450",
    unit: "kg",
    delta: "+8%",
    footnote: "vs last week",
    icon: "trending-up"
  }), /*#__PURE__*/React.createElement(DStat, {
    label: "Workouts",
    value: "4",
    footnote: "This week",
    icon: "calendar"
  })), /*#__PURE__*/React.createElement(DCard, {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 15,
      fontWeight: 800
    }
  }, "Weekly progress"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--text-accent)',
      fontWeight: 800
    }
  }, "4 of 5 workouts")), /*#__PURE__*/React.createElement(DWeek, {
    days: [{
      label: 'M',
      done: true
    }, {
      label: 'T',
      done: true
    }, {
      label: 'W',
      done: true
    }, {
      label: 'T',
      done: true
    }, {
      label: 'F'
    }, {
      label: 'S'
    }, {
      label: 'S'
    }]
  }), /*#__PURE__*/React.createElement(DBars, {
    style: {
      marginTop: 22
    },
    height: 80,
    data: [8, 12, 6, 14, 9, 17, 11, 15, 7, 13, 19, 10],
    labels: ['4 weeks ago', 'This week'],
    highlightLast: true
  })))), /*#__PURE__*/React.createElement(DBan, {
    icon: "cloud-off",
    title: "2 workouts waiting to sync",
    description: "They are stored on this device. We'll send them when you're back online.",
    onClick: () => {}
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 20
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "dlbl",
    style: {
      marginBottom: 10
    }
  }, "Recent activity"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, [['Pull Day', 'May 10, 2024 · 48 min · 14 sets', 'saved'], ['Legs', 'May 8, 2024 · 52 min · 16 sets', 'saved'], ['Push Day', 'May 6, 2024 · 45 min · 18 sets', 'queued']].map(([n, m, s]) => /*#__PURE__*/React.createElement(DRow, {
    key: n,
    name: n,
    meta: m,
    right: /*#__PURE__*/React.createElement(DSync, {
      state: s,
      compact: true
    })
  })))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "dlbl",
    style: {
      marginBottom: 10
    }
  }, "Personal records"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, [['Bench Press', '1RM · May 10, 2024', '102.5 kg', true], ['Back Squat', '1RM · May 8, 2024', '140.0 kg', false], ['Deadlift', '1RM · May 5, 2024', '160.0 kg', false]].map(([n, m, v, fresh]) => /*#__PURE__*/React.createElement(DRow, {
    key: n,
    name: n,
    meta: m,
    badge: fresh ? /*#__PURE__*/React.createElement(DPR, {
      label: "New"
    }) : null,
    right: /*#__PURE__*/React.createElement("span", {
      className: "num",
      style: {
        fontFamily: 'var(--font-numeric)',
        fontVariantNumeric: 'tabular-nums',
        fontSize: 17,
        fontWeight: 700
      }
    }, v)
  }))))));
}
window.DashboardView = DashboardView;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/desktop/DashboardView.jsx", error: String((e && e.message) || e) }); }

// ui_kits/desktop/DesktopShell.jsx
try { (() => {
const DDS = window.LifeOSStrengthDesignSystem_576cfb;
const {
  Icon: DIcon,
  Button: DButton,
  SyncBadge: DSyncBadge
} = DDS;
const NAV = [['home', 'Home', 'house'], ['workout', 'Workout', 'dumbbell'], ['exercises', 'Exercises', 'list'], ['history', 'History', 'history'], ['progress', 'Progress', 'chart-column']];
function DesktopShell({
  view,
  onNavigate,
  children
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      minHeight: 900,
      background: 'var(--surface-base)'
    }
  }, /*#__PURE__*/React.createElement("aside", {
    style: {
      width: 248,
      flex: '0 0 auto',
      padding: '24px 16px',
      borderRight: '1px solid var(--border-subtle)',
      display: 'flex',
      flexDirection: 'column',
      gap: 24,
      background: 'var(--surface-sunken)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 24,
      fontWeight: 800,
      letterSpacing: '-.03em',
      padding: '0 8px'
    }
  }, "LifeOS", /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--action-primary)'
    }
  }, ".")), /*#__PURE__*/React.createElement("nav", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 2
    }
  }, NAV.map(([k, label, icon]) => {
    const on = k === view;
    return /*#__PURE__*/React.createElement("button", {
      key: k,
      onClick: () => onNavigate(k),
      style: {
        display: 'flex',
        alignItems: 'center',
        gap: 12,
        minHeight: 44,
        padding: '0 12px',
        background: on ? 'var(--set-active-bg)' : 'transparent',
        border: `1px solid ${on ? 'var(--border-accent)' : 'transparent'}`,
        borderRadius: 'var(--radius-md)',
        color: on ? 'var(--text-accent)' : 'var(--text-secondary)',
        fontSize: 14,
        fontWeight: on ? 800 : 600,
        cursor: 'pointer',
        fontFamily: 'var(--font-ui)',
        textAlign: 'left'
      }
    }, /*#__PURE__*/React.createElement(DIcon, {
      name: icon,
      size: 19
    }), label);
  })), /*#__PURE__*/React.createElement(DButton, {
    variant: "primary",
    block: true,
    iconLeft: "plus",
    onClick: () => onNavigate('workout')
  }, "Start workout"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'auto',
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(DSyncBadge, {
    state: "saved"
  }), /*#__PURE__*/React.createElement("button", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      minHeight: 44,
      padding: '0 8px',
      background: 'transparent',
      border: 'none',
      cursor: 'pointer',
      color: 'var(--text-secondary)',
      fontFamily: 'var(--font-ui)',
      fontSize: 13,
      fontWeight: 700
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 32,
      height: 32,
      borderRadius: 999,
      background: 'var(--surface-raised)',
      border: '1px solid var(--border-default)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(DIcon, {
    name: "user",
    size: 16,
    color: "var(--text-tertiary)"
  })), "Mariusz", /*#__PURE__*/React.createElement(DIcon, {
    name: "settings",
    size: 16,
    style: {
      marginLeft: 'auto'
    }
  })))), /*#__PURE__*/React.createElement("main", {
    style: {
      flex: 1,
      minWidth: 0,
      padding: '28px 32px 40px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      maxWidth: 1160,
      margin: '0 auto'
    }
  }, children)));
}
function CatalogView() {
  const {
    Input,
    Chip,
    ExerciseRow,
    Badge
  } = DDS;
  const rows = [['Bench Press', 'Barbell · Chest', '100 kg × 8'], ['Incline Dumbbell Press', 'Dumbbell · Chest', '26 kg × 8'], ['Overhead Press', 'Barbell · Shoulders', '55 kg × 6'], ['Barbell Row', 'Barbell · Back', '90 kg × 8'], ['Back Squat', 'Barbell · Legs', '140 kg × 5'], ['Farmer Carry', 'Dumbbell · Carry', '40 kg · 40 m']];
  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 46,
      lineHeight: '50px',
      fontWeight: 700,
      letterSpacing: '-.02em',
      margin: '0 0 20px'
    }
  }, "Exercises"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 12,
      alignItems: 'center',
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement(Input, {
    icon: "search",
    placeholder: "Search 214 exercises",
    style: {
      width: 360
    }
  }), ['All', 'Barbell', 'Dumbbell', 'Bodyweight', 'Custom'].map((c, i) => /*#__PURE__*/React.createElement(Chip, {
    key: c,
    selected: i === 0
  }, c))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 1fr',
      gap: 10
    }
  }, rows.map(([n, m, l]) => /*#__PURE__*/React.createElement(ExerciseRow, {
    key: n,
    name: n,
    meta: m,
    right: /*#__PURE__*/React.createElement("span", {
      className: "num",
      style: {
        fontFamily: 'var(--font-numeric)',
        fontSize: 15,
        fontWeight: 700,
        color: 'var(--text-secondary)'
      }
    }, l)
  }))));
}
Object.assign(window, {
  DesktopShell,
  CatalogView
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/desktop/DesktopShell.jsx", error: String((e && e.message) || e) }); }

// ui_kits/desktop/ProgressView.jsx
try { (() => {
const {
  Card: PvCard,
  SegmentedControl: PvSeg,
  Select: PvSel,
  TrendChart: PvTrend,
  VolumeBars: PvBars,
  ExerciseRow: PvRow,
  Badge: PvBadge,
  PRBadge: PvPR
} = window.LifeOSStrengthDesignSystem_576cfb;
function ProgressView() {
  const [metric, setMetric] = React.useState('Strength');
  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      justifyContent: 'space-between',
      marginBottom: 24
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 46,
      lineHeight: '50px',
      fontWeight: 700,
      letterSpacing: '-.02em',
      margin: 0
    }
  }, "Progress"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 12,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(PvSeg, {
    options: ['Strength', 'Volume', '1RM', 'Body'],
    value: metric,
    onChange: setMetric
  }), /*#__PURE__*/React.createElement(PvSel, {
    value: "This month",
    options: ['This week', 'This month', 'Last 3 months'],
    style: {
      width: 190
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1.6fr 1fr',
      gap: 20
    }
  }, /*#__PURE__*/React.createElement(PvCard, {
    pad: "loose"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "dlbl"
  }, "Bench Press \xB7 estimated 1RM"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 8,
      marginTop: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "num",
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 44,
      lineHeight: '44px',
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, "102.5"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 16,
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "kg"), /*#__PURE__*/React.createElement(PvBadge, {
    tone: "accent"
  }, "+5.0 kg"))), /*#__PURE__*/React.createElement(PvPR, {
    label: "New record",
    detail: "May 10"
  })), /*#__PURE__*/React.createElement(PvTrend, {
    style: {
      marginTop: 24
    },
    height: 260,
    data: [62, 68, 66, 74, 80, 86, 90, 88, 94, 96, 100, 102.5],
    yTicks: [120, 100, 80, 60],
    xLabels: ['Apr 12', 'Apr 26', 'May 10', 'May 24', 'Jun 7']
  }), /*#__PURE__*/React.createElement("details", {
    style: {
      marginTop: 16
    }
  }, /*#__PURE__*/React.createElement("summary", {
    style: {
      fontSize: 13,
      color: 'var(--text-accent)',
      fontWeight: 800,
      cursor: 'pointer'
    }
  }, "View as table"), /*#__PURE__*/React.createElement("table", {
    style: {
      width: '100%',
      marginTop: 10,
      borderCollapse: 'collapse',
      fontSize: 13,
      color: 'var(--text-secondary)'
    }
  }, /*#__PURE__*/React.createElement("thead", null, /*#__PURE__*/React.createElement("tr", null, /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'left',
      padding: '6px 0',
      color: 'var(--text-tertiary)'
    }
  }, "Date"), /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'right',
      color: 'var(--text-tertiary)'
    }
  }, "Top set"), /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'right',
      color: 'var(--text-tertiary)'
    }
  }, "Est. 1RM"))), /*#__PURE__*/React.createElement("tbody", null, [['Apr 12', '80 kg × 5', '62 kg'], ['Apr 26', '90 kg × 5', '74 kg'], ['May 10', '100 kg × 6', '90 kg'], ['May 24', '102.5 kg × 5', '96 kg'], ['Jun 7', '105 kg × 4', '102.5 kg']].map(r => /*#__PURE__*/React.createElement("tr", {
    key: r[0]
  }, /*#__PURE__*/React.createElement("td", {
    style: {
      padding: '6px 0'
    }
  }, r[0]), /*#__PURE__*/React.createElement("td", {
    className: "num",
    style: {
      textAlign: 'right',
      fontFamily: 'var(--font-numeric)'
    }
  }, r[1]), /*#__PURE__*/React.createElement("td", {
    className: "num",
    style: {
      textAlign: 'right',
      fontFamily: 'var(--font-numeric)'
    }
  }, r[2]))))))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(PvCard, null, /*#__PURE__*/React.createElement("div", {
    className: "dlbl"
  }, "Weekly volume"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 6,
      marginTop: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "num",
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 28,
      fontWeight: 700
    }
  }, "18,750"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "kg"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--feedback-success)',
      fontWeight: 800,
      marginLeft: 6
    }
  }, "+12%")), /*#__PURE__*/React.createElement(PvBars, {
    style: {
      marginTop: 18
    },
    height: 120,
    data: [8, 12, 6, 14, 9, 17, 11, 15, 7, 13, 19, 10, 16, 12, 18, 9, 14, 11, 17, 20, 13, 15, 10, 19],
    labels: ['May 1', 'May 14', 'May 28'],
    highlightLast: true
  })), /*#__PURE__*/React.createElement(PvCard, null, /*#__PURE__*/React.createElement("div", {
    className: "dlbl",
    style: {
      marginBottom: 12
    }
  }, "Top lifts"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, [['Bench Press', '102.5 kg'], ['Back Squat', '140.0 kg'], ['Deadlift', '160.0 kg'], ['Overhead Press', '62.5 kg']].map(([n, v]) => /*#__PURE__*/React.createElement("div", {
    key: n,
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      padding: '6px 0',
      borderBottom: '1px solid var(--border-subtle)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      fontWeight: 700
    }
  }, n), /*#__PURE__*/React.createElement("span", {
    className: "num",
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 15,
      fontWeight: 700
    }
  }, v))))))));
}
window.ProgressView = ProgressView;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/desktop/ProgressView.jsx", error: String((e && e.message) || e) }); }

// ui_kits/desktop/WorkoutView.jsx
try { (() => {
const {
  Card: WvCard,
  Button: WvBtn,
  Icon: WvIc,
  SetRow: WvSetRow,
  RestTimer: WvTimer,
  Stepper: WvStepper,
  Chip: WvChip,
  SyncBadge: WvSync,
  IconButton: WvIconBtn,
  PRBadge: WvPR
} = window.LifeOSStrengthDesignSystem_576cfb;
const WDATA = [{
  name: 'Bench Press',
  equip: 'Barbell',
  last: '100 kg × 8, 5 days ago',
  sets: [{
    w: 60,
    r: 10,
    rpe: '—',
    warmup: true,
    state: 'logged'
  }, {
    w: 100,
    r: 8,
    rpe: 8,
    state: 'logged'
  }, {
    w: 100,
    r: 6,
    rpe: 8.5,
    state: 'logged'
  }, {
    w: 105,
    r: 4,
    rpe: 9,
    state: 'active'
  }, {
    w: 105,
    r: 4,
    rpe: 9,
    state: 'proposed'
  }]
}, {
  name: 'Incline Dumbbell Press',
  equip: 'Dumbbell',
  last: '24 kg × 10, 5 days ago',
  sets: [{
    w: 24,
    r: 10,
    rpe: 8,
    state: 'logged'
  }, {
    w: 26,
    r: 8,
    rpe: 8.5,
    state: 'proposed'
  }]
}, {
  name: 'Overhead Press',
  equip: 'Barbell',
  last: '55 kg × 6, 5 days ago',
  sets: [{
    w: 55,
    r: 6,
    rpe: 8,
    state: 'proposed'
  }, {
    w: 55,
    r: 6,
    rpe: 8.5,
    state: 'proposed'
  }]
}];
function WorkoutView() {
  const [data, setData] = React.useState(WDATA);
  const [weight, setWeight] = React.useState(105);
  const confirm = (ei, si) => setData(d => d.map((ex, i) => i !== ei ? ex : {
    ...ex,
    sets: ex.sets.map((s, j) => j === si ? {
      ...s,
      state: 'logged'
    } : j === si + 1 && s.state === 'proposed' ? {
      ...s,
      state: 'active'
    } : s)
  }));
  const logged = data.flatMap(e => e.sets).filter(s => s.state === 'logged' && !s.warmup).length;
  const total = data.flatMap(e => e.sets).filter(s => !s.warmup).length;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'grid',
      gridTemplateColumns: '1fr 372px',
      gap: 24,
      alignItems: 'start'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      justifyContent: 'space-between',
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    className: "dlbl"
  }, "Active workout \xB7 45:12"), /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 46,
      lineHeight: '50px',
      fontWeight: 700,
      letterSpacing: '-.02em',
      margin: '6px 0 0'
    }
  }, "Push Day")), /*#__PURE__*/React.createElement(WvSync, {
    state: "draft_local"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 4,
      background: 'var(--surface-raised)',
      borderRadius: 999,
      overflow: 'hidden',
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      height: '100%',
      width: `${logged / total * 100}%`,
      background: 'var(--action-primary)',
      transition: 'width var(--dur-base) var(--ease-standard)'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, data.map((ex, ei) => /*#__PURE__*/React.createElement(WvCard, {
    key: ex.name,
    pad: "default"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      gap: 12,
      marginBottom: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 28,
      height: 28,
      borderRadius: 999,
      background: 'var(--surface-inset)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontFamily: 'var(--font-numeric)',
      fontSize: 13,
      fontWeight: 700,
      color: 'var(--text-secondary)'
    }
  }, ei + 1), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 18,
      fontWeight: 800
    }
  }, ex.name), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 13,
      color: 'var(--text-tertiary)',
      marginTop: 2
    }
  }, ex.equip, " \xB7 last time: ", ex.last)), /*#__PURE__*/React.createElement(WvIconBtn, {
    icon: "ellipsis",
    label: "Exercise options",
    size: 36,
    iconSize: 18
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      padding: '0 10px 6px 4px',
      fontSize: 10,
      letterSpacing: '.08em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 34,
      textAlign: 'center'
    }
  }, "Set"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Kg"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Reps"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "RPE"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Rest"), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 32
    }
  })), ex.sets.map((s, si) => /*#__PURE__*/React.createElement(WvSetRow, {
    key: si,
    index: ex.sets.slice(0, si + 1).filter(x => !x.warmup).length,
    weight: s.w,
    reps: s.r,
    rir: s.rpe,
    rest: s.state === 'logged' ? '2:00' : '—',
    warmup: s.warmup,
    state: s.state,
    onConfirm: () => confirm(ei, si)
  })), /*#__PURE__*/React.createElement("button", {
    style: {
      minHeight: 40,
      marginTop: 4,
      background: 'transparent',
      border: 'none',
      color: 'var(--text-accent)',
      fontSize: 13,
      fontWeight: 800,
      cursor: 'pointer',
      fontFamily: 'var(--font-ui)'
    }
  }, "+ Add set"))), /*#__PURE__*/React.createElement(WvBtn, {
    variant: "secondary",
    block: true,
    iconLeft: "plus"
  }, "Add exercise"))), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'sticky',
      top: 28,
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(WvCard, {
    pad: "loose"
  }, /*#__PURE__*/React.createElement("div", {
    className: "dlbl"
  }, "Current set \xB7 Bench Press"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 14
    }
  }, /*#__PURE__*/React.createElement(WvStepper, {
    size: "lg",
    value: weight,
    step: 2.5,
    unit: "kg",
    onChange: setWeight
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 10
    }
  }, [weight - 2.5, weight + 2.5, weight + 5].map(v => /*#__PURE__*/React.createElement(WvChip, {
    key: v,
    onClick: () => setWeight(v)
  }, v, " kg"))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 14
    }
  }, /*#__PURE__*/React.createElement(WvStepper, {
    value: 4,
    step: 1,
    unit: "reps"
  })), /*#__PURE__*/React.createElement(WvBtn, {
    variant: "primary",
    size: "lg",
    shape: "pill",
    block: true,
    uppercase: true,
    style: {
      marginTop: 16
    }
  }, "Complete set"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 10,
      fontSize: 12,
      color: 'var(--set-proposed-text)',
      textAlign: 'center'
    }
  }, "Pre-filled from 5 days ago \u2014 confirm or adjust.")), /*#__PURE__*/React.createElement(WvTimer, {
    remaining: "1:45",
    running: true,
    nextLabel: "Next exercise",
    nextValue: "Incline DB Press"
  }), /*#__PURE__*/React.createElement(WvCard, null, /*#__PURE__*/React.createElement("div", {
    className: "dlbl",
    style: {
      marginBottom: 12
    }
  }, "Session"), [['Working sets', `${logged} / ${total}`], ['Volume', '8,240 kg'], ['Duration', '45:12'], ['New records', '1']].map(([k, v]) => /*#__PURE__*/React.createElement("div", {
    key: k,
    style: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      padding: '7px 0',
      borderBottom: '1px solid var(--border-subtle)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--text-secondary)'
    }
  }, k), /*#__PURE__*/React.createElement("span", {
    className: "num",
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 15,
      fontWeight: 700
    }
  }, v))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement(WvPR, {
    label: "PR",
    detail: "Bench Press +2.5 kg"
  }))), /*#__PURE__*/React.createElement(WvBtn, {
    variant: "secondary",
    size: "lg",
    block: true
  }, "Complete workout")));
}
window.WorkoutView = WorkoutView;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/desktop/WorkoutView.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile-app/ExercisesScreen.jsx
try { (() => {
const {
  Input: EInput,
  Chip: EChip,
  ExerciseRow: EExerciseRow,
  Badge: EBadge,
  ScreenHeader: EHeader,
  IconButton: EIconButton,
  EmptyState: EEmptyState
} = window.LifeOSStrengthDesignSystem_576cfb;
const CATALOG = [{
  name: 'Bench Press',
  equip: 'Barbell',
  group: 'Chest',
  last: '100 kg × 8'
}, {
  name: 'Incline Dumbbell Press',
  equip: 'Dumbbell',
  group: 'Chest',
  last: '26 kg × 8'
}, {
  name: 'Overhead Press',
  equip: 'Barbell',
  group: 'Shoulders',
  last: '55 kg × 6'
}, {
  name: 'Barbell Row',
  equip: 'Barbell',
  group: 'Back',
  last: '90 kg × 8'
}, {
  name: 'Pull-up',
  equip: 'Bodyweight',
  group: 'Back',
  last: 'BW × 10'
}, {
  name: 'Back Squat',
  equip: 'Barbell',
  group: 'Legs',
  last: '140 kg × 5'
}, {
  name: 'Romanian Deadlift',
  equip: 'Barbell',
  group: 'Legs',
  last: '120 kg × 8'
}, {
  name: 'Farmer Carry',
  equip: 'Dumbbell',
  group: 'Carry',
  last: '40 kg · 40 m',
  custom: true
}, {
  name: 'Plank',
  equip: 'Bodyweight',
  group: 'Core',
  last: '1:30'
}];
function ExercisesScreen() {
  const [q, setQ] = React.useState('');
  const [filter, setFilter] = React.useState('All');
  const filters = ['All', 'Barbell', 'Dumbbell', 'Bodyweight', 'Custom'];
  const list = CATALOG.filter(e => (filter === 'All' || (filter === 'Custom' ? e.custom : e.equip === filter)) && e.name.toLowerCase().includes(q.toLowerCase()));
  return /*#__PURE__*/React.createElement("div", {
    className: "screen"
  }, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(EHeader, {
    title: "Exercises",
    right: /*#__PURE__*/React.createElement(EIconButton, {
      icon: "plus",
      label: "Create custom exercise"
    })
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px var(--gutter-mobile) 0',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement(EInput, {
    icon: "search",
    placeholder: "Search 214 exercises",
    value: q,
    onChange: e => setQ(e.target.value)
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      marginTop: 12,
      overflowX: 'auto',
      paddingBottom: 4
    }
  }, filters.map(fl => /*#__PURE__*/React.createElement(EChip, {
    key: fl,
    selected: fl === filter,
    onClick: () => setFilter(fl)
  }, fl)))), /*#__PURE__*/React.createElement("div", {
    className: "scroll",
    style: {
      paddingTop: 12
    }
  }, q === '' && filter === 'All' && /*#__PURE__*/React.createElement(SectionLabel, null, "Recent"), list.length === 0 ? /*#__PURE__*/React.createElement(EEmptyState, {
    icon: "search-x",
    title: "No exercises found",
    description: `Nothing matches "${q}". Create it as a custom exercise instead.`
  }) : /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, list.map(e => /*#__PURE__*/React.createElement(EExerciseRow, {
    key: e.name,
    name: e.name,
    meta: `${e.equip} · ${e.group} · last: ${e.last}`,
    badge: e.custom ? /*#__PURE__*/React.createElement(EBadge, {
      tone: "neutral",
      size: "sm"
    }, "Custom") : null
  })))));
}
window.ExercisesScreen = ExercisesScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile-app/ExercisesScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile-app/HomeScreen.jsx
try { (() => {
const {
  Card: HCard,
  Button: HButton,
  IconButton: HIconButton,
  Icon: HIcon,
  Banner: HBanner,
  StatCard: HStatCard,
  WeekDots: HWeekDots,
  SyncBadge: HSyncBadge,
  EmptyState: HEmptyState
} = window.LifeOSStrengthDesignSystem_576cfb;
function HomeScreen({
  onRepeat,
  onStart,
  queued,
  empty
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "screen"
  }, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement("div", {
    className: "scroll"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      height: 48
    }
  }, /*#__PURE__*/React.createElement(Avatar, null), /*#__PURE__*/React.createElement(HIconButton, {
    icon: "bell",
    label: "Notifications",
    size: 40
  })), /*#__PURE__*/React.createElement("h1", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 34,
      lineHeight: '38px',
      fontWeight: 700,
      letterSpacing: '-.02em',
      margin: '10px 0 0'
    }
  }, "Good morning,", /*#__PURE__*/React.createElement("br", null), /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--action-primary)'
    }
  }, "Mariusz")), empty ? /*#__PURE__*/React.createElement(HEmptyState, {
    style: {
      marginTop: 40
    },
    icon: "dumbbell",
    title: "No workouts yet",
    description: "Start an empty session and log your first sets. Next time you can repeat it in one tap.",
    action: /*#__PURE__*/React.createElement(HButton, {
      size: "lg",
      shape: "pill",
      uppercase: true,
      onClick: onStart
    }, "Start workout")
  }) : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(SectionLabel, null, "Repeat last workout"), /*#__PURE__*/React.createElement(HCard, {
    pad: "none",
    radius: "xl",
    style: {
      overflow: 'hidden',
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/imagery/hero-back-rack.png",
    alt: "",
    style: {
      position: 'absolute',
      inset: 0,
      width: '100%',
      height: '100%',
      objectFit: 'cover',
      opacity: .55
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--scrim-side)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      padding: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      justifyContent: 'space-between',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 22,
      lineHeight: '26px',
      fontWeight: 700
    }
  }, "Push Day"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 4,
      fontSize: 13,
      color: 'var(--ink-200)'
    }
  }, "6 exercises \xB7 18 sets \xB7 ~45 min"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 2,
      fontSize: 12,
      color: 'var(--text-tertiary)'
    }
  }, "Last done 2 days ago")), /*#__PURE__*/React.createElement("button", {
    "aria-label": "Repeat last workout",
    onClick: onRepeat,
    style: {
      width: 52,
      height: 52,
      flex: '0 0 auto',
      borderRadius: 999,
      border: 'none',
      background: 'var(--action-primary)',
      color: 'var(--action-primary-text)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      cursor: 'pointer',
      boxShadow: 'var(--shadow-fab)'
    }
  }, /*#__PURE__*/React.createElement(HIcon, {
    name: "play",
    size: 22
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      marginTop: 14,
      flexWrap: 'wrap'
    }
  }, ['Bench Press', 'Incline DB Press', 'Overhead Press', '+3'].map(n => /*#__PURE__*/React.createElement("span", {
    key: n,
    style: {
      fontSize: 11,
      fontWeight: 700,
      color: 'var(--text-secondary)',
      background: 'rgba(255,255,255,.06)',
      border: '1px solid var(--border-subtle)',
      borderRadius: 999,
      padding: '4px 9px'
    }
  }, n))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 12,
      fontSize: 11,
      color: 'var(--text-tertiary)'
    }
  }, "Values pre-fill from that session. Nothing is saved as a template."))), /*#__PURE__*/React.createElement(HButton, {
    variant: "secondary",
    block: true,
    iconLeft: "plus",
    style: {
      marginTop: 10
    },
    onClick: onStart
  }, "Start empty workout"), queued && /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement(HBanner, {
    icon: "cloud-off",
    title: "2 workouts waiting to sync",
    description: "We'll sync when you're back online.",
    onClick: () => {}
  })), /*#__PURE__*/React.createElement(SectionLabel, null, "This week"), /*#__PURE__*/React.createElement(HCard, null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      fontWeight: 800
    }
  }, "Weekly progress"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--text-accent)',
      fontWeight: 800
    }
  }, "4 of 5 workouts")), /*#__PURE__*/React.createElement(HWeekDots, {
    days: [{
      label: 'M',
      done: true
    }, {
      label: 'T',
      done: true
    }, {
      label: 'W',
      done: true
    }, {
      label: 'T',
      done: true
    }, {
      label: 'F'
    }, {
      label: 'S'
    }, {
      label: 'S'
    }]
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 10,
      marginTop: 10
    }
  }, /*#__PURE__*/React.createElement(HStatCard, {
    style: {
      flex: 1
    },
    label: "Volume",
    value: "12,450",
    unit: "kg",
    delta: "+8%",
    footnote: "vs last week",
    icon: "trending-up"
  }), /*#__PURE__*/React.createElement(HStatCard, {
    style: {
      flex: 1
    },
    label: "Workouts",
    value: "4",
    footnote: "This week",
    icon: "calendar"
  })), /*#__PURE__*/React.createElement(SectionLabel, {
    action: "See all"
  }, "Recent activity"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, [['Pull Day', 'May 10, 2024 · 48 min', 'saved'], ['Legs', 'May 8, 2024 · 52 min', 'saved'], ['Push Day', 'May 6, 2024 · 45 min', 'queued']].map(([n, m, s]) => /*#__PURE__*/React.createElement(HCard, {
    key: n,
    pad: "tight",
    interactive: true
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 40,
      height: 40,
      borderRadius: 'var(--radius-md)',
      background: 'var(--surface-inset)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(HIcon, {
    name: "dumbbell",
    size: 18,
    color: "var(--text-secondary)"
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 15,
      fontWeight: 800
    }
  }, n), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 2
    }
  }, m)), /*#__PURE__*/React.createElement(HSyncBadge, {
    state: s,
    compact: true,
    label: s === 'saved' ? 'Saved' : 'Queued'
  }))))))));
}
window.HomeScreen = HomeScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile-app/HomeScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile-app/ProgressScreen.jsx
try { (() => {
const {
  Card: PCard,
  SegmentedControl: PSeg,
  Select: PSelect,
  TrendChart: PTrend,
  VolumeBars: PBars,
  ExerciseRow: PRow,
  ScreenHeader: PHeader,
  IconButton: PIconButton,
  Badge: PBadge,
  PRBadge: PPRBadge
} = window.LifeOSStrengthDesignSystem_576cfb;
function ProgressScreen() {
  const [metric, setMetric] = React.useState('Strength');
  const [range, setRange] = React.useState('This month');
  const series = [62, 68, 66, 74, 80, 86, 90, 88, 94, 96, 100, 102.5];
  const volume = [8, 12, 6, 14, 9, 17, 11, 15, 7, 13, 19, 10, 16, 12, 18, 9, 14, 11, 17, 20, 13, 15, 10, 19];
  return /*#__PURE__*/React.createElement("div", {
    className: "screen"
  }, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(PHeader, {
    title: "Progress",
    right: /*#__PURE__*/React.createElement(PIconButton, {
      icon: "sliders-horizontal",
      label: "Filter"
    })
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px var(--gutter-mobile) 0',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement(PSeg, {
    options: ['Strength', 'Volume', '1RM', 'Body'],
    value: metric,
    onChange: setMetric
  })), /*#__PURE__*/React.createElement("div", {
    className: "scroll",
    style: {
      paddingTop: 14
    }
  }, metric === 'Volume' ? /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(PSelect, {
    value: range,
    options: ['This week', 'This month', 'Last 3 months'],
    onChange: setRange
  }), /*#__PURE__*/React.createElement(PCard, {
    style: {
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "num",
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 28,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, "18,750"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "kg")), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, "Total volume"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--feedback-success)',
      fontWeight: 800,
      marginTop: 4
    }
  }, "+12% vs last month"), /*#__PURE__*/React.createElement(PBars, {
    style: {
      marginTop: 16
    },
    height: 110,
    data: volume,
    labels: ['May 1', 'May 14', 'May 28'],
    highlightLast: true
  }), /*#__PURE__*/React.createElement("details", {
    style: {
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement("summary", {
    style: {
      fontSize: 12,
      color: 'var(--text-accent)',
      fontWeight: 800,
      cursor: 'pointer'
    }
  }, "View as table"), /*#__PURE__*/React.createElement("table", {
    style: {
      width: '100%',
      marginTop: 8,
      borderCollapse: 'collapse',
      fontSize: 12,
      color: 'var(--text-secondary)'
    }
  }, /*#__PURE__*/React.createElement("thead", null, /*#__PURE__*/React.createElement("tr", null, /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'left',
      padding: '4px 0',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "Week"), /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'right',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "Volume"))), /*#__PURE__*/React.createElement("tbody", null, [['May 1–7', '4,120 kg'], ['May 8–14', '4,860 kg'], ['May 15–21', '4,510 kg'], ['May 22–28', '5,260 kg']].map(([a, b]) => /*#__PURE__*/React.createElement("tr", {
    key: a
  }, /*#__PURE__*/React.createElement("td", {
    style: {
      padding: '4px 0'
    }
  }, a), /*#__PURE__*/React.createElement("td", {
    className: "num",
    style: {
      textAlign: 'right',
      fontFamily: 'var(--font-numeric)'
    }
  }, b)))))))) : /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(PSelect, {
    value: "Bench Press",
    options: ['Bench Press', 'Back Squat', 'Deadlift']
  }), /*#__PURE__*/React.createElement(PCard, {
    style: {
      marginTop: 12
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'baseline',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "num",
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 28,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, "102.5"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "kg")), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-secondary)',
      marginTop: 2
    }
  }, "Estimated 1RM")), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'right'
    }
  }, /*#__PURE__*/React.createElement(PBadge, {
    tone: "accent"
  }, "+5.0 kg"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 11,
      color: 'var(--text-tertiary)',
      marginTop: 4
    }
  }, "vs last month"))), /*#__PURE__*/React.createElement(PTrend, {
    style: {
      marginTop: 16
    },
    height: 140,
    data: series,
    yTicks: [120, 100, 80, 60],
    xLabels: ['Apr 12', 'Apr 26', 'May 10', 'May 24', 'Jun 7']
  }), /*#__PURE__*/React.createElement("details", {
    style: {
      marginTop: 10
    }
  }, /*#__PURE__*/React.createElement("summary", {
    style: {
      fontSize: 12,
      color: 'var(--text-accent)',
      fontWeight: 800,
      cursor: 'pointer'
    }
  }, "View as table"), /*#__PURE__*/React.createElement("table", {
    style: {
      width: '100%',
      marginTop: 8,
      borderCollapse: 'collapse',
      fontSize: 12,
      color: 'var(--text-secondary)'
    }
  }, /*#__PURE__*/React.createElement("thead", null, /*#__PURE__*/React.createElement("tr", null, /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'left',
      padding: '4px 0',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "Date"), /*#__PURE__*/React.createElement("th", {
    style: {
      textAlign: 'right',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, "Est. 1RM"))), /*#__PURE__*/React.createElement("tbody", null, [['Apr 12', '62 kg'], ['Apr 26', '74 kg'], ['May 10', '90 kg'], ['May 24', '96 kg'], ['Jun 7', '102.5 kg']].map(([a, b]) => /*#__PURE__*/React.createElement("tr", {
    key: a
  }, /*#__PURE__*/React.createElement("td", {
    style: {
      padding: '4px 0'
    }
  }, a), /*#__PURE__*/React.createElement("td", {
    className: "num",
    style: {
      textAlign: 'right',
      fontFamily: 'var(--font-numeric)'
    }
  }, b)))))))), /*#__PURE__*/React.createElement(SectionLabel, {
    action: "See all"
  }, "Personal records"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, [['Bench Press', '1RM · May 10, 2024', '102.5 kg', true], ['Back Squat', '1RM · May 8, 2024', '140.0 kg', false], ['Deadlift', '1RM · May 5, 2024', '160.0 kg', false]].map(([n, m, v, fresh]) => /*#__PURE__*/React.createElement(PRow, {
    key: n,
    name: n,
    meta: m,
    badge: fresh ? /*#__PURE__*/React.createElement(PPRBadge, {
      label: "New"
    }) : null,
    right: /*#__PURE__*/React.createElement("span", {
      className: "num",
      style: {
        fontFamily: 'var(--font-numeric)',
        fontVariantNumeric: 'tabular-nums',
        fontSize: 17,
        fontWeight: 700
      }
    }, v)
  })))));
}
window.ProgressScreen = ProgressScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile-app/ProgressScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile-app/SignInScreen.jsx
try { (() => {
const {
  Button: SButton,
  Input: SInput
} = window.LifeOSStrengthDesignSystem_576cfb;
function SignInScreen({
  onSignIn
}) {
  const [err, setErr] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", {
    className: "screen"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      height: 300,
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/imagery/hero-dumbbell.png",
    alt: "",
    style: {
      width: '100%',
      height: '100%',
      objectFit: 'cover',
      objectPosition: '62% 26%'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--scrim-strong)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 20,
      right: 20,
      bottom: 18
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 34,
      lineHeight: '38px',
      fontWeight: 800,
      letterSpacing: '-.03em'
    }
  }, "LifeOS", /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--action-primary)'
    }
  }, ".")), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 6,
      fontSize: 14,
      color: 'var(--ink-200)'
    }
  }, "A fast, trustworthy ledger for the gym."))), /*#__PURE__*/React.createElement("div", {
    className: "scroll",
    style: {
      paddingTop: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement(SInput, {
    label: "Email",
    icon: "mail",
    placeholder: "marek@example.com",
    defaultValue: "marek@example.com"
  }), /*#__PURE__*/React.createElement(SInput, {
    label: "Password",
    icon: "lock",
    type: "password",
    defaultValue: "trening123",
    error: err ? 'Incorrect email or password' : undefined
  }), /*#__PURE__*/React.createElement(SButton, {
    variant: "primary",
    size: "lg",
    block: true,
    uppercase: true,
    onClick: onSignIn,
    style: {
      marginTop: 4
    }
  }, "Sign in"), /*#__PURE__*/React.createElement("button", {
    onClick: () => setErr(!err),
    style: {
      background: 'none',
      border: 'none',
      color: 'var(--text-secondary)',
      fontSize: 13,
      fontWeight: 700,
      cursor: 'pointer',
      padding: '6px 0'
    }
  }, "Forgot password?"), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      fontSize: 13,
      color: 'var(--text-tertiary)',
      marginTop: 4
    }
  }, "No account? ", /*#__PURE__*/React.createElement("a", {
    href: "#",
    onClick: e => e.preventDefault()
  }, "Create one"))), /*#__PURE__*/React.createElement("p", {
    style: {
      marginTop: 28,
      fontSize: 11,
      lineHeight: '16px',
      color: 'var(--text-tertiary)',
      textAlign: 'center'
    }
  }, "Email and password only in v1.0 \u2014 Google and Apple sign-in arrive in v1.0.1.")));
}
window.SignInScreen = SignInScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile-app/SignInScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile-app/SummaryScreen.jsx
try { (() => {
const {
  Card: MCard,
  Button: MButton,
  Icon: MIcon,
  StatCard: MStatCard,
  SyncBadge: MSyncBadge,
  PRBadge: MPRBadge,
  Banner: MBanner,
  ScreenHeader: MHeader
} = window.LifeOSStrengthDesignSystem_576cfb;
function SummaryScreen({
  onDone
}) {
  const [sync, setSync] = React.useState('queued');
  React.useEffect(() => {
    const a = setTimeout(() => setSync('syncing'), 2200);
    const b = setTimeout(() => setSync('saved'), 4600);
    return () => {
      clearTimeout(a);
      clearTimeout(b);
    };
  }, []);
  return /*#__PURE__*/React.createElement("div", {
    className: "screen"
  }, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(MHeader, {
    title: "Workout summary"
  }), /*#__PURE__*/React.createElement("div", {
    className: "scroll",
    style: {
      paddingTop: 8
    }
  }, /*#__PURE__*/React.createElement(MCard, {
    radius: "xl",
    pad: "loose"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: 'var(--font-display)',
      fontSize: 22,
      fontWeight: 700
    }
  }, "Push Day"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 2
    }
  }, "Today \xB7 09:41 \u2013 10:26")), /*#__PURE__*/React.createElement(MSyncBadge, {
    state: sync
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 20,
      marginTop: 18
    }
  }, [['45:12', 'Duration'], ['18', 'Working sets'], ['12,450', 'Volume kg']].map(([v, l]) => /*#__PURE__*/React.createElement("div", {
    key: l
  }, /*#__PURE__*/React.createElement("div", {
    className: "num",
    style: {
      fontFamily: 'var(--font-numeric)',
      fontVariantNumeric: 'tabular-nums',
      fontSize: 24,
      fontWeight: 700,
      letterSpacing: '-.02em'
    }
  }, v), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 11,
      letterSpacing: '.06em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700,
      marginTop: 3
    }
  }, l))))), /*#__PURE__*/React.createElement(SectionLabel, null, "New records"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 8
    }
  }, [['Bench Press', '105 kg × 4', '+2.5 kg'], ['Incline Dumbbell Press', '26 kg × 8', '+2 reps']].map(([n, v, d]) => /*#__PURE__*/React.createElement(MCard, {
    key: n,
    pad: "tight"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 36,
      height: 36,
      borderRadius: 999,
      background: 'var(--feedback-success-quiet)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(MIcon, {
    name: "trophy",
    size: 17,
    color: "var(--feedback-success)"
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 14,
      fontWeight: 800
    }
  }, n), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 2
    }
  }, v)), /*#__PURE__*/React.createElement(MPRBadge, {
    label: "PR",
    detail: d
  }))))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 14
    }
  }, sync === 'queued' && /*#__PURE__*/React.createElement(MBanner, {
    icon: "clock",
    title: "Saved on this device",
    description: "Waiting for a connection. Nothing is lost \u2014 it uploads by itself."
  }), sync === 'syncing' && /*#__PURE__*/React.createElement(MBanner, {
    icon: "refresh-cw",
    tone: "info",
    title: "Sending to the server",
    description: "You can leave this screen."
  }), sync === 'saved' && /*#__PURE__*/React.createElement(MBanner, {
    icon: "check",
    title: "On the server",
    description: "Available on your other devices."
  })), /*#__PURE__*/React.createElement(MButton, {
    variant: "primary",
    size: "lg",
    shape: "pill",
    block: true,
    uppercase: true,
    style: {
      marginTop: 16
    },
    onClick: onDone
  }, "Done"), /*#__PURE__*/React.createElement("button", {
    style: {
      width: '100%',
      minHeight: 44,
      marginTop: 6,
      background: 'none',
      border: 'none',
      color: 'var(--text-secondary)',
      fontSize: 13,
      fontWeight: 700,
      cursor: 'pointer'
    }
  }, "Edit workout")));
}
window.SummaryScreen = SummaryScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile-app/SummaryScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile-app/WorkoutScreen.jsx
try { (() => {
const {
  Card: WCard,
  Button: WButton,
  IconButton: WIconButton,
  Icon: WIcon,
  SetRow: WSetRow,
  RestTimer: WRestTimer,
  SyncBadge: WSyncBadge,
  ScreenHeader: WHeader,
  Stepper: WStepper,
  Chip: WChip,
  PRBadge: WPRBadge
} = window.LifeOSStrengthDesignSystem_576cfb;
const EXERCISES = [{
  name: 'Bench Press',
  equip: 'Barbell',
  last: '100 kg × 8, 5 days ago',
  sets: [{
    w: 60,
    r: 10,
    rpe: '—',
    warmup: true,
    state: 'logged'
  }, {
    w: 100,
    r: 8,
    rpe: 8,
    state: 'logged'
  }, {
    w: 100,
    r: 6,
    rpe: 8.5,
    state: 'logged'
  }, {
    w: 105,
    r: 4,
    rpe: 9,
    state: 'active'
  }, {
    w: 105,
    r: 4,
    rpe: 9,
    state: 'proposed'
  }]
}, {
  name: 'Incline Dumbbell Press',
  equip: 'Dumbbell',
  last: '24 kg × 10, 5 days ago',
  sets: [{
    w: 24,
    r: 10,
    rpe: 8,
    state: 'logged'
  }, {
    w: 26,
    r: 8,
    rpe: 8.5,
    state: 'proposed'
  }]
}];
function SetTable({
  ex,
  onConfirm
}) {
  return /*#__PURE__*/React.createElement(WCard, {
    pad: "tight",
    style: {
      marginBottom: 10
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-start',
      gap: 10,
      padding: '4px 6px 10px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 24,
      height: 24,
      borderRadius: 999,
      background: 'var(--surface-inset)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontFamily: 'var(--font-numeric)',
      fontSize: 12,
      fontWeight: 700,
      color: 'var(--text-secondary)',
      flex: '0 0 auto',
      marginTop: 2
    }
  }, ex.n), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 16,
      fontWeight: 800
    }
  }, ex.name), ex.pr && /*#__PURE__*/React.createElement(WPRBadge, null)), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 12,
      color: 'var(--text-tertiary)',
      marginTop: 2
    }
  }, ex.equip), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'block',
      fontSize: 11,
      color: 'var(--set-proposed-text)',
      marginTop: 4
    }
  }, "Last time: ", ex.last)), /*#__PURE__*/React.createElement(WIconButton, {
    icon: "ellipsis",
    label: "Exercise options",
    size: 32,
    iconSize: 18
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      padding: '0 10px 6px 4px',
      fontSize: 10,
      letterSpacing: '.08em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 34,
      textAlign: 'center'
    }
  }, "Set"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Kg"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "Reps"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center'
    }
  }, "RPE"), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 32
    }
  })), ex.sets.map((s, i) => /*#__PURE__*/React.createElement(WSetRow, {
    key: i,
    index: ex.sets.slice(0, i + 1).filter(x => !x.warmup).length,
    weight: s.w,
    reps: s.r,
    rir: s.rpe,
    warmup: s.warmup,
    state: s.state,
    onConfirm: () => onConfirm(ex.i, i)
  })), /*#__PURE__*/React.createElement("button", {
    style: {
      width: '100%',
      minHeight: 40,
      marginTop: 4,
      background: 'transparent',
      border: 'none',
      color: 'var(--text-accent)',
      fontSize: 13,
      fontWeight: 800,
      cursor: 'pointer',
      fontFamily: 'var(--font-ui)'
    }
  }, "+ Add set"));
}
function WorkoutScreen({
  onBack,
  onComplete
}) {
  const [data, setData] = React.useState(EXERCISES);
  const [timer, setTimer] = React.useState(75);
  const [running, setRunning] = React.useState(true);
  React.useEffect(() => {
    if (!running) return;
    const id = setInterval(() => setTimer(t => t > 0 ? t - 1 : 0), 1000);
    return () => clearInterval(id);
  }, [running]);
  const confirm = (ei, si) => setData(d => d.map((ex, i) => i !== ei ? ex : {
    ...ex,
    sets: ex.sets.map((s, j) => {
      if (j !== si) return s;
      return {
        ...s,
        state: 'logged'
      };
    }).map((s, j) => j === si + 1 && s.state === 'proposed' ? {
      ...s,
      state: 'active'
    } : s)
  }));
  const logged = data.flatMap(e => e.sets).filter(s => s.state === 'logged' && !s.warmup).length;
  const total = data.flatMap(e => e.sets).filter(s => !s.warmup).length;
  const mmss = `${Math.floor(timer / 60)}:${String(timer % 60).padStart(2, '0')}`;
  const active = data.find(e => e.sets.some(s => s.state === 'active'));
  const activeSet = active && active.sets.find(s => s.state === 'active');
  return /*#__PURE__*/React.createElement("div", {
    className: "screen"
  }, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement(WHeader, {
    title: "Push Day",
    subtitle: `${logged} of ${total} working sets`,
    onBack: onBack,
    right: /*#__PURE__*/React.createElement(WSyncBadge, {
      state: "draft_local",
      compact: true,
      label: "On device"
    })
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 3,
      margin: '2px var(--gutter-mobile) 0',
      background: 'var(--surface-raised)',
      borderRadius: 999,
      overflow: 'hidden',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      height: '100%',
      width: `${logged / total * 100}%`,
      background: 'var(--action-primary)',
      transition: 'width var(--dur-base) var(--ease-standard)'
    }
  })), /*#__PURE__*/React.createElement("div", {
    className: "scroll",
    style: {
      paddingTop: 12,
      paddingBottom: 210
    }
  }, data.map((ex, i) => /*#__PURE__*/React.createElement(SetTable, {
    key: ex.name,
    ex: {
      ...ex,
      n: i + 1,
      i
    },
    onConfirm: confirm
  })), /*#__PURE__*/React.createElement(WButton, {
    variant: "secondary",
    block: true,
    iconLeft: "plus"
  }, "Add exercise")), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 0,
      right: 0,
      bottom: 0,
      padding: '12px var(--gutter-mobile) 16px',
      background: 'linear-gradient(180deg,rgba(7,10,15,0) 0%,var(--surface-base) 34%)'
    }
  }, activeSet && /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      marginBottom: 10
    }
  }, /*#__PURE__*/React.createElement(WStepper, {
    style: {
      flex: 1
    },
    value: activeSet.w,
    step: 2.5,
    unit: "kg",
    onChange: v => setData(d => d.map(e => ({
      ...e,
      sets: e.sets.map(s => s.state === 'active' ? {
        ...s,
        w: v
      } : s)
    })))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 6
    }
  }, [activeSet.w + 2.5, activeSet.w + 5].map(v => /*#__PURE__*/React.createElement(WChip, {
    key: v,
    onClick: () => setData(d => d.map(e => ({
      ...e,
      sets: e.sets.map(s => s.state === 'active' ? {
        ...s,
        w: v
      } : s)
    })))
  }, v, " kg")))), /*#__PURE__*/React.createElement(WRestTimer, {
    remaining: mmss,
    running: running,
    onToggle: () => setRunning(r => !r),
    nextLabel: "Next",
    nextValue: "Overhead Press",
    style: {
      marginBottom: 10
    }
  }), /*#__PURE__*/React.createElement(WButton, {
    variant: "primary",
    size: "lg",
    shape: "pill",
    block: true,
    uppercase: true,
    onClick: onComplete
  }, "Complete workout")));
}
window.WorkoutScreen = WorkoutScreen;
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile-app/WorkoutScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile-app/app.jsx
try { (() => {
const {
  BottomNav: ABottomNav
} = window.LifeOSStrengthDesignSystem_576cfb;
function App() {
  const [signed, setSigned] = React.useState(false);
  const [tab, setTab] = React.useState('home');
  const [view, setView] = React.useState('home');
  if (!signed) return /*#__PURE__*/React.createElement(SignInScreen, {
    onSignIn: () => setSigned(true)
  });
  let screen;
  if (view === 'workout') screen = /*#__PURE__*/React.createElement(WorkoutScreen, {
    onBack: () => {
      setView('home');
      setTab('home');
    },
    onComplete: () => setView('summary')
  });else if (view === 'summary') screen = /*#__PURE__*/React.createElement(SummaryScreen, {
    onDone: () => {
      setView('home');
      setTab('home');
    }
  });else if (tab === 'exercises') screen = /*#__PURE__*/React.createElement(ExercisesScreen, null);else if (tab === 'progress') screen = /*#__PURE__*/React.createElement(ProgressScreen, null);else screen = /*#__PURE__*/React.createElement(HomeScreen, {
    queued: true,
    onRepeat: () => {
      setView('workout');
      setTab('workout');
    },
    onStart: () => {
      setView('workout');
      setTab('workout');
    }
  });
  const hideNav = view === 'summary';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      flex: 1,
      minHeight: 0
    }
  }, screen), !hideNav && /*#__PURE__*/React.createElement(ABottomNav, {
    active: tab,
    onSelect: k => {
      setTab(k);
      setView(k === 'workout' ? 'workout' : 'home');
    },
    onAdd: () => {
      setView('workout');
      setTab('workout');
    }
  }));
}
ReactDOM.createRoot(document.getElementById('root')).render(/*#__PURE__*/React.createElement(App, null));
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile-app/app.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile-app/shell.jsx
try { (() => {
const DS = window.LifeOSStrengthDesignSystem_576cfb;
const {
  Icon
} = DS;
function StatusBar() {
  return /*#__PURE__*/React.createElement("div", {
    className: "statusbar"
  }, /*#__PURE__*/React.createElement("span", null, "9:41"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "signal",
    size: 16
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "wifi",
    size: 16
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "battery-full",
    size: 20
  })));
}
function SectionLabel({
  children,
  action,
  onAction
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "eyebrow",
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 11,
      letterSpacing: '.08em',
      textTransform: 'uppercase',
      color: 'var(--text-tertiary)',
      fontWeight: 700
    }
  }, children), action && /*#__PURE__*/React.createElement("button", {
    onClick: onAction,
    style: {
      background: 'none',
      border: 'none',
      color: 'var(--text-accent)',
      fontSize: 12,
      fontWeight: 800,
      cursor: 'pointer',
      padding: 0
    }
  }, action));
}
function Avatar({
  size = 36
}) {
  return /*#__PURE__*/React.createElement("span", {
    style: {
      width: size,
      height: size,
      borderRadius: 999,
      background: 'var(--surface-raised)',
      border: '1px solid var(--border-default)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      flex: '0 0 auto'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "user",
    size: size * 0.5,
    color: "var(--text-tertiary)"
  }));
}
Object.assign(window, {
  StatusBar,
  SectionLabel,
  Avatar,
  DS
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile-app/shell.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.Chip = __ds_scope.Chip;

__ds_ns.Icon = __ds_scope.Icon;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.Input = __ds_scope.Input;

__ds_ns.SegmentedControl = __ds_scope.SegmentedControl;

__ds_ns.Select = __ds_scope.Select;

__ds_ns.Stepper = __ds_scope.Stepper;

__ds_ns.Banner = __ds_scope.Banner;

__ds_ns.ConfirmDialog = __ds_scope.ConfirmDialog;

__ds_ns.EmptyState = __ds_scope.EmptyState;

__ds_ns.ExerciseRow = __ds_scope.ExerciseRow;

__ds_ns.PRBadge = __ds_scope.PRBadge;

__ds_ns.RestTimer = __ds_scope.RestTimer;

__ds_ns.SetRow = __ds_scope.SetRow;

__ds_ns.StatCard = __ds_scope.StatCard;

__ds_ns.SYNC_STATES = __ds_scope.SYNC_STATES;

__ds_ns.SyncBadge = __ds_scope.SyncBadge;

__ds_ns.TrendChart = __ds_scope.TrendChart;

__ds_ns.VolumeBars = __ds_scope.VolumeBars;

__ds_ns.WeekDots = __ds_scope.WeekDots;

__ds_ns.NAV_ITEMS = __ds_scope.NAV_ITEMS;

__ds_ns.BottomNav = __ds_scope.BottomNav;

__ds_ns.ScreenHeader = __ds_scope.ScreenHeader;

})();
