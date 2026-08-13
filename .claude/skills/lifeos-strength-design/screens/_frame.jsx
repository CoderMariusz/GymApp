const SDS = window.LifeOSStrengthDesignSystem_576cfb;
const { Icon: FIcon } = SDS;

function PhoneFrame({label, note, theme='dark', children}){
  return (<figure style={{margin:0,display:'flex',flexDirection:'column',gap:10,flex:'0 0 auto'}}>
    <figcaption style={{display:'flex',alignItems:'center',gap:8,minHeight:20}}>
      <span style={{fontSize:12,fontWeight:800,color:'var(--text-primary)',fontFamily:'var(--font-ui)'}}>{label}</span>
      <span style={{fontSize:10,letterSpacing:'.06em',textTransform:'uppercase',fontWeight:700,padding:'2px 7px',borderRadius:999,color:theme==='light'?'var(--ink-1000)':'var(--text-tertiary)',background:theme==='light'?'var(--ink-100)':'var(--surface-inset)'}}>{theme}</span>
      {note && <span style={{fontSize:11,color:'var(--text-tertiary)'}}>{note}</span>}
    </figcaption>
    <div data-theme={theme} style={{width:390,height:844,position:'relative',background:'var(--surface-base)',borderRadius:'var(--radius-device)',overflow:'hidden',border:'1px solid var(--ink-800)',boxShadow:'var(--shadow-float)',color:'var(--text-primary)',fontFamily:'var(--font-ui)'}}>{children}</div>
  </figure>);
}

function DesktopFrame({label, note, theme='dark', height=900, children}){
  return (<figure style={{margin:0,display:'flex',flexDirection:'column',gap:10,flex:'0 0 auto'}}>
    <figcaption style={{display:'flex',alignItems:'center',gap:8}}>
      <span style={{fontSize:13,fontWeight:800,color:'var(--text-primary)',fontFamily:'var(--font-ui)'}}>{label}</span>
      <span style={{fontSize:10,letterSpacing:'.06em',textTransform:'uppercase',fontWeight:700,padding:'2px 7px',borderRadius:999,color:theme==='light'?'var(--ink-1000)':'var(--text-tertiary)',background:theme==='light'?'var(--ink-100)':'var(--surface-inset)'}}>{theme}</span>
      {note && <span style={{fontSize:11,color:'var(--text-tertiary)'}}>{note}</span>}
    </figcaption>
    <div data-theme={theme} style={{width:1440,height,position:'relative',overflow:'hidden',background:'var(--surface-base)',borderRadius:'var(--radius-lg)',border:'1px solid var(--ink-800)',color:'var(--text-primary)',fontFamily:'var(--font-ui)'}}>{children}</div>
  </figure>);
}

function Screen({children, pad=true}){
  return (<div style={{position:'absolute',inset:0,display:'flex',flexDirection:'column',overflow:'hidden'}}>{children}</div>);
}

function Scroll({children, style}){
  return (<div style={{flex:1,overflowY:'auto',padding:'0 var(--gutter-mobile) 32px',scrollbarWidth:'none',...style}}>{children}</div>);
}

function Bar({onPhoto}){
  return (<div style={{display:'flex',alignItems:'center',justifyContent:'space-between',height:44,padding:'0 22px 0 26px',fontFamily:'var(--font-numeric)',fontSize:14,fontWeight:700,flex:'0 0 auto',color:onPhoto?'#fff':'var(--text-primary)'}}>
    <span>9:41</span>
    <span style={{display:'flex',alignItems:'center',gap:6,color:'inherit'}}><FIcon name="signal" size={16} color="currentColor"/><FIcon name="wifi" size={16} color="currentColor"/><FIcon name="battery-full" size={20} color="currentColor"/></span>
  </div>);
}

function Eyebrow({children, action}){
  return (<div style={{display:'flex',alignItems:'center',justifyContent:'space-between',margin:'20px 0 10px'}}>
    <span style={{fontSize:11,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>{children}</span>
    {action && <span style={{fontSize:12,fontWeight:800,color:'var(--text-accent)'}}>{action}</span>}
  </div>);
}

function Row({label, value, icon, chevron=true, tone}){
  return (<div style={{display:'flex',alignItems:'center',gap:12,minHeight:52,padding:'0 14px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)'}}>
    {icon && <FIcon name={icon} size={18} color={tone==='danger'?'var(--feedback-danger)':'var(--text-secondary)'}/>}
    <span style={{flex:1,fontSize:14,fontWeight:700,color:tone==='danger'?'var(--feedback-danger)':'var(--text-primary)'}}>{label}</span>
    {value && <span style={{fontSize:13,color:'var(--text-tertiary)'}}>{value}</span>}
    {chevron && <FIcon name="chevron-right" size={17} color="var(--text-tertiary)"/>}
  </div>);
}

function Overlay({children}){
  return (<div style={{position:'absolute',inset:0,display:'flex',alignItems:'center',justifyContent:'center',padding:20,background:'rgba(4,6,10,.72)',backdropFilter:'var(--blur-overlay)'}}>{children}</div>);
}

function Sheet({children, height='72%'}){
  return (<div style={{position:'absolute',inset:0}}>
    <div style={{position:'absolute',inset:0,background:'rgba(4,6,10,.68)',backdropFilter:'var(--blur-overlay)'}}/>
    <div style={{position:'absolute',left:0,right:0,bottom:0,height,background:'var(--surface-card)',borderTopLeftRadius:'var(--radius-2xl)',borderTopRightRadius:'var(--radius-2xl)',borderTop:'1px solid var(--border-default)',boxShadow:'var(--shadow-sheet)',display:'flex',flexDirection:'column',overflow:'hidden'}}>
      <div style={{display:'flex',justifyContent:'center',padding:'10px 0 4px',flex:'0 0 auto'}}><span style={{width:38,height:4,borderRadius:999,background:'var(--border-strong)'}}/></div>
      {children}
    </div>
  </div>);
}

Object.assign(window,{PhoneFrame,DesktopFrame,Screen,Scroll,Bar,Eyebrow,Row,Overlay,Sheet,SDS});
