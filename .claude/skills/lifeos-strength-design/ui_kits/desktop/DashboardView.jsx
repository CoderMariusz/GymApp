const { Card: DCard, Button: DBtn, StatCard: DStat, WeekDots: DWeek, VolumeBars: DBars, SyncBadge: DSync, Icon: DIc, Banner: DBan, ExerciseRow: DRow, PRBadge: DPR } = window.LifeOSStrengthDesignSystem_576cfb;

function DashboardView({onStart}){
  return (<div style={{display:'flex',flexDirection:'column',gap:20}}>
    <div style={{display:'flex',alignItems:'flex-end',justifyContent:'space-between',gap:24}}>
      <h1 style={{fontFamily:'var(--font-display)',fontSize:46,lineHeight:'50px',fontWeight:700,letterSpacing:'-.02em',margin:0}}>
        Good morning,<br/><span style={{color:'var(--action-primary)'}}>Mariusz</span>
      </h1>
      <div style={{display:'flex',alignItems:'center',gap:12}}>
        <DSync state="queued"/>
        <DBtn variant="secondary" iconLeft="plus">Add exercise</DBtn>
      </div>
    </div>

    <div style={{display:'grid',gridTemplateColumns:'1.5fr 1fr',gap:20}}>
      <DCard pad="none" radius="xl" style={{position:'relative',overflow:'hidden',minHeight:260}}>
        <img src="../../assets/imagery/hero-dumbbell.png" alt="" style={{position:'absolute',inset:0,width:'100%',height:'100%',objectFit:'cover',objectPosition:'62% 22%'}}/>
        <div style={{position:'absolute',inset:0,background:'var(--scrim-side)'}}/>
        <div style={{position:'relative',padding:28,maxWidth:460}}>
          <div className="dlbl" style={{color:'var(--action-primary)'}}>Repeat last workout</div>
          <div style={{fontFamily:'var(--font-display)',fontSize:34,lineHeight:'38px',fontWeight:700,letterSpacing:'-.02em',marginTop:8}}>Push Day</div>
          <div style={{marginTop:8,fontSize:14,color:'var(--ink-200)'}}>6 exercises · 18 sets · ~45 min · last done 2 days ago</div>
          <div style={{display:'flex',gap:6,marginTop:16,flexWrap:'wrap'}}>
            {['Bench Press','Incline DB Press','Overhead Press','Lateral Raise','Triceps Pushdown','Dips'].map(n=>
              <span key={n} style={{fontSize:12,fontWeight:700,color:'var(--text-secondary)',background:'rgba(255,255,255,.06)',border:'1px solid var(--border-subtle)',borderRadius:999,padding:'5px 10px'}}>{n}</span>)}
          </div>
          <div style={{display:'flex',gap:10,marginTop:22}}>
            <DBtn variant="primary" size="lg" shape="pill" uppercase onClick={onStart}>Repeat workout</DBtn>
            <DBtn variant="secondary" size="lg" onClick={onStart}>Start empty</DBtn>
          </div>
          <div style={{marginTop:14,fontSize:12,color:'var(--text-tertiary)'}}>Values pre-fill from that session. No template is created.</div>
        </div>
      </DCard>

      <div style={{display:'flex',flexDirection:'column',gap:12}}>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:12}}>
          <DStat label="Volume" value="12,450" unit="kg" delta="+8%" footnote="vs last week" icon="trending-up"/>
          <DStat label="Workouts" value="4" footnote="This week" icon="calendar"/>
        </div>
        <DCard style={{flex:1}}>
          <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:16}}>
            <span style={{fontSize:15,fontWeight:800}}>Weekly progress</span>
            <span style={{fontSize:13,color:'var(--text-accent)',fontWeight:800}}>4 of 5 workouts</span>
          </div>
          <DWeek days={[{label:'M',done:true},{label:'T',done:true},{label:'W',done:true},{label:'T',done:true},{label:'F'},{label:'S'},{label:'S'}]}/>
          <DBars style={{marginTop:22}} height={80} data={[8,12,6,14,9,17,11,15,7,13,19,10]} labels={['4 weeks ago','This week']} highlightLast/>
        </DCard>
      </div>
    </div>

    <DBan icon="cloud-off" title="2 workouts waiting to sync" description="They are stored on this device. We'll send them when you're back online." onClick={()=>{}}/>

    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:20}}>
      <div>
        <div className="dlbl" style={{marginBottom:10}}>Recent activity</div>
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {[['Pull Day','May 10, 2024 · 48 min · 14 sets','saved'],['Legs','May 8, 2024 · 52 min · 16 sets','saved'],['Push Day','May 6, 2024 · 45 min · 18 sets','queued']].map(([n,m,s])=>
            <DRow key={n} name={n} meta={m} right={<DSync state={s} compact/>}/>)}
        </div>
      </div>
      <div>
        <div className="dlbl" style={{marginBottom:10}}>Personal records</div>
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {[['Bench Press','1RM · May 10, 2024','102.5 kg',true],['Back Squat','1RM · May 8, 2024','140.0 kg',false],['Deadlift','1RM · May 5, 2024','160.0 kg',false]].map(([n,m,v,fresh])=>
            <DRow key={n} name={n} meta={m} badge={fresh?<DPR label="New"/>:null}
              right={<span className="num" style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:17,fontWeight:700}}>{v}</span>}/>)}
        </div>
      </div>
    </div>
  </div>);
}
window.DashboardView = DashboardView;
