const D = window.LifeOSStrengthDesignSystem_576cfb;
const { Card:GCard, Button:GBtn, IconButton:GIconBtn, Icon:GIcon, Chip:GChip, Input:GInput, Select:GSelect, Badge:GBadge, PRBadge:GPR, SyncBadge:GSync, ExerciseRow:GRow, SetRow:GSetRow, ConfirmDialog:GConfirm, TrendChart:GTrend, VolumeBars:GBars, SegmentedControl:GSeg, EmptyState:GEmpty } = D;

const NAV=[['home','Home','house'],['workout','Workout','dumbbell'],['exercises','Exercises','list'],['history','History','history'],['progress','Progress','chart-column']];

function Shell({active, children}){
  return (<div style={{display:'flex',height:'100%'}}>
    <aside style={{width:248,flex:'0 0 auto',padding:'24px 16px',borderRight:'1px solid var(--border-subtle)',display:'flex',flexDirection:'column',gap:24,background:'var(--surface-sunken)'}}>
      <div style={{fontFamily:'var(--font-display)',fontSize:24,fontWeight:800,letterSpacing:'-.03em',padding:'0 8px'}}>LifeOS<span style={{color:'var(--action-primary)'}}>.</span></div>
      <nav style={{display:'flex',flexDirection:'column',gap:2}}>
        {NAV.map(([k,label,icon])=>{const on=k===active;return (
          <div key={k} style={{display:'flex',alignItems:'center',gap:12,minHeight:44,padding:'0 12px',background:on?'var(--set-active-bg)':'transparent',border:'1px solid '+(on?'var(--border-accent)':'transparent'),borderRadius:'var(--radius-md)',color:on?'var(--text-accent)':'var(--text-secondary)',fontSize:14,fontWeight:on?800:600}}>
            <GIcon name={icon} size={19}/>{label}</div>);})}
      </nav>
      <GBtn variant="primary" block iconLeft="plus">Start workout</GBtn>
      <div style={{marginTop:'auto',display:'flex',flexDirection:'column',gap:12}}>
        <GSync state="saved"/>
        <div style={{display:'flex',alignItems:'center',gap:10,minHeight:44,padding:'0 8px',color:'var(--text-secondary)',fontSize:13,fontWeight:700}}>
          <span style={{width:32,height:32,borderRadius:999,background:'var(--surface-raised)',border:'1px solid var(--border-default)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><GIcon name="user" size={16} color="var(--text-tertiary)"/></span>
          Mariusz<GIcon name="settings" size={16} style={{marginLeft:'auto'}}/>
        </div>
      </div>
    </aside>
    <main style={{flex:1,minWidth:0,padding:'28px 32px',overflow:'hidden'}}>
      <div style={{maxWidth:1160,margin:'0 auto',height:'100%'}}>{children}</div>
    </main>
  </div>);
}

const H1=({children})=><h1 style={{fontFamily:'var(--font-display)',fontSize:46,lineHeight:'50px',fontWeight:700,letterSpacing:'-.02em',margin:0}}>{children}</h1>;
const Lbl=({children})=><div style={{fontSize:11,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>{children}</div>;

/* History: master list left, selected workout right */
function HistoryDesktop({confirming}){
  const rows=[['Push Day','Today','45:12 · 18 sets · 12,450 kg','queued',true],['Pull Day','May 10, 2024','48:04 · 14 sets · 10,980 kg','saved',false],['Legs','May 8, 2024','52:20 · 16 sets · 18,300 kg','saved',true],['Push Day','May 6, 2024','45:40 · 18 sets · 11,900 kg','saved',false],['Pull Day','May 3, 2024','44:12 · 14 sets · 10,240 kg','saved',false]];
  const sets=[{w:60,r:10,rpe:'—',warmup:true},{w:100,r:8,rpe:8},{w:100,r:6,rpe:8.5},{w:105,r:4,rpe:9}];
  return (<Shell active="history">
    <div style={{display:'flex',alignItems:'flex-end',justifyContent:'space-between',marginBottom:20}}>
      <H1>History</H1>
      <div style={{display:'flex',gap:10,alignItems:'center'}}>
        <GInput icon="search" placeholder="Search workouts" style={{width:260}}/>
        <GSelect value="Bench Press" options={['All exercises','Bench Press','Back Squat','Deadlift']} style={{width:190}}/>
        <GSelect value="Last 3 months" options={['Last 30 days','Last 3 months','This year']} style={{width:180}}/>
      </div>
    </div>
    <div style={{display:'grid',gridTemplateColumns:'440px 1fr',gap:20,alignItems:'start'}}>
      <div>
        <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:10}}>
          <Lbl>3 workouts contain Bench Press</Lbl>
          <span style={{fontSize:12,fontWeight:800,color:'var(--text-accent)'}}>Clear filters</span>
        </div>
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {rows.map(([n,d,m,s,pr],i)=>
            <GCard key={i} pad="tight" tone={i===0?'accent':'default'} interactive>
              <div style={{display:'flex',alignItems:'center',gap:12}}>
                <span style={{width:44,height:44,flex:'0 0 auto',borderRadius:'var(--radius-md)',background:'var(--surface-inset)',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center'}}>
                  <span style={{fontFamily:'var(--font-numeric)',fontSize:15,fontWeight:700,lineHeight:1}}>{d==='Today'?'12':d.split(' ')[1].replace(',','')}</span>
                  <span style={{fontSize:9,letterSpacing:'.06em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700,marginTop:2}}>{d==='Today'?'Aug':d.split(' ')[0]}</span>
                </span>
                <span style={{flex:1,minWidth:0}}>
                  <span style={{display:'flex',alignItems:'center',gap:8}}><span style={{fontSize:15,fontWeight:800}}>{n}</span>{pr&&<GPR/>}</span>
                  <span style={{display:'block',fontSize:12,color:'var(--text-tertiary)',marginTop:3}}>{m}</span>
                </span>
                <GSync state={s} compact label={s==='saved'?'Saved':'Queued'}/>
              </div>
            </GCard>)}
        </div>
      </div>
      <div style={{display:'flex',flexDirection:'column',gap:12}}>
        <GCard pad="loose">
          <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between'}}>
            <div>
              <div style={{fontFamily:'var(--font-display)',fontSize:26,fontWeight:700}}>Push Day</div>
              <div style={{fontSize:13,color:'var(--text-tertiary)',marginTop:3}}>Today · 09:41 – 10:26</div>
            </div>
            <div style={{display:'flex',gap:8,alignItems:'center'}}>
              <GSync state="queued"/>
              <GBtn variant="secondary" size="sm" iconLeft="pencil">Edit</GBtn>
              <GBtn variant="ghost" size="sm" iconLeft="trash-2" style={{color:'var(--feedback-danger)'}}>Delete</GBtn>
            </div>
          </div>
          <div style={{display:'flex',gap:32,marginTop:20}}>
            {[['45:12','Duration'],['18','Working sets'],['12,450','Volume kg'],['1','New records']].map(([v,l])=>
              <div key={l}><div style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:26,fontWeight:700,letterSpacing:'-.02em'}}>{v}</div><Lbl>{l}</Lbl></div>)}
          </div>
        </GCard>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:12}}>
          <GCard pad="tight">
            <div style={{display:'flex',alignItems:'center',gap:8,padding:'2px 6px 10px'}}><span style={{flex:1,fontSize:15,fontWeight:800}}>Bench Press</span><GPR detail="+2.5 kg"/></div>
            <div style={{display:'flex',gap:8,padding:'0 10px 6px 4px',fontSize:10,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>
              <span style={{width:34,textAlign:'center'}}>Set</span><span style={{flex:1,textAlign:'center'}}>Kg</span><span style={{flex:1,textAlign:'center'}}>Reps</span><span style={{flex:1,textAlign:'center'}}>RPE</span><span style={{width:32}}/>
            </div>
            {sets.map((s,i)=><GSetRow key={i} index={sets.slice(0,i+1).filter(x=>!x.warmup).length} weight={s.w} reps={s.r} rir={s.rpe} warmup={s.warmup} state="logged"/>)}
          </GCard>
          <GCard pad="tight">
            <div style={{display:'flex',alignItems:'center',gap:8,padding:'2px 6px 10px'}}><span style={{flex:1,fontSize:15,fontWeight:800}}>Incline Dumbbell Press</span><span style={{fontSize:12,color:'var(--text-tertiary)'}}>2 sets</span></div>
            <div style={{display:'flex',gap:8,padding:'0 10px 6px 4px',fontSize:10,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>
              <span style={{width:34,textAlign:'center'}}>Set</span><span style={{flex:1,textAlign:'center'}}>Kg</span><span style={{flex:1,textAlign:'center'}}>Reps</span><span style={{flex:1,textAlign:'center'}}>RPE</span><span style={{width:32}}/>
            </div>
            <GSetRow index={1} weight={24} reps={10} rir={8} state="logged"/>
            <GSetRow index={2} weight={26} reps={8} rir={8.5} state="logged"/>
          </GCard>
        </div>
        <GCard>
          <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:12}}>
            <Lbl>Bench Press · estimated 1RM over time</Lbl>
            <GBadge tone="accent">+12.5 kg</GBadge>
          </div>
          <GTrend height={120} data={[62,68,66,74,80,86,90,88,94,96,100,102.5]} yTicks={[120,100,80,60]} xLabels={['Apr 12','May 10','Jun 7']}/>
        </GCard>
      </div>
    </div>
    {confirming && <div style={{position:'absolute',inset:0,display:'flex',alignItems:'center',justifyContent:'center',background:'rgba(4,6,10,.72)',backdropFilter:'var(--blur-overlay)'}}>
      <GConfirm title="Delete this workout?" description="18 sets and 12,450 kg of volume from Push Day will be removed."
        recovery="The Bench Press record set here is recalculated from your remaining history. This cannot be undone." confirmLabel="Delete workout"/>
    </div>}
  </Shell>);
}

/* Catalog: list left, detail right + custom editor variant */
function CatalogDesktop({editor, invalid}){
  const rows=[['Bench Press','Barbell · Chest'],['Incline Dumbbell Press','Dumbbell · Chest'],['Overhead Press','Barbell · Shoulders'],['Barbell Row','Barbell · Back'],['Pull-up','Bodyweight · Back'],['Back Squat','Barbell · Legs'],['Romanian Deadlift','Barbell · Legs'],['Farmer Carry','Dumbbell · Carry']];
  return (<Shell active="exercises">
    <div style={{display:'flex',alignItems:'flex-end',justifyContent:'space-between',marginBottom:20}}>
      <H1>Exercises</H1>
      <GBtn variant="secondary" iconLeft="plus">New custom exercise</GBtn>
    </div>
    <div style={{display:'grid',gridTemplateColumns:'400px 1fr',gap:20,alignItems:'start'}}>
      <div>
        <GInput icon="search" placeholder="Search 214 exercises"/>
        <div style={{display:'flex',gap:8,margin:'12px 0'}}>
          {['All','Barbell','Dumbbell','Custom'].map((c,i)=><GChip key={c} selected={i===0}>{c}</GChip>)}
        </div>
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {rows.map(([n,m],i)=>
            <GCard key={n} pad="tight" tone={(editor?n==='Farmer Carry':i===0)?'accent':'default'} interactive>
              <div style={{display:'flex',alignItems:'center',gap:12}}>
                <span style={{width:36,height:36,borderRadius:'var(--radius-md)',background:'var(--surface-inset)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><GIcon name="dumbbell" size={17} color="var(--text-secondary)"/></span>
                <span style={{flex:1}}><span style={{display:'block',fontSize:14,fontWeight:800}}>{n}</span><span style={{display:'block',fontSize:12,color:'var(--text-tertiary)',marginTop:2}}>{m}</span></span>
                {n==='Farmer Carry' && <GBadge tone="neutral" size="sm">Custom</GBadge>}
              </div>
            </GCard>)}
        </div>
      </div>

      {editor ? (
        <GCard pad="loose">
          <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:20}}>
            <div style={{fontFamily:'var(--font-display)',fontSize:26,fontWeight:700}}>Edit custom exercise</div>
            <div style={{display:'flex',gap:8}}><GBtn variant="ghost" size="sm">Cancel</GBtn><GBtn variant="primary" size="sm" disabled={invalid}>Save</GBtn></div>
          </div>
          <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:16}}>
            <GInput label="Name" defaultValue={invalid?'':'Farmer Carry'} error={invalid?'A name is required':undefined}/>
            <GSelect label="Equipment" value="Dumbbell" options={['Barbell','Dumbbell','Machine','Cable','Bodyweight']}/>
            <GSelect label="Movement pattern" value="Carry" options={['Push horizontal','Pull horizontal','Squat','Hinge','Carry','Isolation']}/>
            <GSelect label="Difficulty" value="Intermediate" options={['Beginner','Intermediate','Advanced']}/>
          </div>
          <div style={{marginTop:20}}>
            <Lbl>What this exercise tracks</Lbl>
            <div style={{display:'flex',gap:8,marginTop:10}}><GChip>Weight</GChip><GChip>Reps</GChip><GChip selected>Distance</GChip><GChip selected>Duration</GChip></div>
            {invalid && <div style={{display:'flex',alignItems:'center',gap:6,marginTop:10,fontSize:12,color:'var(--feedback-danger)'}}><GIcon name="circle-alert" size={13}/> Pick at least one value to track</div>}
            <div style={{fontSize:12,color:'var(--text-tertiary)',marginTop:10}}>This decides the set editor layout: distance and duration replace the weight and reps columns.</div>
          </div>
          <div style={{marginTop:20}}>
            <Lbl>Default rest</Lbl>
            <div style={{display:'flex',gap:8,marginTop:10}}><GChip>0:60</GChip><GChip selected>1:30</GChip><GChip>2:00</GChip><GChip>3:00</GChip></div>
          </div>
          <div style={{marginTop:28,paddingTop:20,borderTop:'1px solid var(--border-subtle)',display:'flex',alignItems:'center',justifyContent:'space-between'}}>
            <div style={{fontSize:12,color:'var(--text-tertiary)',maxWidth:420,lineHeight:'17px'}}>Deleting keeps the sets inside logged workouts, but removes the exercise from the catalog and its progress chart.</div>
            <GBtn variant="ghost" size="sm" iconLeft="trash-2" style={{color:'var(--feedback-danger)'}}>Delete exercise</GBtn>
          </div>
        </GCard>
      ) : (
        <div style={{display:'flex',flexDirection:'column',gap:12}}>
          <GCard pad="loose">
            <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between'}}>
              <div style={{display:'flex',gap:16,alignItems:'center'}}>
                <span style={{width:64,height:64,borderRadius:'var(--radius-lg)',background:'var(--surface-inset)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><GIcon name="dumbbell" size={30} color="var(--text-secondary)"/></span>
                <div>
                  <div style={{fontFamily:'var(--font-display)',fontSize:30,fontWeight:700,letterSpacing:'-.02em'}}>Bench Press</div>
                  <div style={{display:'flex',gap:6,marginTop:8}}>
                    <GBadge tone="neutral" size="sm">Barbell</GBadge><GBadge tone="neutral" size="sm">Chest</GBadge><GBadge tone="neutral" size="sm">Push horizontal</GBadge><GBadge tone="neutral" size="sm">Compound</GBadge>
                  </div>
                </div>
              </div>
              <GBtn variant="primary" iconLeft="plus">Add to workout</GBtn>
            </div>
          </GCard>
          <div style={{display:'grid',gridTemplateColumns:'1.4fr 1fr',gap:12}}>
            <GCard pad="loose">
              <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between'}}>
                <div>
                  <Lbl>Estimated 1RM</Lbl>
                  <div style={{display:'flex',alignItems:'baseline',gap:8,marginTop:6}}>
                    <span style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:44,lineHeight:'44px',fontWeight:700,letterSpacing:'-.02em'}}>102.5</span>
                    <span style={{fontSize:15,color:'var(--text-tertiary)',fontWeight:700}}>kg</span>
                    <GBadge tone="accent">+12.5 kg</GBadge>
                  </div>
                </div>
                <GPR label="Record" detail="105 kg × 4, Jun 7"/>
              </div>
              <GTrend style={{marginTop:20}} height={170} data={[62,68,66,74,80,86,90,88,94,96,100,102.5]} yTicks={[120,100,80,60]} xLabels={['Apr 12','Apr 26','May 10','May 24','Jun 7']}/>
            </GCard>
            <GCard pad="loose">
              <Lbl>Last time · Jun 7, 5 days ago</Lbl>
              <div style={{marginTop:12}}>
                {[['1','100 kg × 8','RPE 8'],['2','100 kg × 6','RPE 8.5'],['3','105 kg × 4','RPE 9']].map(([n,v,r])=>
                  <div key={n} style={{display:'flex',alignItems:'center',gap:10,minHeight:40,borderBottom:'1px solid var(--border-subtle)'}}>
                    <span style={{width:22,fontFamily:'var(--font-numeric)',fontSize:13,color:'var(--text-tertiary)',fontWeight:700}}>{n}</span>
                    <span style={{flex:1,fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:15,fontWeight:700}}>{v}</span>
                    <span style={{fontSize:12,color:'var(--text-tertiary)'}}>{r}</span>
                  </div>)}
              </div>
              <div style={{marginTop:16}}><Lbl>Sessions logged</Lbl><div style={{fontFamily:'var(--font-numeric)',fontSize:22,fontWeight:700,marginTop:4}}>24</div></div>
            </GCard>
          </div>
        </div>
      )}
    </div>
  </Shell>);
}

/* Selector as a centred modal over the workout */
function SelectorDesktop({noresults}){
  return (<Shell active="workout">
    <div style={{opacity:.35,pointerEvents:'none'}}>
      <H1>Push Day</H1>
      <div style={{marginTop:20,display:'grid',gridTemplateColumns:'1fr 372px',gap:24}}>
        <GCard pad="default"><div style={{fontSize:18,fontWeight:800,marginBottom:10}}>Bench Press</div>
          <GSetRow index={1} weight={100} reps={8} rir={8} state="logged"/><GSetRow index={2} weight={105} reps={4} rir={9} state="active"/></GCard>
        <GCard pad="loose"><Lbl>Current set</Lbl></GCard>
      </div>
    </div>
    <div style={{position:'absolute',inset:0,display:'flex',alignItems:'center',justifyContent:'center',background:'rgba(4,6,10,.72)',backdropFilter:'var(--blur-overlay)'}}>
      <div style={{width:720,maxHeight:640,display:'flex',flexDirection:'column',background:'var(--surface-card)',border:'1px solid var(--border-default)',borderRadius:'var(--radius-xl)',boxShadow:'var(--shadow-float)',overflow:'hidden'}}>
        <div style={{padding:'20px 24px 16px',borderBottom:'1px solid var(--border-subtle)'}}>
          <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:14}}>
            <span style={{fontFamily:'var(--font-display)',fontSize:22,fontWeight:700}}>Add exercise</span>
            <GIconBtn icon="x" label="Close"/>
          </div>
          <GInput icon="search" placeholder="Search 214 exercises" defaultValue={noresults?'benhc press':''}/>
          <div style={{display:'flex',gap:8,marginTop:12}}>
            {['All','Barbell','Dumbbell','Bodyweight','Custom'].map((c,i)=><GChip key={c} selected={i===0}>{c}</GChip>)}
          </div>
        </div>
        <div style={{flex:1,overflowY:'auto',padding:'16px 24px 24px'}}>
          {noresults ? <GEmpty icon="search-x" title="No exercises found"
              description={'Nothing matches "benhc press". Check the spelling, or create it as a custom exercise.'}
              action={<GBtn variant="secondary" iconLeft="plus">Create "benhc press"</GBtn>}/>
            : (<React.Fragment>
            <Lbl>Recent</Lbl>
            <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8,margin:'10px 0 18px'}}>
              {[['Bench Press','last: 100 kg × 8'],['Incline Dumbbell Press','last: 26 kg × 8'],['Overhead Press','last: 55 kg × 6'],['Barbell Row','last: 90 kg × 8']].map(([n,m])=>
                <GRow key={n} name={n} meta={m} right={<GIcon name="plus" size={19} color="var(--action-primary)"/>}/>)}
            </div>
            <Lbl>Most used</Lbl>
            <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8,marginTop:10}}>
              {[['Back Squat','42 sessions'],['Deadlift','31 sessions'],['Pull-up','28 sessions'],['Farmer Carry','12 sessions']].map(([n,m])=>
                <GRow key={n} name={n} meta={m} right={<GIcon name="plus" size={19} color="var(--action-primary)"/>}/>)}
            </div>
          </React.Fragment>)}
        </div>
      </div>
    </div>
  </Shell>);
}

/* Auth on desktop: split hero / form */
function AuthDesktop({stage='signup'}){
  return (<div style={{display:'flex',height:'100%'}}>
    <div style={{flex:'1 1 58%',position:'relative'}}>
      <img src="../../assets/imagery/hero-dumbbell.png" alt="" style={{width:'100%',height:'100%',objectFit:'cover',objectPosition:'58% 24%'}}/>
      <div style={{position:'absolute',inset:0,background:'var(--scrim-side)'}}/>
      <div style={{position:'absolute',left:56,bottom:56,maxWidth:420}}>
        <div style={{fontFamily:'var(--font-display)',fontSize:40,fontWeight:800,letterSpacing:'-.03em',color:'#fff'}}>LifeOS<span style={{color:'var(--action-primary)'}}>.</span></div>
        <div style={{marginTop:12,fontSize:16,lineHeight:'23px',color:'var(--ink-200)'}}>A fast, trustworthy ledger for the gym. Your sets save on the device first, then to the server.</div>
      </div>
    </div>
    <div style={{flex:'0 0 480px',padding:'56px 56px',display:'flex',flexDirection:'column',justifyContent:'center',background:'var(--surface-base)',borderLeft:'1px solid var(--border-subtle)'}}>
      {stage==='signup' ? (<React.Fragment>
        <div style={{fontFamily:'var(--font-display)',fontSize:30,fontWeight:700,letterSpacing:'-.02em'}}>Create your account</div>
        <div style={{marginTop:8,fontSize:14,color:'var(--text-secondary)',lineHeight:'20px'}}>Email and password only. Google and Apple sign-in arrive in v1.0.1.</div>
        <div style={{display:'flex',flexDirection:'column',gap:16,marginTop:28}}>
          <GInput label="Email" icon="mail" defaultValue="marek@example.com"/>
          <GInput label="Password" icon="lock" type="password" defaultValue="trening123" hint="At least 8 characters"/>
          <GBtn variant="primary" size="lg" block uppercase>Create account</GBtn>
          <div style={{fontSize:12,color:'var(--text-tertiary)',lineHeight:'17px'}}>You can export or delete everything at any time.</div>
          <div style={{fontSize:13,color:'var(--text-tertiary)'}}>Already have an account? <a href="#" onClick={(e)=>e.preventDefault()}>Sign in</a></div>
        </div>
      </React.Fragment>) : (<React.Fragment>
        <div style={{fontFamily:'var(--font-display)',fontSize:30,fontWeight:700,letterSpacing:'-.02em'}}>This link has expired</div>
        <div style={{marginTop:8,fontSize:14,color:'var(--text-secondary)',lineHeight:'20px'}}>Reset links last 60 minutes. Request a new one and it will work straight away.</div>
        <GCard style={{marginTop:24}}>
          <div style={{display:'flex',gap:12,alignItems:'flex-start'}}>
            <span style={{width:36,height:36,flex:'0 0 auto',borderRadius:999,background:'var(--feedback-warning-quiet)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><GIcon name="link-2-off" size={18} color="var(--feedback-warning)"/></span>
            <div><div style={{fontSize:14,fontWeight:800}}>Nothing was changed</div>
            <div style={{fontSize:12,color:'var(--text-tertiary)',marginTop:3,lineHeight:'17px'}}>Your current password still works and your workouts are untouched.</div></div>
          </div>
        </GCard>
        <GBtn variant="primary" size="lg" block uppercase style={{marginTop:20}}>Request a new link</GBtn>
        <GBtn variant="ghost" block style={{marginTop:8}}>Back to sign in</GBtn>
      </React.Fragment>)}
    </div>
  </div>);
}
Object.assign(window,{HistoryDesktop,CatalogDesktop,SelectorDesktop,AuthDesktop,Shell});
