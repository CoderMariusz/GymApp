const { Card: PvCard, SegmentedControl: PvSeg, Select: PvSel, TrendChart: PvTrend, VolumeBars: PvBars, ExerciseRow: PvRow, Badge: PvBadge, PRBadge: PvPR } = window.LifeOSStrengthDesignSystem_576cfb;

function ProgressView(){
  const [metric,setMetric]=React.useState('Strength');
  return (<div>
    <div style={{display:'flex',alignItems:'flex-end',justifyContent:'space-between',marginBottom:24}}>
      <h1 style={{fontFamily:'var(--font-display)',fontSize:46,lineHeight:'50px',fontWeight:700,letterSpacing:'-.02em',margin:0}}>Progress</h1>
      <div style={{display:'flex',gap:12,alignItems:'center'}}>
        <PvSeg options={['Strength','Volume','1RM','Body']} value={metric} onChange={setMetric}/>
        <PvSel value="This month" options={['This week','This month','Last 3 months']} style={{width:190}}/>
      </div>
    </div>
    <div style={{display:'grid',gridTemplateColumns:'1.6fr 1fr',gap:20}}>
      <PvCard pad="loose">
        <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between'}}>
          <div>
            <div className="dlbl">Bench Press · estimated 1RM</div>
            <div style={{display:'flex',alignItems:'baseline',gap:8,marginTop:8}}>
              <span className="num" style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:44,lineHeight:'44px',fontWeight:700,letterSpacing:'-.02em'}}>102.5</span>
              <span style={{fontSize:16,color:'var(--text-tertiary)',fontWeight:700}}>kg</span>
              <PvBadge tone="accent">+5.0 kg</PvBadge>
            </div>
          </div>
          <PvPR label="New record" detail="May 10"/>
        </div>
        <PvTrend style={{marginTop:24}} height={260} data={[62,68,66,74,80,86,90,88,94,96,100,102.5]} yTicks={[120,100,80,60]} xLabels={['Apr 12','Apr 26','May 10','May 24','Jun 7']}/>
        <details style={{marginTop:16}}>
          <summary style={{fontSize:13,color:'var(--text-accent)',fontWeight:800,cursor:'pointer'}}>View as table</summary>
          <table style={{width:'100%',marginTop:10,borderCollapse:'collapse',fontSize:13,color:'var(--text-secondary)'}}>
            <thead><tr><th style={{textAlign:'left',padding:'6px 0',color:'var(--text-tertiary)'}}>Date</th><th style={{textAlign:'right',color:'var(--text-tertiary)'}}>Top set</th><th style={{textAlign:'right',color:'var(--text-tertiary)'}}>Est. 1RM</th></tr></thead>
            <tbody>{[['Apr 12','80 kg × 5','62 kg'],['Apr 26','90 kg × 5','74 kg'],['May 10','100 kg × 6','90 kg'],['May 24','102.5 kg × 5','96 kg'],['Jun 7','105 kg × 4','102.5 kg']].map(r=>
              <tr key={r[0]}><td style={{padding:'6px 0'}}>{r[0]}</td><td className="num" style={{textAlign:'right',fontFamily:'var(--font-numeric)'}}>{r[1]}</td><td className="num" style={{textAlign:'right',fontFamily:'var(--font-numeric)'}}>{r[2]}</td></tr>)}</tbody>
          </table>
        </details>
      </PvCard>
      <div style={{display:'flex',flexDirection:'column',gap:12}}>
        <PvCard>
          <div className="dlbl">Weekly volume</div>
          <div style={{display:'flex',alignItems:'baseline',gap:6,marginTop:8}}>
            <span className="num" style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:28,fontWeight:700}}>18,750</span>
            <span style={{fontSize:13,color:'var(--text-tertiary)',fontWeight:700}}>kg</span>
            <span style={{fontSize:13,color:'var(--feedback-success)',fontWeight:800,marginLeft:6}}>+12%</span>
          </div>
          <PvBars style={{marginTop:18}} height={120} data={[8,12,6,14,9,17,11,15,7,13,19,10,16,12,18,9,14,11,17,20,13,15,10,19]} labels={['May 1','May 14','May 28']} highlightLast/>
        </PvCard>
        <PvCard>
          <div className="dlbl" style={{marginBottom:12}}>Top lifts</div>
          <div style={{display:'flex',flexDirection:'column',gap:8}}>
            {[['Bench Press','102.5 kg'],['Back Squat','140.0 kg'],['Deadlift','160.0 kg'],['Overhead Press','62.5 kg']].map(([n,v])=>
              <div key={n} style={{display:'flex',justifyContent:'space-between',alignItems:'center',padding:'6px 0',borderBottom:'1px solid var(--border-subtle)'}}>
                <span style={{fontSize:14,fontWeight:700}}>{n}</span>
                <span className="num" style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:15,fontWeight:700}}>{v}</span>
              </div>)}
          </div>
        </PvCard>
      </div>
    </div>
  </div>);
}
window.ProgressView = ProgressView;
