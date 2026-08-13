const { Button: SButton, Input: SInput } = window.LifeOSStrengthDesignSystem_576cfb;

function SignInScreen({onSignIn}){
  const [err,setErr]=React.useState(false);
  return (<div className="screen">
    <div style={{position:'relative',height:300,flex:'0 0 auto'}}>
      <img src="../../assets/imagery/hero-dumbbell.png" alt="" style={{width:'100%',height:'100%',objectFit:'cover',objectPosition:'62% 26%'}}/>
      <div style={{position:'absolute',inset:0,background:'var(--scrim-strong)'}}/>
      <div style={{position:'absolute',left:20,right:20,bottom:18}}>
        <div style={{fontFamily:'var(--font-display)',fontSize:34,lineHeight:'38px',fontWeight:800,letterSpacing:'-.03em'}}>LifeOS<span style={{color:'var(--action-primary)'}}>.</span></div>
        <div style={{marginTop:6,fontSize:14,color:'var(--ink-200)'}}>A fast, trustworthy ledger for the gym.</div>
      </div>
    </div>
    <div className="scroll" style={{paddingTop:24}}>
      <div style={{display:'flex',flexDirection:'column',gap:14}}>
        <SInput label="Email" icon="mail" placeholder="marek@example.com" defaultValue="marek@example.com"/>
        <SInput label="Password" icon="lock" type="password" defaultValue="trening123" error={err?'Incorrect email or password':undefined}/>
        <SButton variant="primary" size="lg" block uppercase onClick={onSignIn} style={{marginTop:4}}>Sign in</SButton>
        <button onClick={()=>setErr(!err)} style={{background:'none',border:'none',color:'var(--text-secondary)',fontSize:13,fontWeight:700,cursor:'pointer',padding:'6px 0'}}>Forgot password?</button>
        <div style={{textAlign:'center',fontSize:13,color:'var(--text-tertiary)',marginTop:4}}>No account? <a href="#" onClick={(e)=>e.preventDefault()}>Create one</a></div>
      </div>
      <p style={{marginTop:28,fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)',textAlign:'center'}}>Email and password only in v1.0 — Google and Apple sign-in arrive in v1.0.1.</p>
    </div>
  </div>);
}
window.SignInScreen = SignInScreen;
