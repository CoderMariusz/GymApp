const { Card: HCard, Button: HButton, IconButton: HIconButton, Icon: HIcon, Banner: HBanner, StatCard: HStatCard, WeekDots: HWeekDots, SyncBadge: HSyncBadge, EmptyState: HEmptyState } = window.LifeOSStrengthDesignSystem_576cfb;

function HomeScreen({onRepeat, onStart, queued, empty}){
  return (<div className="screen">
    <StatusBar/>
    <div className="scroll">
      <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',height:48}}>
        <Avatar/>
        <HIconButton icon="bell" label="Notifications" size={40}/>
      </div>
      <h1 style={{fontFamily:'var(--font-display)',fontSize:34,lineHeight:'38px',fontWeight:700,letterSpacing:'-.02em',margin:'10px 0 0'}}>
        Good morning,<br/><span style={{color:'var(--action-primary)'}}>Mariusz</span>
      </h1>

      {empty ? (
        <HEmptyState style={{marginTop:40}} icon="dumbbell" title="No workouts yet"
          description="Start an empty session and log your first sets. Next time you can repeat it in one tap."
          action={<HButton size="lg" shape="pill" uppercase onClick={onStart}>Start workout</HButton>}/>
      ) : (<React.Fragment>
        <SectionLabel>Repeat last workout</SectionLabel>
        <HCard pad="none" radius="xl" style={{overflow:'hidden',position:'relative'}}>
          <img src="../../assets/imagery/hero-back-rack.png" alt="" style={{position:'absolute',inset:0,width:'100%',height:'100%',objectFit:'cover',opacity:.55}}/>
          <div style={{position:'absolute',inset:0,background:'var(--scrim-side)'}}/>
          <div style={{position:'relative',padding:16}}>
            <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between',gap:12}}>
              <div>
                <div style={{fontFamily:'var(--font-display)',fontSize:22,lineHeight:'26px',fontWeight:700}}>Push Day</div>
                <div style={{marginTop:4,fontSize:13,color:'var(--ink-200)'}}>6 exercises · 18 sets · ~45 min</div>
                <div style={{marginTop:2,fontSize:12,color:'var(--text-tertiary)'}}>Last done 2 days ago</div>
              </div>
              <button aria-label="Repeat last workout" onClick={onRepeat} style={{width:52,height:52,flex:'0 0 auto',borderRadius:999,border:'none',background:'var(--action-primary)',color:'var(--action-primary-text)',display:'inline-flex',alignItems:'center',justifyContent:'center',cursor:'pointer',boxShadow:'var(--shadow-fab)'}}>
                <HIcon name="play" size={22}/>
              </button>
            </div>
            <div style={{display:'flex',gap:6,marginTop:14,flexWrap:'wrap'}}>
              {['Bench Press','Incline DB Press','Overhead Press','+3'].map(n=>
                <span key={n} style={{fontSize:11,fontWeight:700,color:'var(--text-secondary)',background:'rgba(255,255,255,.06)',border:'1px solid var(--border-subtle)',borderRadius:999,padding:'4px 9px'}}>{n}</span>)}
            </div>
            <div style={{marginTop:12,fontSize:11,color:'var(--text-tertiary)'}}>Values pre-fill from that session. Nothing is saved as a template.</div>
          </div>
        </HCard>
        <HButton variant="secondary" block iconLeft="plus" style={{marginTop:10}} onClick={onStart}>Start empty workout</HButton>

        {queued && <div style={{marginTop:12}}>
          <HBanner icon="cloud-off" title="2 workouts waiting to sync" description="We'll sync when you're back online." onClick={()=>{}}/>
        </div>}

        <SectionLabel>This week</SectionLabel>
        <HCard>
          <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:14}}>
            <span style={{fontSize:14,fontWeight:800}}>Weekly progress</span>
            <span style={{fontSize:12,color:'var(--text-accent)',fontWeight:800}}>4 of 5 workouts</span>
          </div>
          <HWeekDots days={[{label:'M',done:true},{label:'T',done:true},{label:'W',done:true},{label:'T',done:true},{label:'F'},{label:'S'},{label:'S'}]}/>
        </HCard>
        <div style={{display:'flex',gap:10,marginTop:10}}>
          <HStatCard style={{flex:1}} label="Volume" value="12,450" unit="kg" delta="+8%" footnote="vs last week" icon="trending-up"/>
          <HStatCard style={{flex:1}} label="Workouts" value="4" footnote="This week" icon="calendar"/>
        </div>

        <SectionLabel action="See all">Recent activity</SectionLabel>
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {[['Pull Day','May 10, 2024 · 48 min','saved'],['Legs','May 8, 2024 · 52 min','saved'],['Push Day','May 6, 2024 · 45 min','queued']].map(([n,m,s])=>
            <HCard key={n} pad="tight" interactive>
              <div style={{display:'flex',alignItems:'center',gap:12}}>
                <span style={{width:40,height:40,borderRadius:'var(--radius-md)',background:'var(--surface-inset)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><HIcon name="dumbbell" size={18} color="var(--text-secondary)"/></span>
                <span style={{flex:1,minWidth:0}}>
                  <span style={{display:'block',fontSize:15,fontWeight:800}}>{n}</span>
                  <span style={{display:'block',fontSize:12,color:'var(--text-tertiary)',marginTop:2}}>{m}</span>
                </span>
                <HSyncBadge state={s} compact label={s==='saved'?'Saved':'Queued'}/>
              </div>
            </HCard>)}
        </div>
      </React.Fragment>)}
    </div>
  </div>);
}
window.HomeScreen = HomeScreen;
