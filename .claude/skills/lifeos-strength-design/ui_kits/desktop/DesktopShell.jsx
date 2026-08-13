const DDS = window.LifeOSStrengthDesignSystem_576cfb;
const { Icon: DIcon, Button: DButton, SyncBadge: DSyncBadge } = DDS;

const NAV=[['home','Home','house'],['workout','Workout','dumbbell'],['exercises','Exercises','list'],['history','History','history'],['progress','Progress','chart-column']];

function DesktopShell({view,onNavigate,children}){
  return (<div style={{display:'flex',minHeight:900,background:'var(--surface-base)'}}>
    <aside style={{width:248,flex:'0 0 auto',padding:'24px 16px',borderRight:'1px solid var(--border-subtle)',display:'flex',flexDirection:'column',gap:24,background:'var(--surface-sunken)'}}>
      <div style={{fontFamily:'var(--font-display)',fontSize:24,fontWeight:800,letterSpacing:'-.03em',padding:'0 8px'}}>LifeOS<span style={{color:'var(--action-primary)'}}>.</span></div>
      <nav style={{display:'flex',flexDirection:'column',gap:2}}>
        {NAV.map(([k,label,icon])=>{
          const on=k===view;
          return (<button key={k} onClick={()=>onNavigate(k)} style={{display:'flex',alignItems:'center',gap:12,minHeight:44,padding:'0 12px',background:on?'var(--set-active-bg)':'transparent',border:`1px solid ${on?'var(--border-accent)':'transparent'}`,borderRadius:'var(--radius-md)',color:on?'var(--text-accent)':'var(--text-secondary)',fontSize:14,fontWeight:on?800:600,cursor:'pointer',fontFamily:'var(--font-ui)',textAlign:'left'}}>
            <DIcon name={icon} size={19}/>{label}
          </button>);
        })}
      </nav>
      <DButton variant="primary" block iconLeft="plus" onClick={()=>onNavigate('workout')}>Start workout</DButton>
      <div style={{marginTop:'auto',display:'flex',flexDirection:'column',gap:12}}>
        <DSyncBadge state="saved"/>
        <button style={{display:'flex',alignItems:'center',gap:10,minHeight:44,padding:'0 8px',background:'transparent',border:'none',cursor:'pointer',color:'var(--text-secondary)',fontFamily:'var(--font-ui)',fontSize:13,fontWeight:700}}>
          <span style={{width:32,height:32,borderRadius:999,background:'var(--surface-raised)',border:'1px solid var(--border-default)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><DIcon name="user" size={16} color="var(--text-tertiary)"/></span>
          Mariusz
          <DIcon name="settings" size={16} style={{marginLeft:'auto'}}/>
        </button>
      </div>
    </aside>
    <main style={{flex:1,minWidth:0,padding:'28px 32px 40px'}}>
      <div style={{maxWidth:1160,margin:'0 auto'}}>{children}</div>
    </main>
  </div>);
}

function CatalogView(){
  const { Input, Chip, ExerciseRow, Badge } = DDS;
  const rows=[['Bench Press','Barbell · Chest','100 kg × 8'],['Incline Dumbbell Press','Dumbbell · Chest','26 kg × 8'],['Overhead Press','Barbell · Shoulders','55 kg × 6'],['Barbell Row','Barbell · Back','90 kg × 8'],['Back Squat','Barbell · Legs','140 kg × 5'],['Farmer Carry','Dumbbell · Carry','40 kg · 40 m']];
  return (<div>
    <h1 style={{fontFamily:'var(--font-display)',fontSize:46,lineHeight:'50px',fontWeight:700,letterSpacing:'-.02em',margin:'0 0 20px'}}>Exercises</h1>
    <div style={{display:'flex',gap:12,alignItems:'center',marginBottom:20}}>
      <Input icon="search" placeholder="Search 214 exercises" style={{width:360}}/>
      {['All','Barbell','Dumbbell','Bodyweight','Custom'].map((c,i)=><Chip key={c} selected={i===0}>{c}</Chip>)}
    </div>
    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
      {rows.map(([n,m,l])=><ExerciseRow key={n} name={n} meta={m} right={<span className="num" style={{fontFamily:'var(--font-numeric)',fontSize:15,fontWeight:700,color:'var(--text-secondary)'}}>{l}</span>}/>)}
    </div>
  </div>);
}

Object.assign(window,{DesktopShell,CatalogView});
