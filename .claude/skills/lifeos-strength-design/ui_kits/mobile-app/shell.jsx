const DS = window.LifeOSStrengthDesignSystem_576cfb;
const { Icon } = DS;

function StatusBar(){
  return (<div className="statusbar">
    <span>9:41</span>
    <span style={{display:'flex',alignItems:'center',gap:6}}>
      <Icon name="signal" size={16}/><Icon name="wifi" size={16}/><Icon name="battery-full" size={20}/>
    </span>
  </div>);
}

function SectionLabel({children, action, onAction}){
  return (<div className="eyebrow" style={{display:'flex',alignItems:'center',justifyContent:'space-between'}}>
    <span style={{fontSize:11,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>{children}</span>
    {action && <button onClick={onAction} style={{background:'none',border:'none',color:'var(--text-accent)',fontSize:12,fontWeight:800,cursor:'pointer',padding:0}}>{action}</button>}
  </div>);
}

function Avatar({size=36}){
  return (<span style={{width:size,height:size,borderRadius:999,background:'var(--surface-raised)',border:'1px solid var(--border-default)',display:'inline-flex',alignItems:'center',justifyContent:'center',flex:'0 0 auto'}}>
    <Icon name="user" size={size*0.5} color="var(--text-tertiary)"/>
  </span>);
}

Object.assign(window,{StatusBar,SectionLabel,Avatar,DS});
