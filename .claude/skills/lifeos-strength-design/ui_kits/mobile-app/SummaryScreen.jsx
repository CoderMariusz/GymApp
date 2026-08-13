const { Card: MCard, Button: MButton, Icon: MIcon, StatCard: MStatCard, SyncBadge: MSyncBadge, PRBadge: MPRBadge, Banner: MBanner, ScreenHeader: MHeader } = window.LifeOSStrengthDesignSystem_576cfb;

function SummaryScreen({onDone}){
  const [sync,setSync]=React.useState('queued');
  React.useEffect(()=>{
    const a=setTimeout(()=>setSync('syncing'),2200);
    const b=setTimeout(()=>setSync('saved'),4600);
    return ()=>{clearTimeout(a);clearTimeout(b);};
  },[]);
  return (<div className="screen">
    <StatusBar/>
    <MHeader title="Workout summary"/>
    <div className="scroll" style={{paddingTop:8}}>
      <MCard radius="xl" pad="loose">
        <div style={{display:'flex',alignItems:'center',justifyContent:'space-between'}}>
          <div>
            <div style={{fontFamily:'var(--font-display)',fontSize:22,fontWeight:700}}>Push Day</div>
            <div style={{fontSize:12,color:'var(--text-tertiary)',marginTop:2}}>Today · 09:41 – 10:26</div>
          </div>
          <MSyncBadge state={sync}/>
        </div>
        <div style={{display:'flex',gap:20,marginTop:18}}>
          {[['45:12','Duration'],['18','Working sets'],['12,450','Volume kg']].map(([v,l])=>
            <div key={l}>
              <div className="num" style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:24,fontWeight:700,letterSpacing:'-.02em'}}>{v}</div>
              <div style={{fontSize:11,letterSpacing:'.06em',textTransform:'uppercase',color:'var(--text-tertiary)',fontWeight:700,marginTop:3}}>{l}</div>
            </div>)}
        </div>
      </MCard>

      <SectionLabel>New records</SectionLabel>
      <div style={{display:'flex',flexDirection:'column',gap:8}}>
        {[['Bench Press','105 kg × 4','+2.5 kg'],['Incline Dumbbell Press','26 kg × 8','+2 reps']].map(([n,v,d])=>
          <MCard key={n} pad="tight">
            <div style={{display:'flex',alignItems:'center',gap:12}}>
              <span style={{width:36,height:36,borderRadius:999,background:'var(--feedback-success-quiet)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><MIcon name="trophy" size={17} color="var(--feedback-success)"/></span>
              <span style={{flex:1,minWidth:0}}>
                <span style={{display:'block',fontSize:14,fontWeight:800}}>{n}</span>
                <span style={{display:'block',fontSize:12,color:'var(--text-tertiary)',marginTop:2}}>{v}</span>
              </span>
              <MPRBadge label="PR" detail={d}/>
            </div>
          </MCard>)}
      </div>

      <div style={{marginTop:14}}>
        {sync==='queued' && <MBanner icon="clock" title="Saved on this device" description="Waiting for a connection. Nothing is lost — it uploads by itself."/>}
        {sync==='syncing' && <MBanner icon="refresh-cw" tone="info" title="Sending to the server" description="You can leave this screen."/>}
        {sync==='saved' && <MBanner icon="check" title="On the server" description="Available on your other devices."/>}
      </div>

      <MButton variant="primary" size="lg" shape="pill" block uppercase style={{marginTop:16}} onClick={onDone}>Done</MButton>
      <button style={{width:'100%',minHeight:44,marginTop:6,background:'none',border:'none',color:'var(--text-secondary)',fontSize:13,fontWeight:700,cursor:'pointer'}}>Edit workout</button>
    </div>
  </div>);
}
window.SummaryScreen = SummaryScreen;
