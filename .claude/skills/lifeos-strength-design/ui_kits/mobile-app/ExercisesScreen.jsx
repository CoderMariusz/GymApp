const { Input: EInput, Chip: EChip, ExerciseRow: EExerciseRow, Badge: EBadge, ScreenHeader: EHeader, IconButton: EIconButton, EmptyState: EEmptyState } = window.LifeOSStrengthDesignSystem_576cfb;

const CATALOG = [
  {name:'Bench Press', equip:'Barbell', group:'Chest', last:'100 kg × 8'},
  {name:'Incline Dumbbell Press', equip:'Dumbbell', group:'Chest', last:'26 kg × 8'},
  {name:'Overhead Press', equip:'Barbell', group:'Shoulders', last:'55 kg × 6'},
  {name:'Barbell Row', equip:'Barbell', group:'Back', last:'90 kg × 8'},
  {name:'Pull-up', equip:'Bodyweight', group:'Back', last:'BW × 10'},
  {name:'Back Squat', equip:'Barbell', group:'Legs', last:'140 kg × 5'},
  {name:'Romanian Deadlift', equip:'Barbell', group:'Legs', last:'120 kg × 8'},
  {name:'Farmer Carry', equip:'Dumbbell', group:'Carry', last:'40 kg · 40 m', custom:true},
  {name:'Plank', equip:'Bodyweight', group:'Core', last:'1:30'},
];

function ExercisesScreen(){
  const [q,setQ]=React.useState('');
  const [filter,setFilter]=React.useState('All');
  const filters=['All','Barbell','Dumbbell','Bodyweight','Custom'];
  const list=CATALOG.filter(e=>
    (filter==='All'||(filter==='Custom'?e.custom:e.equip===filter)) &&
    e.name.toLowerCase().includes(q.toLowerCase()));
  return (<div className="screen">
    <StatusBar/>
    <EHeader title="Exercises" right={<EIconButton icon="plus" label="Create custom exercise"/>}/>
    <div style={{padding:'4px var(--gutter-mobile) 0',flex:'0 0 auto'}}>
      <EInput icon="search" placeholder="Search 214 exercises" value={q} onChange={(e)=>setQ(e.target.value)}/>
      <div style={{display:'flex',gap:8,marginTop:12,overflowX:'auto',paddingBottom:4}}>
        {filters.map(fl=><EChip key={fl} selected={fl===filter} onClick={()=>setFilter(fl)}>{fl}</EChip>)}
      </div>
    </div>
    <div className="scroll" style={{paddingTop:12}}>
      {q==='' && filter==='All' && <SectionLabel>Recent</SectionLabel>}
      {list.length===0
        ? <EEmptyState icon="search-x" title="No exercises found" description={`Nothing matches "${q}". Create it as a custom exercise instead.`}/>
        : <div style={{display:'flex',flexDirection:'column',gap:8}}>
            {list.map(e=><EExerciseRow key={e.name} name={e.name} meta={`${e.equip} · ${e.group} · last: ${e.last}`}
              badge={e.custom?<EBadge tone="neutral" size="sm">Custom</EBadge>:null}/>)}
          </div>}
    </div>
  </div>);
}
window.ExercisesScreen = ExercisesScreen;
