const { BottomNav: ABottomNav } = window.LifeOSStrengthDesignSystem_576cfb;

function App(){
  const [signed,setSigned]=React.useState(false);
  const [tab,setTab]=React.useState('home');
  const [view,setView]=React.useState('home');

  if(!signed) return <SignInScreen onSignIn={()=>setSigned(true)}/>;

  let screen;
  if(view==='workout') screen=<WorkoutScreen onBack={()=>{setView('home');setTab('home');}} onComplete={()=>setView('summary')}/>;
  else if(view==='summary') screen=<SummaryScreen onDone={()=>{setView('home');setTab('home');}}/>;
  else if(tab==='exercises') screen=<ExercisesScreen/>;
  else if(tab==='progress') screen=<ProgressScreen/>;
  else screen=<HomeScreen queued onRepeat={()=>{setView('workout');setTab('workout');}} onStart={()=>{setView('workout');setTab('workout');}}/>;

  const hideNav = view==='summary';
  return (<div style={{position:'absolute',inset:0,display:'flex',flexDirection:'column'}}>
    <div style={{position:'relative',flex:1,minHeight:0}}>{screen}</div>
    {!hideNav && <ABottomNav active={tab} onSelect={(k)=>{setTab(k);setView(k==='workout'?'workout':'home');}} onAdd={()=>{setView('workout');setTab('workout');}}/>}
  </div>);
}
ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
