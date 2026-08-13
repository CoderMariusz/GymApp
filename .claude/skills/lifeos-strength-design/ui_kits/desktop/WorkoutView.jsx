const { Card: WvCard, Button: WvBtn, Icon: WvIc, SetRow: WvSetRow, RestTimer: WvTimer, Stepper: WvStepper, Chip: WvChip, SyncBadge: WvSync, IconButton: WvIconBtn, PRBadge: WvPR } = window.LifeOSStrengthDesignSystem_576cfb;

const WDATA=[
  {name:'Bench Press',equip:'Barbell',last:'100 kg × 8, 5 days ago',sets:[
    {w:60,r:10,rpe:'—',warmup:true,state:'logged'},{w:100,r:8,rpe:8,state:'logged'},
    {w:100,r:6,rpe:8.5,state:'logged'},{w:105,r:4,rpe:9,state:'active'},{w:105,r:4,rpe:9,state:'proposed'}]},
  {name:'Incline Dumbbell Press',equip:'Dumbbell',last:'24 kg × 10, 5 days ago',sets:[
    {w:24,r:10,rpe:8,state:'logged'},{w:26,r:8,rpe:8.5,state:'proposed'}]},
  {name:'Overhead Press',equip:'Barbell',last:'55 kg × 6, 5 days ago',sets:[
    {w:55,r:6,rpe:8,state:'proposed'},{w:55,r:6,rpe:8.5,state:'proposed'}]},
];

function WorkoutView(){
  const [data,setData]=React.useState(WDATA);
  const [weight,setWeight]=React.useState(105);
  const confirm=(ei,si)=>setData(d=>d.map((ex,i)=>i!==ei?ex:{...ex,sets:ex.sets.map((s,j)=>j===si?{...s,state:'logged'}:(j===si+1&&s.state==='proposed'?{...s,state:'active'}:s))}));
  const logged=data.flatMap(e=>e.sets).filter(s=>s.state==='logged'&&!s.warmup).length;
  const total=data.flatMap(e=>e.sets).filter(s=>!s.warmup).length;
  return (<div style={{display:'grid',gridTemplateColumns:'1fr 372px',gap:24,alignItems:'start'}}>
    <div>
      <div style={{display:'flex',alignItems:'flex-end',justifyContent:'space-between',marginBottom:20}}>
        <div>
          <div className="dlbl">Active workout · 45:12</div>
          <h1 style={{fontFamily:'var(--font-display)',fontSize:46,lineHeight:'50px',fontWeight:700,letterSpacing:'-.02em',margin:'6px 0 0'}}>Push Day</h1>
        </div>
        <WvSync state="draft_local"/>
      </div>
      <div style={{height:4,background:'var(--surface-raised)',borderRadius:999,overflow:'hidden',marginBottom:20}}>
        <div style={{height:'100%',width:`${(logged/total)*100}%`,background:'var(--action-primary)',transition:'width var(--dur-base) var(--ease-standard)'}}/>
      </div>
      <div style={{display:'flex',flexDirection:'column',gap:12}}>
        {data.map((ex,ei)=>
          <WvCard key={ex.name} pad="default">
            <div style={{display:'flex',alignItems:'flex-start',gap:12,marginBottom:12}}>
              <span style={{width:28,height:28,borderRadius:999,background:'var(--surface-inset)',display:'inline-flex',alignItems:'center',justifyContent:'center',fontFamily:'var(--font-numeric)',fontSize:13,fontWeight:700,color:'var(--text-secondary)'}}>{ei+1}</span>
              <span style={{flex:1}}>
                <span style={{display:'block',fontSize:18,fontWeight:800}}>{ex.name}</span>
                <span style={{display:'block',fontSize:13,color:'var(--text-tertiary)',marginTop:2}}>{ex.equip} · last time: {ex.last}</span>
              </span>
              <WvIconBtn icon="ellipsis" label="Exercise options" size={36} iconSize={18}/>
            </div>
            <div style={{display:'flex',gap:8,padding:'0 10px 6px 4px',fontSize:10,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>
              <span style={{width:34,textAlign:'center'}}>Set</span><span style={{flex:1,textAlign:'center'}}>Kg</span><span style={{flex:1,textAlign:'center'}}>Reps</span><span style={{flex:1,textAlign:'center'}}>RPE</span><span style={{flex:1,textAlign:'center'}}>Rest</span><span style={{width:32}}/>
            </div>
            {ex.sets.map((s,si)=>
              <WvSetRow key={si} index={ex.sets.slice(0,si+1).filter(x=>!x.warmup).length} weight={s.w} reps={s.r} rir={s.rpe} rest={s.state==='logged'?'2:00':'—'} warmup={s.warmup} state={s.state} onConfirm={()=>confirm(ei,si)}/>)}
            <button style={{minHeight:40,marginTop:4,background:'transparent',border:'none',color:'var(--text-accent)',fontSize:13,fontWeight:800,cursor:'pointer',fontFamily:'var(--font-ui)'}}>+ Add set</button>
          </WvCard>)}
        <WvBtn variant="secondary" block iconLeft="plus">Add exercise</WvBtn>
      </div>
    </div>

    <div style={{position:'sticky',top:28,display:'flex',flexDirection:'column',gap:12}}>
      <WvCard pad="loose">
        <div className="dlbl">Current set · Bench Press</div>
        <div style={{marginTop:14}}><WvStepper size="lg" value={weight} step={2.5} unit="kg" onChange={setWeight}/></div>
        <div style={{display:'flex',gap:8,marginTop:10}}>
          {[weight-2.5,weight+2.5,weight+5].map(v=><WvChip key={v} onClick={()=>setWeight(v)}>{v} kg</WvChip>)}
        </div>
        <div style={{marginTop:14}}><WvStepper value={4} step={1} unit="reps"/></div>
        <WvBtn variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:16}}>Complete set</WvBtn>
        <div style={{marginTop:10,fontSize:12,color:'var(--set-proposed-text)',textAlign:'center'}}>Pre-filled from 5 days ago — confirm or adjust.</div>
      </WvCard>
      <WvTimer remaining="1:45" running nextLabel="Next exercise" nextValue="Incline DB Press"/>
      <WvCard>
        <div className="dlbl" style={{marginBottom:12}}>Session</div>
        {[['Working sets',`${logged} / ${total}`],['Volume','8,240 kg'],['Duration','45:12'],['New records','1']].map(([k,v])=>
          <div key={k} style={{display:'flex',justifyContent:'space-between',alignItems:'center',padding:'7px 0',borderBottom:'1px solid var(--border-subtle)'}}>
            <span style={{fontSize:13,color:'var(--text-secondary)'}}>{k}</span>
            <span className="num" style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:15,fontWeight:700}}>{v}</span>
          </div>)}
        <div style={{marginTop:12}}><WvPR label="PR" detail="Bench Press +2.5 kg"/></div>
      </WvCard>
      <WvBtn variant="secondary" size="lg" block>Complete workout</WvBtn>
    </div>
  </div>);
}
window.WorkoutView = WorkoutView;
