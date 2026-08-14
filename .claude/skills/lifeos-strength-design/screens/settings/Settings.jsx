const { Card:SCard, Button:SBtn, Icon:SIcon, Chip:SChip, Badge:SBadge, SegmentedControl:SSeg, Switch:SSwitch, RadioGroup:SRadio, ListRow:SRow, ScreenHeader:SHeader, SyncBadge:SSync, ConfirmDialog:SConfirm, Banner:SBanner } = window.LifeOSStrengthDesignSystem_576cfb;

function Field({label, hint, children}){
  return (<div style={{padding:'12px 14px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)'}}>
    <div style={{fontSize:13,fontWeight:800,color:'var(--text-secondary)',marginBottom:10}}>{label}</div>
    {children}
    {hint && <div style={{fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)',marginTop:10}}>{hint}</div>}
  </div>);
}

function Stack({children, gap=8, style}){
  return <div style={{display:'flex',flexDirection:'column',gap,...style}}>{children}</div>;
}

function SettingsRoot(){
  return (<Screen><Bar/>
    <SHeader title="Settings" onBack={()=>{}}/>
    <Scroll style={{paddingTop:4}}>
      <SCard interactive style={{display:'flex',alignItems:'center',gap:12}}>
        <span style={{width:44,height:44,flex:'0 0 auto',borderRadius:'var(--radius-pill)',background:'var(--surface-inset)',display:'inline-flex',alignItems:'center',justifyContent:'center',fontFamily:'var(--font-numeric)',fontSize:15,fontWeight:800,color:'var(--text-secondary)'}}>MK</span>
        <span style={{flex:1,minWidth:0}}>
          <span style={{display:'block',fontSize:15,fontWeight:800}}>Mariusz Kowalski</span>
          <span style={{display:'block',fontSize:12,color:'var(--text-tertiary)',marginTop:2,overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}>marek@example.com</span>
        </span>
        <SIcon name="chevron-right" size={18} color="var(--text-tertiary)"/>
      </SCard>
      <div style={{display:'flex',alignItems:'center',gap:8,margin:'10px 2px 0'}}>
        <SSync state="queued"/>
        <span style={{fontSize:11,color:'var(--text-tertiary)'}}>2 workouts waiting · synced 2 minutes ago</span>
      </div>

      <Eyebrow>Preferences</Eyebrow>
      <Stack>
        <SRow icon="ruler" label="Units & display" value="kg · dark" onClick={()=>{}}/>
        <SRow icon="dumbbell" label="Workout defaults" value="1:30 rest" onClick={()=>{}}/>
        <SRow icon="bell" label="Notifications" value="Off" onClick={()=>{}}/>
        <SRow icon="refresh-cw" label="Data & sync" value="2 queued" onClick={()=>{}}/>
      </Stack>

      <Eyebrow>About</Eyebrow>
      <Stack>
        <SRow icon="smartphone" label="Version" value="1.0.0 (214)" chevron={false}/>
        <SRow icon="shield" label="Privacy policy" onClick={()=>{}}/>
        <SRow icon="file-text" label="Terms of use" onClick={()=>{}}/>
        <SRow icon="git-merge" label="Open-source licences" onClick={()=>{}}/>
      </Stack>

      <SBtn variant="ghost" block iconLeft="log-out" style={{color:'var(--feedback-danger)',marginTop:20}}>Sign out</SBtn>
      <div style={{fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)',textAlign:'center',marginTop:14}}>Settings is reached from your name on Home.<br/>It is not one of the five destinations.</div>
    </Scroll>
  </Screen>);
}

function SettingsAccount(){
  return (<Screen><Bar/>
    <SHeader title="Account" onBack={()=>{}}/>
    <Scroll style={{paddingTop:4}}>
      <Stack>
        <SRow label="Name" value="Mariusz Kowalski" onClick={()=>{}}/>
        <SRow label="Email" description="Used for sign-in and password reset" value="marek@example.com" onClick={()=>{}}/>
        <SRow label="Password" value="Change" onClick={()=>{}}/>
        <SRow label="Body weight" description="Used for volume on bodyweight exercises" value="78 kg" onClick={()=>{}}/>
      </Stack>

      <Eyebrow>Session</Eyebrow>
      <Stack>
        <SRow icon="clock" label="Signed in since" value="May 2, 2024" chevron={false}/>
        <SRow icon="log-out" label="Sign out" tone="danger" chevron={false} onClick={()=>{}}/>
      </Stack>

      <Eyebrow>This account</Eyebrow>
      <SRow icon="trash-2" label="Delete account" tone="danger" description="Removes 142 workouts and 2,568 sets from the server" chevron={false} onClick={()=>{}}/>
      <div style={{marginTop:16,padding:'12px 14px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)',fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)'}}>
        Email sign-in only in this version. Google and Apple sign-in are not available yet.
      </div>
    </Scroll>
  </Screen>);
}

function SettingsUnits(){
  return (<Screen><Bar/>
    <SHeader title="Units & display" onBack={()=>{}}/>
    <Scroll style={{paddingTop:4}}>
      <Stack gap={10}>
        <Field label="Weight" hint="Changing this converts every logged set on screen. Nothing is rewritten.">
          <SSeg options={['kg','lb']} value="kg"/>
        </Field>
        <Field label="Distance"><SSeg options={['km','mi']} value="km"/></Field>
        <Field label="First day of week"><SSeg options={['Monday','Sunday']} value="Monday"/></Field>
      </Stack>

      <Eyebrow>Theme</Eyebrow>
      <SRadio value="Dark" options={[
        {value:'System',label:'System',icon:'smartphone',description:'Follows your phone'},
        {value:'Dark',label:'Dark',icon:'moon',description:'Designed for gym lighting'},
        {value:'Light',label:'Light',icon:'sun',description:'Designed, not inverted'}]}/>

      <Eyebrow>Language</Eyebrow>
      <SRadio value="English" options={[
        {value:'English',label:'English',icon:'globe'},
        {value:'Polski',label:'Polski',icon:'globe',description:'Labels run longer; rows stay the same height'}]}/>

      <Eyebrow>Preview</Eyebrow>
      <SCard>
        <div style={{display:'flex',alignItems:'baseline',gap:8}}>
          <span style={{fontFamily:'var(--font-numeric)',fontVariantNumeric:'tabular-nums',fontSize:28,fontWeight:700,letterSpacing:'-.02em'}}>102.5</span>
          <span style={{fontSize:13,fontWeight:800,color:'var(--text-tertiary)'}}>kg</span>
          <span style={{marginLeft:'auto',fontFamily:'var(--font-numeric)',fontSize:13,color:'var(--text-secondary)'}}>Mon 12 May · 5.0 km</span>
        </div>
        <div style={{fontSize:11,color:'var(--text-tertiary)',marginTop:6}}>Bench Press · estimated 1RM</div>
      </SCard>
    </Scroll>
  </Screen>);
}

function SettingsWorkout(){
  return (<Screen><Bar/>
    <SHeader title="Workout defaults" onBack={()=>{}}/>
    <Scroll style={{paddingTop:4}}>
      <Field label="Default rest between sets" hint="Used by exercises that carry no rest value of their own.">
        <div style={{display:'flex',gap:8}}>
          <SChip>0:45</SChip><SChip>1:00</SChip><SChip selected>1:30</SChip><SChip>2:00</SChip><SChip>3:00</SChip>
        </div>
      </Field>
      <Stack style={{marginTop:8}}>
        <SRow icon="play" label="Start rest timer automatically" description="Starts when you confirm a set" control={<SSwitch checked label="Start rest timer automatically"/>}/>
        <SRow icon="bell" label="Alert when rest ends" description="Sound and vibration" control={<SSwitch label="Alert when rest ends"/>}/>
      </Stack>

      <Eyebrow>Set entry</Eyebrow>
      <Stack gap={10}>
        <Field label="Weight increment" hint="Sets the stepper step and the quick-pick chips.">
          <SSeg options={['1.25','2.5','5']} value="2.5"/>
        </Field>
        <SRow icon="dumbbell" label="Plate inventory" description="Quick picks are built from the plates you own" value="6 sizes" onClick={()=>{}}/>
        <SRow icon="history" label="Pre-fill from last session" description="Shown greyed, as a proposal until you confirm" control={<SSwitch checked label="Pre-fill from last session"/>}/>
        <SRow icon="trending-up" label="Count warm-up sets in volume" description="Off: warm-ups never affect volume or records" control={<SSwitch label="Count warm-up sets in volume"/>}/>
      </Stack>

      <Eyebrow>During a workout</Eyebrow>
      <Stack>
        <SRow icon="smartphone" label="Keep the screen awake" control={<SSwitch checked label="Keep the screen awake"/>}/>
        <SRow icon="clock" label="Finish automatically after" value="4 hours" onClick={()=>{}}/>
      </Stack>
    </Scroll>
  </Screen>);
}

function SettingsNotifications({blocked}){
  return (<Screen><Bar/>
    <SHeader title="Notifications" onBack={()=>{}}/>
    <Scroll style={{paddingTop:4}}>
      {blocked && <SBanner tone="warning" icon="bell-off" title="Turned off in system settings"
        description="Nothing can be sent until you allow notifications for this app."
        action={<SBtn size="sm" variant="secondary">Open</SBtn>} style={{marginBottom:12}}/>}
      <SRow icon="bell" label="Notifications" description={blocked?'Allowed in the app, blocked by the system':'Everything below depends on this'} control={<SSwitch checked label="Notifications"/>}/>
      <Eyebrow>During a workout</Eyebrow>
      <Stack>
        <SRow icon="clock" label="Rest timer ends" control={<SSwitch checked={!blocked} disabled={blocked} label="Rest timer ends"/>} />
        <SRow icon="cloud-off" label="A workout failed to sync" description="Never a toast only — the queue is on the surface too" control={<SSwitch checked={!blocked} disabled={blocked} label="A workout failed to sync"/>}/>
      </Stack>
      <Eyebrow>Weekly</Eyebrow>
      <Stack>
        <SRow icon="chart-column" label="Weekly summary" description="Sunday evening: volume, records, sessions" control={<SSwitch disabled={blocked} label="Weekly summary"/>}/>
        <SRow icon="calendar" label="Missed planned session" description="Not in this version" disabled control={<SBadge tone="neutral" size="sm">1.0.1</SBadge>}/>
      </Stack>
      <div style={{marginTop:16,padding:'12px 14px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)',fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)'}}>
        No notification ever asks you to train. The app only reports on work you have already done.
      </div>
    </Scroll>
  </Screen>);
}

function SettingsData(){
  return (<Screen><Bar/>
    <SHeader title="Data & sync" onBack={()=>{}}/>
    <Scroll style={{paddingTop:4}}>
      <SCard>
        <div style={{display:'flex',alignItems:'center',gap:8}}><SSync state="queued"/><span style={{fontSize:13,fontWeight:800}}>2 workouts waiting</span></div>
        <div style={{fontSize:12,lineHeight:'17px',color:'var(--text-secondary)',marginTop:8}}>Saved on this device. They upload as soon as there is a connection — nothing is lost.</div>
        <SBtn variant="secondary" block iconLeft="refresh-cw" style={{marginTop:12}}>Sync now</SBtn>
      </SCard>
      <Stack style={{marginTop:8}}>
        <SRow icon="clock" label="Last synced" value="2 minutes ago" chevron={false}/>
        <SRow icon="git-merge" label="Waiting to upload" description="Jun 12 · Jun 10" value="2 workouts" onClick={()=>{}}/>
        <SRow icon="signal" label="Sync over mobile data" description="Off: uploads wait for Wi-Fi" control={<SSwitch checked label="Sync over mobile data"/>}/>
      </Stack>

      <Eyebrow>On this device</Eyebrow>
      <Stack>
        <SRow icon="smartphone" label="Local data" value="1.2 MB" chevron={false}/>
        <SRow icon="download" label="Export as CSV" description="Not in this version" disabled control={<SBadge tone="neutral" size="sm">1.0.1</SBadge>}/>
        <SRow icon="trash-2" label="Delete local data" tone="danger" description="Server data stays. Anything still queued is lost." chevron={false} onClick={()=>{}}/>
      </Stack>
      <div style={{marginTop:16,padding:'12px 14px',background:'var(--surface-card)',border:'1px solid var(--border-subtle)',borderRadius:'var(--radius-md)',fontSize:11,lineHeight:'16px',color:'var(--text-tertiary)'}}>
        Logging never waits for the network. A set is on this device the moment you confirm it, and on the server when the badge says so.
      </div>
    </Scroll>
  </Screen>);
}

function SignOutConfirm(){
  return (<Screen><Bar/>
    <SHeader title="Settings" onBack={()=>{}}/>
    <Scroll style={{paddingTop:4,opacity:.5}}>
      <Stack><SRow icon="ruler" label="Units & display" value="kg · dark"/><SRow icon="dumbbell" label="Workout defaults" value="1:30 rest"/><SRow icon="bell" label="Notifications" value="Off"/><SRow icon="refresh-cw" label="Data & sync" value="2 queued"/></Stack>
    </Scroll>
    <Overlay>
      <SConfirm title="Sign out?" description="2 workouts are still waiting to upload."
        recovery="They stay on this device and upload when you sign back in on this phone. Deleting the app first loses them."
        confirmLabel="Sign out anyway" cancelLabel="Stay signed in"/>
    </Overlay>
  </Screen>);
}

function DeleteAccountConfirm(){
  return (<Screen><Bar/>
    <SHeader title="Account" onBack={()=>{}}/>
    <Scroll style={{paddingTop:4,opacity:.5}}>
      <Stack><SRow label="Name" value="Mariusz Kowalski"/><SRow label="Email" value="marek@example.com"/><SRow label="Password" value="Change"/></Stack>
    </Scroll>
    <Overlay>
      <SConfirm title="Delete your account?"
        description="142 workouts, 2,568 sets and every record are removed from the server and from this device."
        recovery="Nothing can be recovered, and export is not available in this version. Type your email to confirm."
        confirmLabel="Delete account" cancelLabel="Keep my account"/>
    </Overlay>
  </Screen>);
}

Object.assign(window,{SettingsRoot,SettingsAccount,SettingsUnits,SettingsWorkout,SettingsNotifications,SettingsData,SignOutConfirm,DeleteAccountConfirm});
