const { Card: WCard, Button: WButton, IconButton: WIconButton, Icon: WIcon, SetRow: WSetRow, RestTimer: WRestTimer, SyncBadge: WSyncBadge, ScreenHeader: WHeader, Stepper: WStepper, Chip: WChip, PRBadge: WPRBadge } = window.LifeOSStrengthDesignSystem_576cfb;

const EXERCISES = [
  { name:'Bench Press', equip:'Barbell', last:'100 kg × 8, 5 days ago', sets:[
    {w:60,r:10,rpe:'—',warmup:true,state:'logged'},
    {w:100,r:8,rpe:8,state:'logged'},
    {w:100,r:6,rpe:8.5,state:'logged'},
    {w:105,r:4,rpe:9,state:'active'},
    {w:105,r:4,rpe:9,state:'proposed'},
  ]},
  { name:'Incline Dumbbell Press', equip:'Dumbbell', last:'24 kg × 10, 5 days ago', sets:[
    {w:24,r:10,rpe:8,state:'logged'},
    {w:26,r:8,rpe:8.5,state:'proposed'},
  ]},
];

function SetTable({ex, onConfirm}){
  return (<WCard pad="tight" style={{marginBottom:10}}>
    <div style={{display:'flex',alignItems:'flex-start',gap:10,padding:'4px 6px 10px'}}>
      <span style={{width:24,height:24,borderRadius:999,background:'var(--surface-inset)',display:'inline-flex',alignItems:'center',justifyContent:'center',fontFamily:'var(--font-numeric)',fontSize:12,fontWeight:700,color:'var(--text-secondary)',flex:'0 0 auto',marginTop:2}}>{ex.n}</span>
      <span style={{flex:1,minWidth:0}}>
        <span style={{display:'flex',alignItems:'center',gap:8}}>
          <span style={{fontSize:16,fontWeight:800}}>{ex.name}</span>
          {ex.pr && <WPRBadge/>}
        </span>
        <span style={{display:'block',fontSize:12,color:'var(--text-tertiary)',marginTop:2}}>{ex.equip}</span>
        <span style={{display:'block',fontSize:11,color:'var(--set-proposed-text)',marginTop:4}}>Last time: {ex.last}</span>
      </span>
      <WIconButton icon="ellipsis" label="Exercise options" size={32} iconSize={18}/>
    </div>
    <div style={{display:'flex',gap:8,padding:'0 10px 6px 4px',fontSize:10,letterSpacing:'.08em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>
      <span style={{width:34,textAlign:'center'}}>Set</span>
      <span style={{flex:1,textAlign:'center'}}>Kg</span>
      <span style={{flex:1,textAlign:'center'}}>Reps</span>
      <span style={{flex:1,textAlign:'center'}}>RPE</span>
      <span style={{width:32}}/>
    </div>
    {ex.sets.map((s,i)=>
      <WSetRow key={i} index={ex.sets.slice(0,i+1).filter(x=>!x.warmup).length} weight={s.w} reps={s.r} rir={s.rpe}
        warmup={s.warmup} state={s.state} onConfirm={()=>onConfirm(ex.i,i)}/>)}
    <button style={{width:'100%',minHeight:40,marginTop:4,background:'transparent',border:'none',color:'var(--text-accent)',fontSize:13,fontWeight:800,cursor:'pointer',fontFamily:'var(--font-ui)'}}>+ Add set</button>
  </WCard>);
}

function WorkoutScreen({onBack, onComplete}){
  const [data,setData]=React.useState(EXERCISES);
  const [timer,setTimer]=React.useState(75);
  const [running,setRunning]=React.useState(true);
  React.useEffect(()=>{
    if(!running) return;
    const id=setInterval(()=>setTimer(t=>t>0?t-1:0),1000);
    return ()=>clearInterval(id);
  },[running]);
  const confirm=(ei,si)=>setData(d=>d.map((ex,i)=>i!==ei?ex:{...ex,sets:ex.sets.map((s,j)=>{
    if(j!==si) return s;
    return {...s,state:'logged'};
  }).map((s,j)=>(j===si+1&&s.state==='proposed')?{...s,state:'active'}:s)}));
  const logged=data.flatMap(e=>e.sets).filter(s=>s.state==='logged'&&!s.warmup).length;
  const total=data.flatMap(e=>e.sets).filter(s=>!s.warmup).length;
  const mmss=`${Math.floor(timer/60)}:${String(timer%60).padStart(2,'0')}`;
  const active=data.find(e=>e.sets.some(s=>s.state==='active'));
  const activeSet=active&&active.sets.find(s=>s.state==='active');

  return (<div className="screen">
    <StatusBar/>
    <WHeader title="Push Day" subtitle={`${logged} of ${total} working sets`} onBack={onBack}
      right={<WSyncBadge state="draft_local" compact label="On device"/>}/>
    <div style={{height:3,margin:'2px var(--gutter-mobile) 0',background:'var(--surface-raised)',borderRadius:999,overflow:'hidden',flex:'0 0 auto'}}>
      <div style={{height:'100%',width:`${(logged/total)*100}%`,background:'var(--action-primary)',transition:'width var(--dur-base) var(--ease-standard)'}}/>
    </div>
    <div className="scroll" style={{paddingTop:12,paddingBottom:210}}>
      {data.map((ex,i)=><SetTable key={ex.name} ex={{...ex,n:i+1,i}} onConfirm={confirm}/>)}
      <WButton variant="secondary" block iconLeft="plus">Add exercise</WButton>
    </div>
    <div style={{position:'absolute',left:0,right:0,bottom:0,padding:'12px var(--gutter-mobile) 16px',background:'linear-gradient(180deg,rgba(7,10,15,0) 0%,var(--surface-base) 34%)'}}>
      {activeSet && <div style={{display:'flex',alignItems:'center',gap:8,marginBottom:10}}>
        <WStepper style={{flex:1}} value={activeSet.w} step={2.5} unit="kg" onChange={(v)=>setData(d=>d.map(e=>({...e,sets:e.sets.map(s=>s.state==='active'?{...s,w:v}:s)})))}/>
        <div style={{display:'flex',flexDirection:'column',gap:6}}>
          {[activeSet.w+2.5,activeSet.w+5].map(v=><WChip key={v} onClick={()=>setData(d=>d.map(e=>({...e,sets:e.sets.map(s=>s.state==='active'?{...s,w:v}:s)})))}>{v} kg</WChip>)}
        </div>
      </div>}
      <WRestTimer remaining={mmss} running={running} onToggle={()=>setRunning(r=>!r)} nextLabel="Next" nextValue="Overhead Press" style={{marginBottom:10}}/>
      <WButton variant="primary" size="lg" shape="pill" block uppercase onClick={onComplete}>Complete workout</WButton>
    </div>
  </div>);
}
window.WorkoutScreen = WorkoutScreen;
