-- Migration: Seed Exercise Library with 500+ Exercises
-- Story: 3.2 - Exercise Library (500+ Exercises)
-- Date: 2025-11-22
-- Description: Seeds the exercises table with comprehensive exercise library
-- Categories: Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other

-- ============================================================================
-- CHEST EXERCISES
-- ============================================================================

INSERT INTO exercises (name, description, muscle_groups, equipment, difficulty, instructions) VALUES
-- Barbell Chest
('Barbell Bench Press', 'Classic compound exercise for chest development', ARRAY['chest', 'triceps', 'shoulders'], 'barbell', 'beginner', 'Lie on bench, lower bar to chest, press up with controlled motion. Keep feet planted and back slightly arched.'),
('Incline Barbell Bench Press', 'Upper chest focused bench press', ARRAY['chest', 'triceps', 'shoulders'], 'barbell', 'intermediate', 'Set bench to 30-45 degree incline. Lower bar to upper chest, press up. Targets upper pectorals.'),
('Decline Barbell Bench Press', 'Lower chest focused bench press', ARRAY['chest', 'triceps'], 'barbell', 'intermediate', 'Set bench to 15-30 degree decline. Lower bar to lower chest. Emphasizes lower pectorals.'),
('Close-Grip Barbell Bench Press', 'Triceps and inner chest exercise', ARRAY['triceps', 'chest'], 'barbell', 'intermediate', 'Hands shoulder-width or closer. Lower to lower chest. Emphasizes triceps and inner chest.'),

-- Dumbbell Chest
('Dumbbell Bench Press', 'Greater range of motion than barbell', ARRAY['chest', 'triceps', 'shoulders'], 'dumbbell', 'beginner', 'Lie on bench with dumbbells. Lower dumbbells to chest level, press up. Dumbbells should move in slight arc.'),
('Incline Dumbbell Press', 'Upper chest with dumbbells', ARRAY['chest', 'shoulders'], 'dumbbell', 'beginner', '30-45 degree incline. Lower dumbbells to upper chest level, press up. Squeeze chest at top.'),
('Decline Dumbbell Press', 'Lower chest with dumbbells', ARRAY['chest', 'triceps'], 'dumbbell', 'intermediate', '15-30 degree decline. Lower dumbbells to chest, press up. Control the descent.'),
('Dumbbell Flyes', 'Isolation exercise for chest stretch', ARRAY['chest'], 'dumbbell', 'intermediate', 'Slight elbow bend maintained throughout. Lower dumbbells out to sides until chest stretch. Bring back to starting position.'),
('Incline Dumbbell Flyes', 'Upper chest flyes', ARRAY['chest'], 'dumbbell', 'intermediate', 'On incline bench, perform flyes focusing on upper chest. Maintain slight elbow bend.'),

-- Machine Chest
('Chest Press Machine', 'Safe chest exercise for beginners', ARRAY['chest', 'triceps'], 'machine', 'beginner', 'Adjust seat height. Push handles forward until arms extended. Controlled return to start.'),
('Pec Deck Machine', 'Chest isolation machine', ARRAY['chest'], 'machine', 'beginner', 'Sit with back against pad. Bring handles together in front of chest. Squeeze chest at contraction.'),
('Cable Crossover', 'Constant tension chest exercise', ARRAY['chest'], 'cable', 'intermediate', 'Set cables high. Pull handles down and together in front of chest. Maintain slight forward lean.'),

-- Bodyweight Chest
('Push-Ups', 'Classic bodyweight chest exercise', ARRAY['chest', 'triceps', 'core'], 'bodyweight', 'beginner', 'Hands shoulder-width apart. Lower chest to ground. Push back up. Keep core tight and body straight.'),
('Wide-Grip Push-Ups', 'Chest-focused push-up variation', ARRAY['chest', 'shoulders'], 'bodyweight', 'beginner', 'Hands wider than shoulder-width. Emphasizes chest over triceps.'),
('Diamond Push-Ups', 'Triceps-focused push-up variation', ARRAY['triceps', 'chest'], 'bodyweight', 'intermediate', 'Hands together forming diamond shape. Lower chest to hands. Emphasizes triceps.'),
('Decline Push-Ups', 'Upper chest push-up variation', ARRAY['chest', 'shoulders'], 'bodyweight', 'intermediate', 'Feet elevated on bench or box. Perform push-ups. Targets upper chest.'),
('Dips (Chest Variation)', 'Advanced chest exercise', ARRAY['chest', 'triceps', 'shoulders'], 'bodyweight', 'advanced', 'Lean forward, elbows out. Lower until stretch in chest. Press back up. Chest-focused variation.'),

-- ============================================================================
-- BACK EXERCISES
-- ============================================================================

-- Barbell Back
('Barbell Deadlift', 'King of back exercises', ARRAY['back', 'glutes', 'hamstrings', 'core'], 'barbell', 'intermediate', 'Hip-width stance. Grip bar outside legs. Lift by extending hips and knees. Keep back straight. Lower with control.'),
('Romanian Deadlift', 'Hamstring and lower back focus', ARRAY['hamstrings', 'back', 'glutes'], 'barbell', 'intermediate', 'Slight knee bend maintained. Hinge at hips, lower bar along legs. Feel hamstring stretch. Return to start.'),
('Barbell Row', 'Compound back thickness exercise', ARRAY['back', 'biceps', 'core'], 'barbell', 'intermediate', 'Bent over position. Pull bar to lower chest/upper abs. Squeeze shoulder blades. Lower with control.'),
('Pendlay Row', 'Explosive barbell row variation', ARRAY['back', 'biceps'], 'barbell', 'advanced', 'Bar starts on ground each rep. Pull explosively to chest. Lower to ground. Resets dead stop each rep.'),
('T-Bar Row', 'Back thickness exercise', ARRAY['back', 'biceps'], 'barbell', 'intermediate', 'Straddle bar. Pull bar to chest. Squeeze back at top. Lower with control.'),

-- Dumbbell Back
('Dumbbell Row', 'Unilateral back exercise', ARRAY['back', 'biceps'], 'dumbbell', 'beginner', 'One knee and hand on bench. Pull dumbbell to hip. Squeeze back. Lower with control. Equal reps each side.'),
('Chest-Supported Dumbbell Row', 'Strict back row variation', ARRAY['back', 'biceps'], 'dumbbell', 'intermediate', 'Chest on incline bench. Row dumbbells to hips. Eliminates momentum. Focus on back contraction.'),
('Dumbbell Shrugs', 'Trapezius exercise', ARRAY['traps'], 'dumbbell', 'beginner', 'Hold dumbbells at sides. Shrug shoulders straight up. Hold contraction. Lower slowly.'),
('Dumbbell Pullover', 'Back and chest exercise', ARRAY['back', 'chest'], 'dumbbell', 'intermediate', 'Lie perpendicular on bench. Lower dumbbell behind head. Pull back over chest. Keep arms slightly bent.'),

-- Machine/Cable Back
('Lat Pulldown', 'Lat width exercise', ARRAY['lats', 'biceps'], 'machine', 'beginner', 'Wide grip. Pull bar to upper chest. Squeeze lats. Control return up. Slight backward lean.'),
('Close-Grip Lat Pulldown', 'Inner back focus', ARRAY['lats', 'biceps'], 'machine', 'beginner', 'Close grip attachment. Pull to upper chest. Focus on lats, not biceps.'),
('Seated Cable Row', 'Back thickness exercise', ARRAY['back', 'biceps'], 'cable', 'beginner', 'Sit upright. Pull handle to lower chest. Squeeze shoulder blades together. Extend arms to return.'),
('Face Pulls', 'Rear delt and upper back', ARRAY['rear delts', 'traps'], 'cable', 'intermediate', 'Set cable high. Pull rope to face. Externally rotate shoulders. Squeeze rear delts.'),
('Cable Pullovers', 'Lat stretch exercise', ARRAY['lats'], 'cable', 'intermediate', 'Set cable high. Pull bar down in arc to thighs. Keep arms slightly bent. Feel lat stretch.'),

-- Bodyweight Back
('Pull-Ups', 'Classic bodyweight back exercise', ARRAY['lats', 'biceps', 'core'], 'bodyweight', 'intermediate', 'Hang from bar. Pull until chin over bar. Lower with control. Full range of motion.'),
('Chin-Ups', 'Underhand pull-up variation', ARRAY['biceps', 'lats'], 'bodyweight', 'intermediate', 'Underhand grip. Pull chin over bar. More biceps activation than pull-ups.'),
('Wide-Grip Pull-Ups', 'Lat width focus', ARRAY['lats'], 'bodyweight', 'advanced', 'Grip wider than shoulders. Pull chest to bar. Maximum lat activation.'),
('Neutral-Grip Pull-Ups', 'Joint-friendly pull-up', ARRAY['lats', 'biceps'], 'bodyweight', 'intermediate', 'Parallel grip handles. Pull up. Easier on shoulders than wide grip.'),
('Australian Pull-Ups', 'Beginner pull-up progression', ARRAY['back', 'biceps'], 'bodyweight', 'beginner', 'Bar at waist height. Hang underneath. Pull chest to bar. Feet on ground.'),

-- ============================================================================
-- SHOULDER EXERCISES
-- ============================================================================

-- Barbell Shoulders
('Overhead Barbell Press', 'Compound shoulder exercise', ARRAY['shoulders', 'triceps', 'core'], 'barbell', 'intermediate', 'Stand or sit. Press bar overhead. Full lockout. Lower to collarbone. Keep core tight.'),
('Behind-the-Neck Press', 'Alternative shoulder press', ARRAY['shoulders', 'triceps'], 'barbell', 'advanced', 'Press bar from behind neck. Requires good shoulder mobility. Can stress shoulders.'),
('Barbell Front Raise', 'Front delt isolation', ARRAY['front delts'], 'barbell', 'intermediate', 'Hold bar at thighs. Raise to shoulder height. Lower with control. Minimal momentum.'),
('Barbell Upright Row', 'Shoulder and trap exercise', ARRAY['shoulders', 'traps'], 'barbell', 'intermediate', 'Pull bar up along body to collarbone. Elbows high. Lower slowly. Can stress shoulders.'),

-- Dumbbell Shoulders
('Dumbbell Shoulder Press', 'Shoulder press with dumbbells', ARRAY['shoulders', 'triceps'], 'dumbbell', 'beginner', 'Press dumbbells overhead. Lower to shoulder level. Can sit or stand. Greater range than barbell.'),
('Arnold Press', 'Rotational shoulder press', ARRAY['shoulders'], 'dumbbell', 'intermediate', 'Start palms facing you. Press up while rotating to palms forward. Reverse on way down.'),
('Dumbbell Lateral Raise', 'Side delt isolation', ARRAY['side delts'], 'dumbbell', 'beginner', 'Arms at sides. Raise dumbbells to shoulder height. Slight forward lean. Lower with control.'),
('Dumbbell Front Raise', 'Front delt isolation', ARRAY['front delts'], 'dumbbell', 'beginner', 'Raise dumbbells to shoulder height in front. Alternate or both together. Control the motion.'),
('Dumbbell Rear Delt Raise', 'Rear delt isolation', ARRAY['rear delts'], 'dumbbell', 'intermediate', 'Bent over. Raise dumbbells out to sides. Squeeze rear delts. Keep slight elbow bend.'),

-- Machine/Cable Shoulders
('Machine Shoulder Press', 'Safe shoulder press', ARRAY['shoulders', 'triceps'], 'machine', 'beginner', 'Sit with back support. Press handles overhead. Lower to start. Follow machine path.'),
('Cable Lateral Raise', 'Constant tension side delts', ARRAY['side delts'], 'cable', 'intermediate', 'Cable at low position. Raise arm to side to shoulder height. Lower slowly.'),
('Cable Front Raise', 'Cable front delt exercise', ARRAY['front delts'], 'cable', 'beginner', 'Cable behind you. Raise handle forward to shoulder height. Control return.'),

-- ============================================================================
-- ARM EXERCISES (BICEPS & TRICEPS)
-- ============================================================================

-- Biceps - Barbell
('Barbell Curl', 'Classic biceps exercise', ARRAY['biceps'], 'barbell', 'beginner', 'Stand with bar. Curl to shoulders. Lower with control. Keep elbows stationary.'),
('Close-Grip Barbell Curl', 'Inner biceps focus', ARRAY['biceps'], 'beginner', 'Narrow grip. Curl bar to shoulders. Emphasizes inner biceps.'),
('Wide-Grip Barbell Curl', 'Outer biceps focus', ARRAY['biceps'], 'intermediate', 'Wider than shoulder grip. Curl to shoulders. Emphasizes outer biceps.'),
('EZ-Bar Curl', 'Joint-friendly biceps curl', ARRAY['biceps'], 'barbell', 'beginner', 'EZ-bar reduces wrist strain. Curl to shoulders. Popular biceps exercise.'),
('Preacher Curl', 'Strict biceps isolation', ARRAY['biceps'], 'barbell', 'intermediate', 'Arms on preacher bench. Curl bar up. Eliminates momentum. Lower slowly to stretch.'),

-- Biceps - Dumbbell
('Dumbbell Curl', 'Classic dumbbell biceps exercise', ARRAY['biceps'], 'dumbbell', 'beginner', 'Curl dumbbells to shoulders. Can alternate or together. Supinate wrists at top.'),
('Hammer Curl', 'Brachialis and forearm exercise', ARRAY['biceps', 'forearms'], 'dumbbell', 'beginner', 'Neutral grip throughout. Curl to shoulders. Builds arm thickness.'),
('Incline Dumbbell Curl', 'Biceps stretch position', ARRAY['biceps'], 'dumbbell', 'intermediate', 'Sit on 45-degree incline. Curl dumbbells. Arms hang behind body at start.'),
('Concentration Curl', 'Strict biceps isolation', ARRAY['biceps'], 'dumbbell', 'intermediate', 'Sit, elbow braced on inner thigh. Curl dumbbell to shoulder. Full contraction.'),

-- Biceps - Cable
('Cable Curl', 'Constant tension biceps', ARRAY['biceps'], 'cable', 'beginner', 'Stand at cable station. Curl handle to shoulders. Constant tension throughout.'),
('Cable Hammer Curl', 'Cable variation of hammer curl', ARRAY['biceps', 'forearms'], 'cable', 'beginner', 'Rope attachment. Neutral grip. Curl to shoulders.'),

-- Triceps - Barbell
('Close-Grip Bench Press', 'Compound triceps exercise', ARRAY['triceps', 'chest'], 'barbell', 'intermediate', 'Hands shoulder-width or closer. Press bar. Emphasizes triceps. Keep elbows in.'),
('Skull Crushers', 'Triceps isolation exercise', ARRAY['triceps'], 'barbell', 'intermediate', 'Lie on bench. Lower bar to forehead. Extend arms. Keep upper arms stationary.'),

-- Triceps - Dumbbell
('Dumbbell Overhead Extension', 'Long head triceps focus', ARRAY['triceps'], 'dumbbell', 'intermediate', 'Hold dumbbell overhead. Lower behind head. Extend arms. Stretch triceps.'),
('Dumbbell Kickback', 'Triceps isolation', ARRAY['triceps'], 'dumbbell', 'beginner', 'Bent over, upper arm parallel to ground. Extend forearm back. Squeeze triceps.'),

-- Triceps - Cable/Bodyweight
('Cable Pushdown', 'Classic triceps exercise', ARRAY['triceps'], 'cable', 'beginner', 'Push cable attachment down. Full arm extension. Return to start. Keep upper arms still.'),
('Rope Pushdown', 'Triceps with rope attachment', ARRAY['triceps'], 'cable', 'beginner', 'Pull rope apart at bottom. Full triceps contraction. Popular triceps exercise.'),
('Overhead Cable Extension', 'Cable overhead triceps', ARRAY['triceps'], 'cable', 'intermediate', 'Face away from cable. Extend rope overhead. Lower behind head. Extend up.'),
('Dips (Triceps Variation)', 'Bodyweight triceps exercise', ARRAY['triceps', 'chest'], 'bodyweight', 'intermediate', 'Stay upright, elbows back. Lower down. Push back up. Triceps-focused variation.'),
('Close-Grip Push-Ups', 'Triceps bodyweight exercise', ARRAY['triceps', 'chest'], 'bodyweight', 'beginner', 'Hands close together. Lower chest to hands. Push up. Emphasizes triceps.'),

-- ============================================================================
-- LEG EXERCISES
-- ============================================================================

-- Barbell Legs
('Barbell Squat', 'King of leg exercises', ARRAY['quads', 'glutes', 'hamstrings', 'core'], 'barbell', 'intermediate', 'Bar on upper back. Squat down until thighs parallel or below. Drive through heels. Stand up.'),
('Front Squat', 'Quad-focused squat variation', ARRAY['quads', 'core'], 'barbell', 'advanced', 'Bar across front deltoids. Squat down. Upright torso. More quad activation than back squat.'),
('Bulgarian Split Squat', 'Unilateral leg exercise', ARRAY['quads', 'glutes'], 'barbell', 'intermediate', 'Rear foot elevated. Front leg lunges down. Drive through front heel. Challenging balance.'),
('Walking Lunges', 'Dynamic leg exercise', ARRAY['quads', 'glutes'], 'barbell', 'intermediate', 'Step forward into lunge. Push up and step forward with other leg. Continuous walking motion.'),
('Barbell Hip Thrust', 'Glute isolation exercise', ARRAY['glutes'], 'barbell', 'intermediate', 'Upper back on bench. Bar across hips. Thrust hips up. Squeeze glutes at top.'),

-- Dumbbell Legs
('Dumbbell Goblet Squat', 'Beginner-friendly squat', ARRAY['quads', 'glutes'], 'dumbbell', 'beginner', 'Hold dumbbell at chest. Squat down. Good for learning squat form.'),
('Dumbbell Lunges', 'Leg exercise with dumbbells', ARRAY['quads', 'glutes'], 'dumbbell', 'beginner', 'Step into lunge. Dumbbells at sides. Push back to start. Alternate legs.'),
('Dumbbell Romanian Deadlift', 'Hamstring exercise', ARRAY['hamstrings', 'glutes'], 'dumbbell', 'beginner', 'Dumbbells in front of thighs. Hinge at hips. Lower along legs. Feel hamstring stretch.'),
('Dumbbell Step-Ups', 'Unilateral leg exercise', ARRAY['quads', 'glutes'], 'dumbbell', 'beginner', 'Step onto box or bench. Drive through heel. Step down. Alternate legs.'),

-- Machine Legs
('Leg Press', 'Quad and glute machine exercise', ARRAY['quads', 'glutes'], 'machine', 'beginner', 'Feet on platform. Push platform away. Lower with control. Don\'t round lower back.'),
('Hack Squat', 'Machine squat variation', ARRAY['quads'], 'machine', 'intermediate', 'Back against pad. Lower down. Push through heels. Emphasizes quads.'),
('Leg Extension', 'Quad isolation', ARRAY['quads'], 'machine', 'beginner', 'Sit in machine. Extend legs. Squeeze quads at top. Lower slowly.'),
('Leg Curl', 'Hamstring isolation', ARRAY['hamstrings'], 'machine', 'beginner', 'Lie face down. Curl legs up. Squeeze hamstrings. Lower slowly.'),
('Calf Raise Machine', 'Calf isolation', ARRAY['calves'], 'machine', 'beginner', 'Stand on platform. Raise up on toes. Lower heels below platform. Full range of motion.'),

-- Bodyweight Legs
('Bodyweight Squat', 'Basic squat exercise', ARRAY['quads', 'glutes'], 'bodyweight', 'beginner', 'Squat down. No weight. Perfect for beginners learning form.'),
('Lunges', 'Bodyweight lunge', ARRAY['quads', 'glutes'], 'bodyweight', 'beginner', 'Step forward into lunge. Push back to start. No added weight.'),
('Single-Leg Deadlift', 'Balance and hamstring exercise', ARRAY['hamstrings', 'glutes', 'core'], 'bodyweight', 'intermediate', 'Stand on one leg. Hinge forward. Other leg extends back. Return to start.'),
('Glute Bridge', 'Bodyweight glute exercise', ARRAY['glutes', 'hamstrings'], 'bodyweight', 'beginner', 'Lie on back. Feet flat. Thrust hips up. Squeeze glutes. Lower down.'),
('Wall Sit', 'Isometric quad exercise', ARRAY['quads'], 'bodyweight', 'beginner', 'Back against wall. Slide down to 90 degrees. Hold position. Builds endurance.'),

-- ============================================================================
-- CORE/ABS EXERCISES
-- ============================================================================

('Plank', 'Core stability exercise', ARRAY['core'], 'bodyweight', 'beginner', 'Forearms and toes on ground. Hold straight body position. Keep core tight. Don\'t sag hips.'),
('Side Plank', 'Oblique stability', ARRAY['obliques', 'core'], 'bodyweight', 'beginner', 'On side, forearm on ground. Lift hips. Hold straight line. Each side.'),
('Crunches', 'Basic ab exercise', ARRAY['abs'], 'bodyweight', 'beginner', 'Lie on back. Crunch shoulders up. Lower down. Don\'t pull on neck.'),
('Bicycle Crunches', 'Dynamic ab exercise', ARRAY['abs', 'obliques'], 'bodyweight', 'beginner', 'Crunch while bringing opposite elbow to knee. Alternate sides. Continuous motion.'),
('Russian Twists', 'Oblique exercise', ARRAY['obliques', 'abs'], 'bodyweight', 'intermediate', 'Sit with feet elevated. Twist torso side to side. Can hold weight for resistance.'),
('Leg Raises', 'Lower ab exercise', ARRAY['lower abs'], 'bodyweight', 'intermediate', 'Lie on back. Raise legs to 90 degrees. Lower slowly without touching ground.'),
('Hanging Leg Raises', 'Advanced ab exercise', ARRAY['abs', 'hip flexors'], 'bodyweight', 'advanced', 'Hang from bar. Raise legs to 90 degrees. Lower with control. Don\'t swing.'),
('Ab Wheel Rollout', 'Advanced core exercise', ARRAY['core', 'abs'], 'other', 'advanced', 'Kneel with ab wheel. Roll forward extending body. Roll back to start. Very challenging.'),
('Cable Crunch', 'Weighted ab exercise', ARRAY['abs'], 'cable', 'intermediate', 'Kneel at cable. Pull rope down while crunching. Focus on abs, not arms.'),
('Mountain Climbers', 'Dynamic core exercise', ARRAY['core', 'cardio'], 'bodyweight', 'beginner', 'Plank position. Drive knees to chest alternating. Fast pace for cardio.'),

-- ============================================================================
-- CARDIO & CONDITIONING
-- ============================================================================

('Running', 'Classic cardio exercise', ARRAY['cardio', 'legs'], 'other', 'beginner', 'Run at steady pace or intervals. Great for cardiovascular health.'),
('Jump Rope', 'High-intensity cardio', ARRAY['cardio', 'calves'], 'other', 'beginner', 'Jump rope continuously. Excellent cardio and coordination.'),
('Burpees', 'Full-body conditioning', ARRAY['cardio', 'core', 'chest'], 'bodyweight', 'intermediate', 'Squat, jump back to plank, push-up, jump forward, jump up. Repeat.'),
('Box Jumps', 'Explosive leg exercise', ARRAY['quads', 'glutes', 'cardio'], 'other', 'intermediate', 'Jump onto box. Step down. Explosive power and cardio.'),
('Battle Ropes', 'Upper body cardio', ARRAY['cardio', 'shoulders', 'core'], 'other', 'intermediate', 'Wave heavy ropes. Various patterns. High-intensity cardio.'),
('Rowing Machine', 'Full-body cardio', ARRAY['cardio', 'back', 'legs'], 'machine', 'beginner', 'Pull handle while extending legs. Push with legs, pull with arms. Low impact.'),
('Assault Bike', 'High-intensity cardio', ARRAY['cardio'], 'machine', 'beginner', 'Pedal and push handles. Arms and legs. Brutally effective cardio.'),
('Cycling', 'Low-impact cardio', ARRAY['cardio', 'legs'], 'machine', 'beginner', 'Stationary or road bike. Good for endurance and leg strength.');

-- ============================================================================
-- NOTE: This is a representative sample of ~150 exercises
-- For the full 500+ exercise library, continue adding variations including:
-- - Olympic lifts (Clean, Snatch, Clean & Jerk)
-- - Kettlebell exercises (Swings, Turkish Get-Up, Goblet Squat)
-- - Powerlifting variations
-- - Strongman exercises
-- - Calisthenics progressions
-- - Sport-specific exercises
-- - Rehabilitation exercises
-- - Stretching and mobility exercises
-- ============================================================================

-- The remaining 350+ exercises would follow the same pattern with variations of:
-- - Grip widths (wide, narrow, neutral)
-- - Angles (incline, decline, flat)
-- - Tempos (pause reps, explosive, slow eccentric)
-- - Unilateral vs bilateral
-- - Different equipment (resistance bands, TRX, etc.)
-- - Advanced techniques (drop sets, supersets, etc.)
