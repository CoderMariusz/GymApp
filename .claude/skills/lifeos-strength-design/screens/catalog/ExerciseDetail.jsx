const { Card:XCard, Button:XBtn, IconButton:XIconBtn, Icon:XIcon, Chip:XChip, Input:XInput, Select:XSelect, Badge:XBadge, PRBadge:XPR, ScreenHeader:XHeader, ExerciseRow:XRow, ConfirmDialog:XConfirm, TrendChart:XTrend, EmptyState:XEmpty } = window.LifeOSStrengthDesignSystem_576cfb;

function Meta({items}){
  return (<div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8}}>
    {items.map(([k,v])=>
      <div key={k} style={{padding:'10px 12px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)'}}>
        <div style={{fontSize:10,letterSpacing:'.06em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700}}>{k}</div>
        <div style={{fontSize:13,fontWeight:800,marginTop:3}}>{v}</div>
      </div>)}
  </div>);
}

function ExerciseDetail({minimal, custom}){
  return (<Screen><Bar/>
    <XHeader title={custom?'Farmer Carry':'Bench Press'} onBack={()=>{}}
      right={custom?<XIconBtn icon="pencil" label="Edit exercise"/>:<XIconBtn icon="star" label="Add to favourites"/>}/>
    <Scroll style={{paddingTop:6}}>
      <div style={{display:'flex',alignItems:'center',gap:12,marginBottom:14}}>
        <span style={{width:56,height:56,borderRadius:'var(--radius-lg)',background:'var(--surface-inset)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}>
          <XIcon name="dumbbell" size={26} color="var(--text-secondary)"/>
        </span>
        <div style={{flex:1}}>
          <div style={{display:'flex',gap:6,flexWrap:'wrap'}}>
            <XBadge tone="neutral" size="sm">{custom?'Dumbbell':'Barbell'}</XBadge>
            <XBadge tone="neutral" size="sm">{custom?'Carry':'Chest'}</XBadge>
            {custom && <XBadge tone="accent" size="sm">Custom</XBadge>}
          </div>
          <div style={{fontSize:12,color:'var(--text-tertiary)',marginTop:6}}>Tracks: {custom?'distance · duration':'weight · reps'}</div>
        </div>
      </div>

      <Meta items={custom
        ? [['Equipment','Dumbbell'],['Pattern','Carry'],['Difficulty','Intermediate'],['Created','Jun 2, 2024']]
        : [['Equipment','Barbell'],['Pattern','Push horizontal'],['Difficulty','Intermediate'],['Compound','Yes']]}/>

      {!minimal && !custom && <React.Fragment>
        <Eyebrow>Your progress</Eyebrow>
        <XCard>
          <div style={{display:'flex',alignItems:'baseline',gap:6}}>
            <span style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:28,fontWeight:700,letterSpacing:'-.02em'}}>102.5</span>
            <span style={{fontSize:13,color:'var(--text-tertiary)',fontWeight:700}}>kg</span>
            <XBadge tone="accent" style={{marginLeft:6}}>+12.5 kg</XBadge>
          </div>
          <div style={{fontSize:12,color:'var(--text-secondary)',marginTop:2}}>Estimated 1RM · 24 sessions logged</div>
          <XTrend style={{marginTop:14}} height={110} data={[62,68,66,74,80,86,90,88,94,96,100,102.5]} xLabels={['Apr 12','Jun 7']}/>
        </XCard>
        <XBtn variant="secondary" block iconLeft="history" style={{marginTop:8}}>See all 24 sessions</XBtn>

        <Eyebrow>Last time</Eyebrow>
        <XCard pad="tight">
          {[['1','100 kg × 8','RPE 8'],['2','100 kg × 6','RPE 8.5'],['3','105 kg × 4','RPE 9']].map(([n,v,r])=>
            <div key={n} style={{display:'flex',alignItems:'center',gap:10,minHeight:40,padding:'0 8px'}}>
              <span style={{width:26,textAlign:'center',fontFamily:'var(--font-numeric)',fontSize:13,color:'var(--text-tertiary)',fontWeight:700}}>{n}</span>
              <span style={{flex:1,fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:15,fontWeight:700}}>{v}</span>
              <span style={{fontSize:12,color:'var(--text-tertiary)'}}>{r}</span>
            </div>)}
          <div style={{padding:'8px',fontSize:11,color:'var(--text-tertiary)'}}>Jun 7, 2024 · 5 days ago</div>
        </XCard>
      </React.Fragment>}

      {minimal && <React.Fragment>
        <Eyebrow>Your progress</Eyebrow>
        <XEmpty icon="chart-column" title="No sessions yet"
          description="Log this exercise once and its trend, records and last-session recall appear here."/>
        <div style={{padding:'12px 14px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)',fontSize:12,lineHeight:'17px',color:'var(--text-tertiary)'}}>
          <XIcon name="info" size={14} style={{marginRight:6,verticalAlign:'-2px'}}/>
          No form tips are available for this exercise. Written guidance exists for 50 key movements only.
        </div>
      </React.Fragment>}

      {custom && <div style={{display:'flex',flexDirection:'column',gap:8,marginTop:20}}>
        <XBtn variant="secondary" block iconLeft="pencil">Edit exercise</XBtn>
        <XBtn variant="ghost" block iconLeft="trash-2" style={{color:'var(--feedback-danger)'}}>Delete exercise</XBtn>
      </div>}
      <XBtn variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:20}}>Add to workout</XBtn>
    </Scroll>
  </Screen>);
}

function CustomEditor({mode='create', invalid, confirming}){
  return (<Screen><Bar/>
    <XHeader title={mode==='create'?'New exercise':'Edit exercise'} onBack={()=>{}}
      right={<span style={{fontSize:13,fontWeight:800,color:invalid?'var(--text-tertiary)':'var(--text-accent)',padding:'0 6px'}}>Save</span>}/>
    <Scroll style={{paddingTop:8}}>
      <div style={{display:'flex',flexDirection:'column',gap:14}}>
        <XInput label="Name" placeholder="e.g. Farmer Carry" defaultValue={invalid?'':(mode==='create'?'Farmer Carry':'Farmer Carry')}
          error={invalid?'A name is required':undefined}/>
        <XSelect label="Equipment" value="Dumbbell" options={['Barbell','Dumbbell','Machine','Cable','Bodyweight','Kettlebell','Band']}/>
        <XSelect label="Movement pattern" value="Carry" options={['Push horizontal','Push vertical','Pull horizontal','Pull vertical','Squat','Hinge','Lunge','Carry','Rotation','Isolation']}/>
        <div>
          <div style={{fontSize:13,fontWeight:700,color:'var(--text-secondary)',marginBottom:8}}>What this exercise tracks</div>
          <div style={{display:'flex',gap:8,flexWrap:'wrap'}}>
            <XChip>Weight</XChip><XChip>Reps</XChip><XChip selected>Distance</XChip><XChip selected>Duration</XChip>
          </div>
          {invalid && <div style={{display:'flex',alignItems:'center',gap:6,marginTop:8,fontSize:12,color:'var(--feedback-danger)'}}>
            <XIcon name="circle-alert" size={13}/> Pick at least one value to track
          </div>}
          <div style={{fontSize:11,color:'var(--text-tertiary)',marginTop:8,lineHeight:'16px'}}>This decides the set editor layout: distance and duration replace the weight and reps columns.</div>
        </div>
        <XSelect label="Difficulty" value="Intermediate" options={['Beginner','Intermediate','Advanced']}/>
        <div>
          <div style={{fontSize:13,fontWeight:700,color:'var(--text-secondary)',marginBottom:6}}>Default rest</div>
          <div style={{display:'flex',gap:8}}>
            <XChip>0:60</XChip><XChip selected>1:30</XChip><XChip>2:00</XChip><XChip>3:00</XChip>
          </div>
        </div>
      </div>
      {mode==='edit' && <XBtn variant="ghost" block iconLeft="trash-2" style={{color:'var(--feedback-danger)',marginTop:24}}>Delete exercise</XBtn>}
      <div style={{marginTop:20,padding:'12px 14px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)',fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)'}}>
        Custom exercises are yours only. They stay on this device until the next sync.
      </div>
    </Scroll>
    {confirming && <Overlay>
      <XConfirm title="Delete Farmer Carry?"
        description="This exercise appears in 6 logged workouts."
        recovery="Those workouts keep their sets, but the exercise disappears from the catalog and its progress chart. This cannot be undone."
        confirmLabel="Delete exercise"/>
    </Overlay>}
  </Screen>);
}
Object.assign(window,{ExerciseDetail,CustomEditor});
