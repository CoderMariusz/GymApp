const { Card:HsCard, Button:HsBtn, IconButton:HsIconBtn, Icon:HsIcon, Chip:HsChip, Input:HsInput, Select:HsSelect, Badge:HsBadge, PRBadge:HsPR, SyncBadge:HsSync, ScreenHeader:HsHeader, SetRow:HsSetRow, EmptyState:HsEmpty, ConfirmDialog:HsConfirm, TrendChart:HsTrend, VolumeBars:HsBars, ExerciseRow:HsRow, SegmentedControl:HsSeg } = window.LifeOSStrengthDesignSystem_576cfb;

const SESSIONS=[
  {name:'Push Day',date:'Today',meta:'45:12 · 18 sets · 12,450 kg',sync:'queued',pr:1},
  {name:'Pull Day',date:'May 10, 2024',meta:'48:04 · 14 sets · 10,980 kg',sync:'saved'},
  {name:'Legs',date:'May 8, 2024',meta:'52:20 · 16 sets · 18,300 kg',sync:'saved',pr:1},
  {name:'Push Day',date:'May 6, 2024',meta:'45:40 · 18 sets · 11,900 kg',sync:'saved'},
  {name:'Pull Day',date:'May 3, 2024',meta:'44:12 · 14 sets · 10,240 kg',sync:'saved'},
];

function SessionCard({s, onClick}){
  return (<HsCard pad="tight" interactive onClick={onClick} style={{marginBottom:8}}>
    <div style={{display:'flex',alignItems:'center',gap:12}}>
      <span style={{width:44,height:44,flex:'0 0 auto',borderRadius:'var(--radius-md)',background:'var(--surface-inset)',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center'}}>
        <span style={{fontFamily:'var(--font-numeric)',fontSize:15,fontWeight:700,lineHeight:1}}>{s.date==='Today'?'12':s.date.split(' ')[1].replace(',','')}</span>
        <span style={{fontSize:9,letterSpacing:'.06em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700,marginTop:2}}>{s.date==='Today'?'Aug':s.date.split(' ')[0]}</span>
      </span>
      <span style={{flex:1,minWidth:0}}>
        <span style={{display:'flex',alignItems:'center',gap:8}}>
          <span style={{fontSize:15,fontWeight:800}}>{s.name}</span>
          {s.pr && <HsPR/>}
        </span>
        <span style={{display:'block',fontSize:12,color:'var(--text-tertiary)',marginTop:3}}>{s.meta}</span>
      </span>
      <HsSync state={s.sync} compact label={s.sync==='saved'?'Saved':'Queued'}/>
    </div>
  </HsCard>);
}

function HistoryList({filtered}){
  return (<Screen><Bar/>
    <HsHeader title="History" right={<HsIconBtn icon="sliders-horizontal" label="Filter"/>}/>
    <div style={{padding:'4px var(--gutter-mobile) 0',flex:'0 0 auto'}}>
      <HsInput icon="search" placeholder="Search workouts"/>
      <div style={{display:'flex',gap:8,marginTop:12,overflowX:'auto',paddingBottom:4}}>
        <HsChip selected={!filtered} icon={filtered?undefined:'check'}>All</HsChip>
        <HsChip selected={filtered} icon={filtered?'x':undefined}>Bench Press</HsChip>
        <HsChip>Last 30 days</HsChip>
        <HsChip>With records</HsChip>
      </div>
    </div>
    <Scroll style={{paddingTop:14}}>
      {filtered && <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:12}}>
        <span style={{fontSize:12,color:'var(--text-secondary)'}}>3 workouts contain <strong style={{color:'var(--text-primary)'}}>Bench Press</strong></span>
        <span style={{fontSize:12,fontWeight:800,color:'var(--text-accent)'}}>Clear</span>
      </div>}
      {(filtered?SESSIONS.filter(s=>s.name==='Push Day'):SESSIONS).map((s,i)=><SessionCard key={i} s={s}/>)}
      {!filtered && <React.Fragment>
        <Eyebrow>April</Eyebrow>
        {[{name:'Legs',date:'Apr 29, 2024',meta:'50:10 · 16 sets · 17,600 kg',sync:'saved'},{name:'Push Day',date:'Apr 26, 2024',meta:'46:02 · 18 sets · 11,450 kg',sync:'saved'}].map((s,i)=><SessionCard key={i} s={s}/>)}
        <div style={{display:'flex',alignItems:'center',justifyContent:'center',gap:8,padding:'14px 0',fontSize:12,color:'var(--text-tertiary)'}}>
          <HsIcon name="loader" size={14}/> Loading more…
        </div>
      </React.Fragment>}
    </Scroll>
  </Screen>);
}

function HistoryEmpty(){
  return (<Screen><Bar/>
    <HsHeader title="History"/>
    <Scroll style={{paddingTop:60}}>
      <HsEmpty icon="history" title="No workouts yet"
        description="Finished sessions land here with volume, duration, records and where the data is stored."
        action={<HsBtn size="lg" shape="pill" uppercase>Start workout</HsBtn>}/>
    </Scroll>
  </Screen>);
}

function WorkoutDetail({editing, confirming}){
  const sets=[{w:60,r:10,rpe:'—',warmup:true},{w:100,r:8,rpe:8},{w:100,r:6,rpe:8.5},{w:105,r:4,rpe:9,pr:true}];
  return (<Screen><Bar/>
    <HsHeader title="Push Day" subtitle="Today · 09:41 – 10:26" onBack={()=>{}}
      right={editing?<span style={{fontSize:13,fontWeight:800,color:'var(--text-accent)',padding:'0 6px'}}>Save</span>:<HsIconBtn icon="ellipsis" label="Workout options"/>}/>
    <Scroll style={{paddingTop:8}}>
      <HsCard>
        <div style={{display:'flex',justifyContent:'space-between',alignItems:'flex-start'}}>
          <div style={{display:'flex',gap:20}}>
            {[['45:12','Duration'],['18','Sets'],['12,450','Volume kg']].map(([v,l])=>
              <div key={l}>
                <div style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:22,fontWeight:700,letterSpacing:'-.02em'}}>{v}</div>
                <div style={{fontSize:10,letterSpacing:'.06em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700,marginTop:3}}>{l}</div>
              </div>)}
          </div>
          <HsSync state="queued" compact label="Queued"/>
        </div>
      </HsCard>
      <Eyebrow>Exercises</Eyebrow>
      <HsCard pad="tight">
        <div style={{display:'flex',alignItems:'center',gap:8,padding:'2px 6px 10px'}}>
          <span style={{flex:1,fontSize:15,fontWeight:800}}>Bench Press</span>
          <HsPR detail="+2.5 kg"/>
        </div>
        <div style={{display:'flex',gap:8,padding:'0 10px 6px 4px',fontSize:10,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>
          <span style={{width:34,textAlign:'center'}}>Set</span><span style={{flex:1,textAlign:'center'}}>Kg</span><span style={{flex:1,textAlign:'center'}}>Reps</span><span style={{flex:1,textAlign:'center'}}>RPE</span><span style={{width:32}}/>
        </div>
        {sets.map((s,i)=><HsSetRow key={i} index={sets.slice(0,i+1).filter(x=>!x.warmup).length} weight={editing&&i===3?<span style={{color:'var(--text-accent)',borderBottom:'2px solid var(--action-primary)'}}>107.5</span>:s.w} reps={s.r} rir={s.rpe} warmup={s.warmup} state="logged"/>)}
        {editing && <button style={{width:'100%',minHeight:40,marginTop:4,background:'transparent',border:'none',color:'var(--text-accent)',fontSize:13,fontWeight:800,cursor:'pointer'}}>+ Add set</button>}
      </HsCard>
      <HsCard pad="tight" style={{marginTop:8}}>
        <div style={{display:'flex',alignItems:'center',gap:8,padding:'2px 6px 8px'}}>
          <span style={{flex:1,fontSize:15,fontWeight:800}}>Incline Dumbbell Press</span>
          <span style={{fontSize:12,color:'var(--text-tertiary)'}}>2 sets</span>
        </div>
        <HsSetRow index={1} weight={24} reps={10} rir={8} state="logged"/>
        <HsSetRow index={2} weight={26} reps={8} rir={8.5} state="logged"/>
      </HsCard>
      {!editing && <div style={{display:'flex',flexDirection:'column',gap:8,marginTop:20}}>
        <HsBtn variant="secondary" block iconLeft="pencil">Edit workout</HsBtn>
        <HsBtn variant="ghost" block iconLeft="trash-2" style={{color:'var(--feedback-danger)'}}>Delete workout</HsBtn>
      </div>}
    </Scroll>
    {confirming && <Overlay>
      <HsConfirm title="Delete this workout?"
        description="18 sets and 12,450 kg of volume from Push Day will be removed."
        recovery="The Bench Press record set here is recalculated from your remaining history. This cannot be undone."
        confirmLabel="Delete workout"/>
    </Overlay>}
  </Screen>);
}

function ExerciseHistory(){
  const [range,setRange]=React.useState('Last 3 months');
  return (<Screen><Bar/>
    <HsHeader title="Bench Press" subtitle="History · 24 sessions" onBack={()=>{}}/>
    <div style={{padding:'4px var(--gutter-mobile) 0',flex:'0 0 auto'}}>
      <HsSeg options={['1RM','Volume','Top set']} value="1RM" onChange={()=>{}}/>
    </div>
    <Scroll style={{paddingTop:12}}>
      <HsSelect value={range} options={['Last 30 days','Last 3 months','This year','All time']} onChange={setRange}/>
      <HsCard style={{marginTop:12}}>
        <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between'}}>
          <div>
            <div style={{display:'flex',alignItems:'baseline',gap:6}}>
              <span style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:28,fontWeight:700,letterSpacing:'-.02em'}}>102.5</span>
              <span style={{fontSize:13,color:'var(--text-tertiary)',fontWeight:700}}>kg</span>
            </div>
            <div style={{fontSize:12,color:'var(--text-secondary)',marginTop:2}}>Estimated 1RM · best 105 kg × 4</div>
          </div>
          <HsBadge tone="accent">+12.5 kg</HsBadge>
        </div>
        <HsTrend style={{marginTop:16}} height={150} data={[62,68,66,74,80,86,90,88,94,96,100,102.5]} yTicks={[120,100,80,60]} xLabels={['Apr 12','May 10','Jun 7']}/>
        <details style={{marginTop:10}}>
          <summary style={{fontSize:12,color:'var(--text-accent)',fontWeight:800,cursor:'pointer'}}>View as table</summary>
          <table style={{width:'100%',marginTop:8,borderCollapse:'collapse',fontSize:12,color:'var(--text-secondary)'}}>
            <thead><tr><th style={{textAlign:'left',padding:'4px 0',color:'var(--text-tertiary)'}}>Date</th><th style={{textAlign:'right',color:'var(--text-tertiary)'}}>Top set</th><th style={{textAlign:'right',color:'var(--text-tertiary)'}}>Est. 1RM</th></tr></thead>
            <tbody>{[['Jun 7','105 × 4','102.5'],['May 24','102.5 × 5','96'],['May 10','100 × 6','90'],['Apr 26','90 × 5','74']].map(r=>
              <tr key={r[0]}><td style={{padding:'4px 0'}}>{r[0]}</td><td style={{textAlign:'right',fontFamily:'var(--font-numeric)'}}>{r[1]}</td><td style={{textAlign:'right',fontFamily:'var(--font-numeric)'}}>{r[2]}</td></tr>)}</tbody>
          </table>
        </details>
      </HsCard>
      <Eyebrow>Every session</Eyebrow>
      <div style={{display:'flex',flexDirection:'column',gap:8}}>
        {[['Jun 7','105 kg × 4','102.5 kg',true],['May 24','102.5 kg × 5','96.0 kg',false],['May 10','100 kg × 6','90.0 kg',false],['Apr 26','90 kg × 5','74.0 kg',false]].map(([d,top,orm,pr])=>
          <HsRow key={d} thumb="calendar" name={d} meta={`Top set ${top}`} badge={pr?<HsPR/>:null}
            right={<span style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:15,fontWeight:700}}>{orm}</span>}/>)}
      </div>
    </Scroll>
  </Screen>);
}

Object.assign(window,{HistoryList,HistoryEmpty,WorkoutDetail,ExerciseHistory,SESSIONS,SessionCard});
