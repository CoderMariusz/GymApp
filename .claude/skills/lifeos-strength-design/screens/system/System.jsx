const { Card:YCard, Button:YBtn, Icon:YIcon, Badge:YBadge, Chip:YChip, Banner:YBanner, Skeleton:YSk, SetRow:YSet, Stepper:YStep, SyncBadge:YSync, ScreenHeader:YHeader, BottomNav:YNav, RestTimer:YRest } = window.LifeOSStrengthDesignSystem_576cfb;

function FatalError(){
  return (<Screen><Bar/>
    <div style={{flex:1,display:'flex',flexDirection:'column',justifyContent:'center',padding:'0 24px 40px'}}>
      <span style={{width:56,height:56,borderRadius:'var(--radius-lg)',background:'var(--feedback-danger-quiet)',display:'inline-flex',alignItems:'center',justifyContent:'center',marginBottom:20}}>
        <YIcon name="triangle-alert" size={26} color="var(--feedback-danger)"/>
      </span>
      <h1 style={{margin:0,fontFamily:'var(--font-display)',fontSize:30,lineHeight:'34px',fontWeight:800,letterSpacing:'-.02em'}}>The app stopped unexpectedly</h1>
      <p style={{margin:'12px 0 0',fontSize:14,lineHeight:'21px',color:'var(--text-secondary)'}}>Your last workout is saved on this device, including the set you were entering. Nothing has been lost.</p>
      <div style={{marginTop:18,display:'flex',alignItems:'center',gap:8}}><YSync state="draft_local"/><span style={{fontSize:12,color:'var(--text-tertiary)'}}>1 workout on this device</span></div>
      <YBtn variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:24}}>Reload</YBtn>
      <YBtn variant="secondary" block iconLeft="copy" style={{marginTop:8}}>Copy error details</YBtn>
      <div style={{marginTop:20,fontFamily:'var(--font-numeric)',fontSize:11,lineHeight:'17px',color:'var(--text-tertiary)',textAlign:'center'}}>
        ERR-4C21 · build 214 · Jun 12, 2024 18:42<br/>Reported automatically. No workout data is sent.
      </div>
    </div>
  </Screen>);
}

function OfflineHistory(){
  const rows=[['Jun 12','Push · 6 exercises','12,450 kg'],['Jun 10','Pull · 5 exercises','10,980 kg'],['Jun 8','Legs · 5 exercises','16,240 kg'],['Jun 5','Push · 6 exercises','11,900 kg']];
  return (<Screen><Bar/>
    <YHeader title="History" right={<YSync state="queued" compact/>}/>
    <Scroll style={{paddingTop:4}}>
      <YBanner icon="wifi-off" title="Offline" description="Logging works as usual. Sessions older than what is stored here are unavailable until you reconnect."/>
      <Eyebrow>On this device</Eyebrow>
      <div style={{display:'flex',flexDirection:'column',gap:8}}>
        {rows.map(([d,t,v])=>
          <YCard key={d} interactive style={{display:'flex',alignItems:'center',gap:12}}>
            <span style={{flex:1}}>
              <span style={{display:'block',fontSize:14,fontWeight:800}}>{t}</span>
              <span style={{display:'block',fontSize:12,color:'var(--text-tertiary)',marginTop:2}}>{d}, 2024 · 45:12</span>
            </span>
            <span style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:14,fontWeight:700}}>{v}</span>
            <YIcon name="chevron-right" size={17} color="var(--text-tertiary)"/>
          </YCard>)}
      </div>
      <div style={{marginTop:14,padding:'12px 14px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)',fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)'}}>
        The last 30 sessions stay on this device. Volume, records and charts are calculated from them, so they work offline too.
      </div>
    </Scroll>
    <YNav active="history"/>
  </Screen>);
}

function OfflineWorkout(){
  return (<Screen><Bar/>
    <YHeader title="Bench Press" subtitle="Exercise 2 of 6" onBack={()=>{}} right={<YSync state="draft_local" compact/>}/>
    <Scroll style={{paddingTop:2}}>
      <YBanner icon="cloud-off" title="Saved on this device" description="No connection. Every set you confirm is stored here and uploads by itself later." style={{marginBottom:12}}/>
      <YSet index={1} weight="100" reps="8" rir="2" state="logged"/>
      <YSet index={2} weight="100" reps="6" rir="1" state="logged"/>
      <YSet index={3} weight="102.5" reps="6" rir="—" state="active"/>
      <YSet index={4} weight="102.5" reps="6" rir="—" state="proposed"/>
      <div style={{fontSize:11,color:'var(--text-tertiary)',margin:'10px 4px 0'}}>Nothing here waits for the network. The badge in the header says where the data is.</div>
    </Scroll>
    <div style={{flex:'0 0 auto',padding:'0 var(--gutter-mobile) 16px'}}>
      <YRest remaining="1:26" running nextLabel="Then" nextValue="Set 4 · 102.5 kg"/>
      <div style={{display:'flex',gap:8,marginTop:12}}>
        <YStep size="lg" value={102.5} step={2.5} unit="kg" style={{flex:1.4}}/>
        <YStep size="lg" value={6} step={1} unit="reps" style={{flex:1}}/>
      </div>
      <YBtn variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:10}}>Complete set</YBtn>
    </div>
  </Screen>);
}

function UpdateAvailable(){
  return (<Screen><Bar/>
    <YHeader title="History"/>
    <Scroll style={{paddingTop:4}}>
      <div style={{display:'flex',flexDirection:'column',gap:8}}>
        {[['Jun 12','Push · 6 exercises'],['Jun 10','Pull · 5 exercises'],['Jun 8','Legs · 5 exercises']].map(([d,t])=>
          <YCard key={d}><span style={{display:'block',fontSize:14,fontWeight:800}}>{t}</span><span style={{display:'block',fontSize:12,color:'var(--text-tertiary)',marginTop:2}}>{d}, 2024</span></YCard>)}
      </div>
    </Scroll>
    <Sheet height="52%">
      <div style={{padding:'12px 20px 20px',display:'flex',flexDirection:'column',height:'100%'}}>
        <span style={{width:44,height:44,borderRadius:'var(--radius-md)',background:'var(--feedback-info-quiet)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}>
          <YIcon name="download" size={22} color="var(--feedback-info)"/>
        </span>
        <h2 style={{margin:'16px 0 0',fontFamily:'var(--font-display)',fontSize:22,lineHeight:'26px',fontWeight:800,letterSpacing:'-.01em'}}>Version 1.0.1 is ready</h2>
        <p style={{margin:'10px 0 0',fontSize:14,lineHeight:'21px',color:'var(--text-secondary)'}}>Installing restarts the app. It takes about two seconds, and your queued workouts stay on this device.</p>
        <div style={{marginTop:14,display:'flex',flexDirection:'column',gap:6,fontSize:12,lineHeight:'18px',color:'var(--text-tertiary)'}}>
          <span>Faster history search</span>
          <span>Plate maths for 1.25 kg increments</span>
        </div>
        <div style={{marginTop:'auto',display:'flex',flexDirection:'column',gap:8}}>
          <YBtn variant="primary" size="lg" shape="pill" block uppercase>Install now</YBtn>
          <YBtn variant="ghost" block>Later</YBtn>
        </div>
      </div>
    </Sheet>
  </Screen>);
}

function UpdateDeferred(){
  return (<Screen><Bar/>
    <YHeader title="Bench Press" subtitle="Exercise 2 of 6" onBack={()=>{}} right={<YSync state="saved" compact/>}/>
    <Scroll style={{paddingTop:2}}>
      <YBanner tone="info" icon="download" title="Update installs after this workout" description="Version 1.0.1 is downloaded. It will not interrupt the session." action={<YBadge tone="neutral" size="sm">1.0.1</YBadge>} style={{marginBottom:12}}/>
      <YSet index={1} weight="100" reps="8" rir="2" state="logged"/>
      <YSet index={2} weight="100" reps="6" rir="1" state="logged"/>
      <YSet index={3} weight="102.5" reps="6" rir="—" state="active"/>
      <div style={{fontSize:11,color:'var(--text-tertiary)',margin:'10px 4px 0'}}>An update never interrupts an active workout, and never takes the primary action slot.</div>
    </Scroll>
    <div style={{flex:'0 0 auto',padding:'0 var(--gutter-mobile) 16px'}}>
      <YRest remaining="1:26" running nextLabel="Then" nextValue="Set 4 · 102.5 kg"/>
      <YBtn variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:12}}>Complete set</YBtn>
    </div>
  </Screen>);
}

function SkeletonHome(){
  return (<Screen><Bar/>
    <div style={{height:56,display:'flex',alignItems:'center',gap:12,padding:'0 var(--gutter-mobile)'}}>
      <YSk circle height={36}/>
      <div style={{flex:1}}><YSk width="46%" height={13}/><YSk width="28%" height={9} style={{marginTop:7}}/></div>
    </div>
    <Scroll style={{paddingTop:6}}>
      <YSk height={128} radius={18}/>
      <div style={{display:'flex',gap:12,marginTop:12}}>
        <YSk height={86} radius={18} style={{flex:1}}/>
        <YSk height={86} radius={18} style={{flex:1}}/>
      </div>
      <div style={{height:18}}/>
      <YSk width="34%" height={10}/>
      <div style={{display:'flex',flexDirection:'column',gap:8,marginTop:10}}>
        <YSk height={64} radius={18}/><YSk height={64} radius={18}/><YSk height={64} radius={18}/>
      </div>
      <div style={{marginTop:16,textAlign:'center',fontSize:11,color:'var(--text-tertiary)'}}>Cards keep their real heights, so nothing moves when the data lands.</div>
    </Scroll>
    <YNav active="home"/>
  </Screen>);
}

function SkeletonHistory(){
  return (<Screen><Bar/>
    <YHeader title="History"/>
    <Scroll style={{paddingTop:4}}>
      <div style={{display:'flex',gap:8,marginBottom:14}}>
        <YSk width={86} height={34} radius={999}/><YSk width={104} height={34} radius={999}/><YSk width={72} height={34} radius={999}/>
      </div>
      <div style={{display:'flex',flexDirection:'column',gap:8}}>
        {[0,1,2,3,4,5].map(i=>
          <div key={i} style={{padding:16,background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-lg)',display:'flex',alignItems:'center',gap:12}}>
            <div style={{flex:1}}><YSk width="52%" height={13}/><YSk width="34%" height={9} style={{marginTop:8}}/></div>
            <YSk width={62} height={13}/>
          </div>)}
      </div>
    </Scroll>
    <YNav active="history"/>
  </Screen>);
}

function SkeletonDetail(){
  return (<Screen><Bar/>
    <YHeader title="Bench Press" onBack={()=>{}}/>
    <Scroll style={{paddingTop:6}}>
      <div style={{display:'flex',alignItems:'center',gap:12,marginBottom:14}}>
        <YSk height={56} width={56} radius={14}/>
        <div style={{flex:1}}><YSk width="44%" height={12}/><YSk width="62%" height={9} style={{marginTop:8}}/></div>
      </div>
      <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8}}>
        <YSk height={56} radius={14}/><YSk height={56} radius={14}/><YSk height={56} radius={14}/><YSk height={56} radius={14}/>
      </div>
      <div style={{height:20}}/>
      <YSk width="30%" height={10}/>
      <div style={{marginTop:10,padding:16,background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-lg)'}}>
        <YSk width="38%" height={26}/>
        <YSk width="56%" height={9} style={{marginTop:8}}/>
        <YSk height={110} radius={12} style={{marginTop:14}}/>
      </div>
      <div style={{height:18}}/>
      <YSk width="26%" height={10}/>
      <div style={{marginTop:10,display:'flex',flexDirection:'column',gap:8}}><YSk height={40} radius={12}/><YSk height={40} radius={12}/><YSk height={40} radius={12}/></div>
    </Scroll>
  </Screen>);
}

Object.assign(window,{FatalError,OfflineHistory,OfflineWorkout,UpdateAvailable,UpdateDeferred,SkeletonHome,SkeletonHistory,SkeletonDetail});
