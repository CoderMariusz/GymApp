const { Card:SlCard, Button:SlBtn, IconButton:SlIconBtn, Icon:SlIcon, Chip:SlChip, Input:SlInput, Badge:SlBadge, ExerciseRow:SlRow, EmptyState:SlEmpty, ScreenHeader:SlHeader, SetRow:SlSetRow } = window.LifeOSStrengthDesignSystem_576cfb;

const RECENT=[['Bench Press','Barbell · last: 100 kg × 8'],['Incline Dumbbell Press','Dumbbell · last: 26 kg × 8'],['Overhead Press','Barbell · last: 55 kg × 6']];
const FREQUENT=[['Back Squat','Barbell · 42 sessions'],['Deadlift','Barbell · 31 sessions'],['Pull-up','Bodyweight · 28 sessions'],['Barbell Row','Barbell · 24 sessions']];
const RESULTS=[['Bench Press','Barbell · Chest'],['Close-Grip Bench Press','Barbell · Chest'],['Dumbbell Bench Press','Dumbbell · Chest'],['Incline Bench Press','Barbell · Chest']];

/* The workout underneath, so the sheet reads in context */
function WorkoutBackdrop(){
  return (<Screen><Bar/>
    <SlHeader title="Push Day" subtitle="3 of 18 working sets" onBack={()=>{}}/>
    <Scroll style={{paddingTop:12,opacity:.5}}>
      <SlCard pad="tight">
        <div style={{padding:'4px 6px 10px',fontSize:16,fontWeight:800}}>Bench Press</div>
        <SlSetRow index={1} weight={100} reps={8} rir={8} state="logged"/>
        <SlSetRow index={2} weight={100} reps={6} rir={8.5} state="logged"/>
        <SlSetRow index={3} weight={105} reps={4} rir={9} state="active"/>
      </SlCard>
    </Scroll>
  </Screen>);
}

function SelectorSheet({mode='recent'}){
  const q = mode==='search'||mode==='noresults';
  return (<React.Fragment>
    <WorkoutBackdrop/>
    <Sheet height="80%">
      <div style={{padding:'8px var(--gutter-mobile) 12px',flex:'0 0 auto'}}>
        <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',minHeight:36}}>
          <span style={{fontFamily:'var(--font-display)',fontSize:19,fontWeight:700}}>Add exercise</span>
          <SlIconBtn icon="x" label="Close"/>
        </div>
        <SlInput icon="search" placeholder="Search 214 exercises"
          defaultValue={mode==='search'?'bench':mode==='noresults'?'benhc press':''} style={{marginTop:10}}/>
        {mode==='filtered'
          ? <div style={{display:'flex',gap:8,marginTop:12,overflowX:'auto',paddingBottom:2}}>
              <SlChip>All</SlChip><SlChip selected icon="x">Barbell</SlChip><SlChip selected icon="x">Chest</SlChip><SlChip>Bodyweight</SlChip>
            </div>
          : <div style={{display:'flex',gap:8,marginTop:12,overflowX:'auto',paddingBottom:2}}>
              <SlChip selected>All</SlChip><SlChip>Barbell</SlChip><SlChip>Dumbbell</SlChip><SlChip>Bodyweight</SlChip><SlChip>Custom</SlChip>
            </div>}
      </div>
      <div style={{flex:1,overflowY:'auto',padding:'0 var(--gutter-mobile) 20px'}}>
        {mode==='noresults' ? (
          <SlEmpty icon="search-x" title="No exercises found"
            description={'Nothing matches "benhc press". Check the spelling, or create it as a custom exercise.'}
            action={<SlBtn variant="secondary" iconLeft="plus">Create "benhc press"</SlBtn>}/>
        ) : mode==='search' ? (<React.Fragment>
          <Eyebrow>4 results</Eyebrow>
          <div style={{display:'flex',flexDirection:'column',gap:8}}>
            {RESULTS.map(([n,m])=><SlRow key={n} name={n} meta={m} right={<SlIcon name="plus" size={20} color="var(--action-primary)"/>}/>)}
          </div>
        </React.Fragment>) : mode==='filtered' ? (<React.Fragment>
          <Eyebrow>Barbell · Chest · 6 exercises</Eyebrow>
          <div style={{display:'flex',flexDirection:'column',gap:8}}>
            {[['Bench Press','Barbell · Chest'],['Close-Grip Bench Press','Barbell · Chest'],['Incline Bench Press','Barbell · Chest'],['Decline Bench Press','Barbell · Chest'],['Floor Press','Barbell · Chest'],['Guillotine Press','Barbell · Chest']].map(([n,m])=>
              <SlRow key={n} name={n} meta={m} right={<SlIcon name="plus" size={20} color="var(--action-primary)"/>}/>)}
          </div>
        </React.Fragment>) : (<React.Fragment>
          <Eyebrow>Recent</Eyebrow>
          <div style={{display:'flex',flexDirection:'column',gap:8}}>
            {RECENT.map(([n,m])=><SlRow key={n} name={n} meta={m} right={<SlIcon name="plus" size={20} color="var(--action-primary)"/>}/>)}
          </div>
          <Eyebrow>Most used</Eyebrow>
          <div style={{display:'flex',flexDirection:'column',gap:8}}>
            {FREQUENT.map(([n,m])=><SlRow key={n} name={n} meta={m} right={<SlIcon name="plus" size={20} color="var(--action-primary)"/>}/>)}
          </div>
          <SlBtn variant="secondary" block iconLeft="plus" style={{marginTop:16}}>Create custom exercise</SlBtn>
        </React.Fragment>)}
      </div>
    </Sheet>
  </React.Fragment>);
}
Object.assign(window,{SelectorSheet,WorkoutBackdrop});
