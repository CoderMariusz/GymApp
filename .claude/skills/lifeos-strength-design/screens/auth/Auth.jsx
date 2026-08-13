const { Button:ABtn, Input:AInput, Icon:AIcon, Card:ACard, ScreenHeader:AHeader, Badge:ABadge } = window.LifeOSStrengthDesignSystem_576cfb;

function AuthShell({title, lead, children, back, hero='hero-dumbbell.png', tight}){
  return (<Screen>
    <div style={{position:'relative',height:tight?190:250,flex:'0 0 auto'}}>
      <img src={'../../assets/imagery/'+hero} alt="" style={{width:'100%',height:'100%',objectFit:'cover',objectPosition:'62% 26%'}}/>
      <div style={{position:'absolute',inset:0,background:'var(--scrim-strong)'}}/>
      <div style={{position:'absolute',top:0,left:0,right:0}}><Bar onPhoto/></div>
      {back && <button aria-label="Back" style={{position:'absolute',top:52,left:10,width:44,height:44,background:'transparent',border:'none',color:'#fff',cursor:'pointer'}}><AIcon name="chevron-left" size={24}/></button>}
      <div style={{position:'absolute',left:20,right:20,bottom:16}}>
        <div style={{fontFamily:'var(--font-display)',fontSize:26,fontWeight:800,letterSpacing:'-.03em',color:'#fff'}}>{title}</div>
        {lead && <div style={{marginTop:6,fontSize:13,lineHeight:'18px',color:'var(--ink-200)',maxWidth:300}}>{lead}</div>}
      </div>
    </div>
    <Scroll style={{paddingTop:22}}>{children}</Scroll>
  </Screen>);
}

function SignUp({invalid, taken, success}){
  if(success) return (<AuthShell tight title="Check your email" lead="We sent a confirmation link to marek@example.com. Open it to finish creating your account." hero="hero-back-rack.png">
    <div style={{display:'flex',flexDirection:'column',gap:14}}>
      <ACard>
        <div style={{display:'flex',gap:12,alignItems:'flex-start'}}>
          <span style={{width:36,height:36,flex:'0 0 auto',borderRadius:999,background:'var(--feedback-success-quiet)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><AIcon name="mail-check" size={18} color="var(--feedback-success)"/></span>
          <div>
            <div style={{fontSize:14,fontWeight:800}}>Link sent</div>
            <div style={{fontSize:12,color:'var(--text-tertiary)',marginTop:3,lineHeight:'17px'}}>It expires in 60 minutes. Nothing else is needed on this device.</div>
          </div>
        </div>
      </ACard>
      <ABtn variant="secondary" block>Resend link</ABtn>
      <ABtn variant="ghost" block>Use a different email</ABtn>
    </div>
  </AuthShell>);
  return (<AuthShell back title="Create your account" lead="Email and password only. Your workouts stay on this device until you are online." hero="hero-back-rack.png">
    <div style={{display:'flex',flexDirection:'column',gap:14}}>
      <AInput label="Email" icon="mail" defaultValue={taken?'marek@example.com':invalid?'marek@example':'marek@example.com'}
        error={taken?'That email already has an account':invalid?'Enter a valid email address':undefined}/>
      <AInput label="Password" icon="lock" type="password" defaultValue={invalid?'123':'trening123'}
        hint={invalid?undefined:'At least 8 characters'} error={invalid?'Use at least 8 characters':undefined}/>
      {taken && <ABtn variant="secondary" block iconLeft="log-in">Sign in instead</ABtn>}
      <ABtn variant="primary" size="lg" block uppercase disabled={invalid}>Create account</ABtn>
      <p style={{margin:'6px 0 0',fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)',textAlign:'center'}}>
        By creating an account you accept the terms and the privacy notice. You can export or delete everything at any time.
      </p>
      <div style={{textAlign:'center',fontSize:13,color:'var(--text-tertiary)',marginTop:6}}>Already have an account? <a href="#" onClick={(e)=>e.preventDefault()}>Sign in</a></div>
    </div>
  </AuthShell>);
}

function Reset({stage='request'}){
  if(stage==='sent') return (<AuthShell tight back title="Check your email" lead="If an account exists for marek@example.com, a reset link is on its way." hero="hero-core-front.png">
    <ACard>
      <div style={{display:'flex',gap:12,alignItems:'flex-start'}}>
        <span style={{width:36,height:36,flex:'0 0 auto',borderRadius:999,background:'var(--surface-inset)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><AIcon name="clock" size={18} color="var(--text-secondary)"/></span>
        <div>
          <div style={{fontSize:14,fontWeight:800}}>The link expires in 60 minutes</div>
          <div style={{fontSize:12,color:'var(--text-tertiary)',marginTop:3,lineHeight:'17px'}}>We do not say whether an account exists — that would leak who is registered.</div>
        </div>
      </div>
    </ACard>
    <ABtn variant="secondary" block style={{marginTop:14}}>Resend link</ABtn>
    <ABtn variant="ghost" block style={{marginTop:8}}>Back to sign in</ABtn>
  </AuthShell>);

  if(stage==='new') return (<AuthShell tight title="Set a new password" lead="You are signed out on every other device once this is saved." hero="hero-core-front.png">
    <div style={{display:'flex',flexDirection:'column',gap:14}}>
      <AInput label="New password" icon="lock" type="password" defaultValue="treningmocny" hint="At least 8 characters"/>
      <AInput label="Repeat password" icon="lock" type="password" defaultValue="treningmocny"/>
      <ABtn variant="primary" size="lg" block uppercase>Save password</ABtn>
    </div>
  </AuthShell>);

  if(stage==='expired') return (<AuthShell tight title="This link has expired" lead="Reset links last 60 minutes. Request a new one and it will work straight away." hero="hero-core-front.png">
    <ACard tone="default">
      <div style={{display:'flex',gap:12,alignItems:'flex-start'}}>
        <span style={{width:36,height:36,flex:'0 0 auto',borderRadius:999,background:'var(--feedback-warning-quiet)',display:'inline-flex',alignItems:'center',justifyContent:'center'}}><AIcon name="link-2-off" size={18} color="var(--feedback-warning)"/></span>
        <div>
          <div style={{fontSize:14,fontWeight:800}}>Nothing was changed</div>
          <div style={{fontSize:12,color:'var(--text-tertiary)',marginTop:3,lineHeight:'17px'}}>Your current password still works and your workouts are untouched.</div>
        </div>
      </div>
    </ACard>
    <ABtn variant="primary" size="lg" block uppercase style={{marginTop:14}}>Request a new link</ABtn>
    <ABtn variant="ghost" block style={{marginTop:8}}>Back to sign in</ABtn>
  </AuthShell>);

  return (<AuthShell back tight title="Reset your password" lead="Enter the email you signed up with and we'll send a link." hero="hero-core-front.png">
    <div style={{display:'flex',flexDirection:'column',gap:14}}>
      <AInput label="Email" icon="mail" defaultValue="marek@example.com"/>
      <ABtn variant="primary" size="lg" block uppercase>Send reset link</ABtn>
      <ABtn variant="ghost" block>Back to sign in</ABtn>
    </div>
  </AuthShell>);
}
Object.assign(window,{SignUp,Reset,AuthShell});
