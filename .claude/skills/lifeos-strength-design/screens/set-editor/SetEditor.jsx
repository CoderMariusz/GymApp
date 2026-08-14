const { Card:ECard, Button:EBtn, Icon:EIcon, Chip:EChip, Badge:EBadge, Stepper:EStep, SetRow:ESet, RestTimer:ERest, SyncBadge:ESync, ScreenHeader:EHeader, IconButton:EIconBtn } = window.LifeOSStrengthDesignSystem_576cfb;

function Cols({labels}){
  return (<div style={{display:'flex',alignItems:'center',gap:8,padding:'0 10px 0 4px',margin:'2px 0 4px'}}>
    <span style={{width:34,textAlign:'center',fontSize:10,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>Set</span>
    {labels.map(l=><span key={l} style={{flex:1,textAlign:'center',fontSize:10,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>{l}</span>)}
    <span style={{width:32,flex:'0 0 auto'}}/>
  </div>);
}

function Docked({children}){
  return (<div style={{flex:'0 0 auto',position:'relative',padding:'0 var(--gutter-mobile) 16px'}}>
    <div style={{position:'absolute',left:0,right:0,top:-28,height:28,background:'linear-gradient(to top,var(--surface-base),rgba(0,0,0,0))',pointerEvents:'none'}}/>
    {children}
  </div>);
}

function Quick({items}){
  return (<div style={{display:'flex',gap:8,margin:'12px 0 10px',overflow:'hidden'}}>
    {items.map((t,i)=><EChip key={t} selected={i===0}>{t}</EChip>)}
  </div>);
}

function TrackNote({children}){
  return (<div style={{display:'flex',gap:8,marginTop:14,padding:'10px 12px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)',fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)'}}>
    <EIcon name="info" size={14} color="var(--text-tertiary)" style={{flex:'0 0 auto',marginTop:1}}/>
    <span>{children}</span>
  </div>);
}

function Head({title, meta, tracks}){
  return (<React.Fragment>
    <EHeader title={title} subtitle={meta} onBack={()=>{}} right={<ESync state="draft_local" compact/>}/>
    <div style={{padding:'0 var(--gutter-mobile)',marginTop:2,marginBottom:6}}>
      <EBadge tone="neutral" size="sm" icon="sliders-horizontal">Tracks: {tracks}</EBadge>
    </div>
  </React.Fragment>);
}

function EditorWeighted(){
  return (<Screen><Bar/>
    <Head title="Bench Press" meta="Exercise 2 of 6" tracks="weight · reps"/>
    <Scroll style={{paddingTop:2}}>
      <Cols labels={['kg','Reps','RIR']}/>
      <ESet index={1} warmup weight="60" reps="8" rir="—" state="logged"/>
      <ESet index={1} weight="100" reps="8" rir="2" state="logged"/>
      <ESet index={2} weight="100" reps="6" rir="1" state="logged"/>
      <ESet index={3} weight="102.5" reps="6" rir="—" state="active"/>
      <ESet index={4} weight="102.5" reps="6" rir="—" state="proposed"/>
      <div style={{fontSize:11,color:'var(--text-tertiary)',margin:'10px 4px 0'}}>Last time: 100 kg × 8, 5 days ago. Grey rows are proposals, not records.</div>
      <TrackNote>Weight and reps: the default layout. The other three come from what the exercise tracks.</TrackNote>
    </Scroll>
    <Docked>
      <ERest remaining="1:26" running nextLabel="Then" nextValue="Set 4 · 102.5 kg"/>
      <Quick items={['100 kg','102.5','105','+2.5']}/>
      <div style={{display:'flex',gap:8}}>
        <EStep size="lg" value={102.5} step={2.5} unit="kg" style={{flex:1.4}}/>
        <EStep size="lg" value={6} step={1} unit="reps" style={{flex:1}}/>
      </div>
      <EBtn variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:10}}>Complete set</EBtn>
    </Docked>
  </Screen>);
}

function EditorBodyweight(){
  return (<Screen><Bar/>
    <Head title="Pull-up" meta="Exercise 3 of 6" tracks="reps · added weight"/>
    <Scroll style={{paddingTop:2}}>
      <Cols labels={['Reps','Added','RIR']}/>
      <ESet index={1} warmup weight="10" reps="Body" rir="—" state="logged"/>
      <ESet index={1} weight="10" reps="Body" rir="2" state="logged"/>
      <ESet index={2} weight="8" reps="+5 kg" rir="1" state="logged"/>
      <ESet index={3} weight="8" reps="+5 kg" rir="—" state="active"/>
      <ESet index={4} weight="6" reps="+5 kg" rir="—" state="proposed"/>
      <div style={{fontSize:11,color:'var(--text-tertiary)',margin:'10px 4px 0'}}>Reps lead. Added weight is optional and reads "Body" when there is none.</div>
      <TrackNote>Volume counts your body weight at 78 kg plus anything added. Change your body weight in Account — past sets keep the value they were logged with.</TrackNote>
    </Scroll>
    <Docked>
      <ERest remaining="2:10" running nextLabel="Then" nextValue="Set 4 · 6 reps"/>
      <Quick items={['Body','+5 kg','+10 kg','Assisted −20']}/>
      <div style={{display:'flex',gap:8}}>
        <EStep size="lg" value={8} step={1} unit="reps" style={{flex:1.2}}/>
        <EStep size="lg" value={5} step={2.5} unit="added kg" style={{flex:1.2}}/>
      </div>
      <EBtn variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:10}}>Complete set</EBtn>
    </Docked>
  </Screen>);
}

function EditorTimed({running}){
  return (<Screen><Bar/>
    <Head title="Plank" meta="Exercise 5 of 6" tracks="duration · load"/>
    <Scroll style={{paddingTop:2}}>
      <Cols labels={['Time','Load']}/>
      <ESet index={1} weight="0:45" reps="Body" state="logged"/>
      <ESet index={2} weight="1:00" reps="Body" state="logged"/>
      <ESet index={3} weight="1:00" reps="+10 kg" state={running?'active':'active'}/>
      <ESet index={4} weight="1:00" reps="+10 kg" state="proposed"/>
      <div style={{fontSize:11,color:'var(--text-tertiary)',margin:'10px 4px 0'}}>Time replaces reps. Load is optional.</div>
      <TrackNote>Timing runs in the app so you do not have to watch a clock and a phone. The set is recorded when you stop, and you can still correct the value by hand.</TrackNote>
    </Scroll>
    <Docked>
      {running
        ? <ECard tone="accent" style={{display:'flex',alignItems:'center',gap:14}}>
            <span style={{flex:1}}>
              <span style={{display:'block',fontSize:10,letterSpacing:'.1em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>Timing set 3</span>
              <span className="num" style={{display:'block',fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:44,lineHeight:'46px',fontWeight:700,letterSpacing:'-.02em',color:'var(--text-accent)'}}>0:47</span>
            </span>
            <EIconBtn icon="pause" label="Pause the set timer" variant="filled" size={52} iconSize={22}/>
          </ECard>
        : <ERest remaining="1:30" running={false} nextLabel="Then" nextValue="Set 4 · 1:00"/>}
      <Quick items={running?['Stop at 1:00','Keep going','Discard']:['1:00','0:45','1:30','2:00']}/>
      <div style={{display:'flex',gap:8}}>
        <EStep size="lg" value={running?'0:47':'1:00'} step={15} unit="mm:ss" style={{flex:1.4}}/>
        <EStep size="lg" value={10} step={2.5} unit="load kg" style={{flex:1}}/>
      </div>
      <EBtn variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:10}}>{running?'Stop and log':'Start the set'}</EBtn>
    </Docked>
  </Screen>);
}

function EditorDistance(){
  return (<Screen><Bar/>
    <Head title="Farmer Carry" meta="Exercise 6 of 6" tracks="distance · duration"/>
    <Scroll style={{paddingTop:2}}>
      <Cols labels={['Dist','Time','Pace']}/>
      <ESet index={1} weight="40 m" reps="0:38" rir="1:35" state="logged"/>
      <ESet index={2} weight="40 m" reps="0:35" rir="1:28" state="logged"/>
      <ESet index={3} weight="40 m" reps="0:35" rir="1:28" state="active"/>
      <ESet index={4} weight="40 m" reps="0:35" rir="—" state="proposed"/>
      <div style={{fontSize:11,color:'var(--text-tertiary)',margin:'10px 4px 0'}}>Pace is calculated, never typed. It is shown per 100 m.</div>
      <TrackNote>Distance and duration replace weight and reps. Load carried is part of the exercise, not the set — it lives on the exercise, with the plates you used.</TrackNote>
    </Scroll>
    <Docked>
      <ERest remaining="1:45" running nextLabel="Then" nextValue="Set 4 · 40 m"/>
      <Quick items={['40 m','20 m','60 m','+10 m']}/>
      <div style={{display:'flex',gap:8}}>
        <EStep size="lg" value={40} step={5} unit="m" style={{flex:1}}/>
        <EStep size="lg" value={'0:35'} step={5} unit="mm:ss" style={{flex:1}}/>
      </div>
      <div style={{display:'flex',alignItems:'center',gap:8,marginTop:8,padding:'8px 12px',background:'var(--surface-inset)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)'}}>
        <EIcon name="trending-up" size={14} color="var(--text-tertiary)"/>
        <span style={{fontSize:11,letterSpacing:'.06em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>Pace</span>
        <span style={{marginLeft:'auto',fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:15,fontWeight:700}}>1:28 / 100 m</span>
      </div>
      <EBtn variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:10}}>Complete set</EBtn>
    </Docked>
  </Screen>);
}

Object.assign(window,{EditorWeighted,EditorBodyweight,EditorTimed,EditorDistance});
