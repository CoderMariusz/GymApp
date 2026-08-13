const { Card: PCard, SegmentedControl: PSeg, Select: PSelect, TrendChart: PTrend, VolumeBars: PBars, ExerciseRow: PRow, ScreenHeader: PHeader, IconButton: PIconButton, Badge: PBadge, PRBadge: PPRBadge } = window.LifeOSStrengthDesignSystem_576cfb;

function ProgressScreen(){
  const [metric,setMetric]=React.useState('Strength');
  const [range,setRange]=React.useState('This month');
  const series=[62,68,66,74,80,86,90,88,94,96,100,102.5];
  const volume=[8,12,6,14,9,17,11,15,7,13,19,10,16,12,18,9,14,11,17,20,13,15,10,19];
  return (<div className="screen">
    <StatusBar/>
    <PHeader title="Progress" right={<PIconButton icon="sliders-horizontal" label="Filter"/>}/>
    <div style={{padding:'4px var(--gutter-mobile) 0',flex:'0 0 auto'}}>
      <PSeg options={['Strength','Volume','1RM','Body']} value={metric} onChange={setMetric}/>
    </div>
    <div className="scroll" style={{paddingTop:14}}>
      {metric==='Volume' ? (<React.Fragment>
        <PSelect value={range} options={['This week','This month','Last 3 months']} onChange={setRange}/>
        <PCard style={{marginTop:12}}>
          <div style={{display:'flex',alignItems:'baseline',gap:6}}>
            <span className="num" style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:28,fontWeight:700,letterSpacing:'-.02em'}}>18,750</span>
            <span style={{fontSize:13,color:'var(--text-tertiary)',fontWeight:700}}>kg</span>
          </div>
          <div style={{fontSize:12,color:'var(--text-secondary)',marginTop:2}}>Total volume</div>
          <div style={{fontSize:12,color:'var(--feedback-success)',fontWeight:800,marginTop:4}}>+12% vs last month</div>
          <PBars style={{marginTop:16}} height={110} data={volume} labels={['May 1','May 14','May 28']} highlightLast/>
          <details style={{marginTop:12}}>
            <summary style={{fontSize:12,color:'var(--text-accent)',fontWeight:800,cursor:'pointer'}}>View as table</summary>
            <table style={{width:'100%',marginTop:8,borderCollapse:'collapse',fontSize:12,color:'var(--text-secondary)'}}>
              <thead><tr><th style={{textAlign:'left',padding:'4px 0',color:'var(--text-tertiary)',fontWeight:700}}>Week</th><th style={{textAlign:'right',color:'var(--text-tertiary)',fontWeight:700}}>Volume</th></tr></thead>
              <tbody>{[['May 1–7','4,120 kg'],['May 8–14','4,860 kg'],['May 15–21','4,510 kg'],['May 22–28','5,260 kg']].map(([a,b])=>
                <tr key={a}><td style={{padding:'4px 0'}}>{a}</td><td className="num" style={{textAlign:'right',fontFamily:'var(--font-numeric)'}}>{b}</td></tr>)}</tbody>
            </table>
          </details>
        </PCard>
      </React.Fragment>) : (<React.Fragment>
        <PSelect value="Bench Press" options={['Bench Press','Back Squat','Deadlift']}/>
        <PCard style={{marginTop:12}}>
          <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between'}}>
            <div>
              <div style={{display:'flex',alignItems:'baseline',gap:6}}>
                <span className="num" style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:28,fontWeight:700,letterSpacing:'-.02em'}}>102.5</span>
                <span style={{fontSize:13,color:'var(--text-tertiary)',fontWeight:700}}>kg</span>
              </div>
              <div style={{fontSize:12,color:'var(--text-secondary)',marginTop:2}}>Estimated 1RM</div>
            </div>
            <div style={{textAlign:'right'}}>
              <PBadge tone="accent">+5.0 kg</PBadge>
              <div style={{fontSize:11,color:'var(--text-tertiary)',marginTop:4}}>vs last month</div>
            </div>
          </div>
          <PTrend style={{marginTop:16}} height={140} data={series} yTicks={[120,100,80,60]} xLabels={['Apr 12','Apr 26','May 10','May 24','Jun 7']}/>
          <details style={{marginTop:10}}>
            <summary style={{fontSize:12,color:'var(--text-accent)',fontWeight:800,cursor:'pointer'}}>View as table</summary>
            <table style={{width:'100%',marginTop:8,borderCollapse:'collapse',fontSize:12,color:'var(--text-secondary)'}}>
              <thead><tr><th style={{textAlign:'left',padding:'4px 0',color:'var(--text-tertiary)',fontWeight:700}}>Date</th><th style={{textAlign:'right',color:'var(--text-tertiary)',fontWeight:700}}>Est. 1RM</th></tr></thead>
              <tbody>{[['Apr 12','62 kg'],['Apr 26','74 kg'],['May 10','90 kg'],['May 24','96 kg'],['Jun 7','102.5 kg']].map(([a,b])=>
                <tr key={a}><td style={{padding:'4px 0'}}>{a}</td><td className="num" style={{textAlign:'right',fontFamily:'var(--font-numeric)'}}>{b}</td></tr>)}</tbody>
            </table>
          </details>
        </PCard>
      </React.Fragment>)}

      <SectionLabel action="See all">Personal records</SectionLabel>
      <div style={{display:'flex',flexDirection:'column',gap:8}}>
        {[['Bench Press','1RM · May 10, 2024','102.5 kg',true],['Back Squat','1RM · May 8, 2024','140.0 kg',false],['Deadlift','1RM · May 5, 2024','160.0 kg',false]].map(([n,m,v,fresh])=>
          <PRow key={n} name={n} meta={m} badge={fresh?<PPRBadge label="New"/>:null}
            right={<span className="num" style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:17,fontWeight:700}}>{v}</span>}/>)}
      </div>
    </div>
  </div>);
}
window.ProgressScreen = ProgressScreen;
