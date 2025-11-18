// Apply seed data fix via Supabase REST API
const fs = require('fs');
const path = require('path');
const https = require('https');

const SUPABASE_URL = 'https://mogaptihdxdfimszomef.supabase.co';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2FwdGloZHhkZmltc3pvbWVmIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzM5NTQ2NiwiZXhwIjoyMDc4OTcxNDY2fQ.pQAKLjlmL7gwBJnKXd93hq8COtKY4tkFhHLiuZX8l7U';

async function executeSQL(sql) {
  return new Promise((resolve, reject) => {
    const url = new URL('/rest/v1/rpc/exec_sql', SUPABASE_URL);

    const options = {
      hostname: url.hostname,
      port: 443,
      path: url.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SERVICE_ROLE_KEY,
        'Authorization': `Bearer ${SERVICE_ROLE_KEY}`
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(data);
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(JSON.stringify({ sql }));
    req.end();
  });
}

async function main() {
  console.log('🔧 Applying seed data fix...\n');

  // Read the migration file
  const sqlFile = path.join(__dirname, 'migrations', 'sprint-0', '007_fix_seed_data.sql');
  const fullSql = fs.readFileSync(sqlFile, 'utf8');

  // Split into individual statements (simplified approach)
  const statements = [
    // Step 1: Alter table
    `ALTER TABLE workout_templates ALTER COLUMN user_id DROP NOT NULL;`,

    // Step 2: Drop old policy
    `DROP POLICY IF EXISTS "Users can view own and public templates" ON workout_templates;`,

    // Step 3: Create new policy
    `CREATE POLICY "Users can view own and public templates"
      ON workout_templates FOR SELECT
      USING (
        auth.uid() = user_id
        OR is_public = TRUE
        OR (user_id IS NULL AND created_by = 'system')
      );`,

    // Step 4: Delete old system templates
    `DELETE FROM workout_templates WHERE created_by = 'system';`,

    // Step 5: Insert new templates (one at a time for clarity)
  ];

  // Try using direct REST API to insert templates
  console.log('📋 Inserting system workout templates via REST API...\n');

  const templates = [
    {
      user_id: null,
      name: 'Push Day (Beginner)',
      description: 'Classic push workout: chest, shoulders, triceps',
      is_public: true,
      created_by: 'system',
      exercises: [
        { exercise_library_id: null, name: 'Bench Press', sets: 3, reps: 10, rest_seconds: 90 },
        { exercise_library_id: null, name: 'Shoulder Press', sets: 3, reps: 10, rest_seconds: 90 },
        { exercise_library_id: null, name: 'Tricep Dips', sets: 3, reps: 12, rest_seconds: 60 }
      ]
    },
    {
      user_id: null,
      name: 'Pull Day (Beginner)',
      description: 'Classic pull workout: back, biceps',
      is_public: true,
      created_by: 'system',
      exercises: [
        { exercise_library_id: null, name: 'Pull-ups', sets: 3, reps: 8, rest_seconds: 90 },
        { exercise_library_id: null, name: 'Barbell Rows', sets: 3, reps: 10, rest_seconds: 90 },
        { exercise_library_id: null, name: 'Bicep Curls', sets: 3, reps: 12, rest_seconds: 60 }
      ]
    },
    {
      user_id: null,
      name: 'Leg Day (Beginner)',
      description: 'Classic leg workout: quads, hamstrings, glutes',
      is_public: true,
      created_by: 'system',
      exercises: [
        { exercise_library_id: null, name: 'Squats', sets: 4, reps: 10, rest_seconds: 120 },
        { exercise_library_id: null, name: 'Romanian Deadlifts', sets: 3, reps: 10, rest_seconds: 90 },
        { exercise_library_id: null, name: 'Leg Press', sets: 3, reps: 12, rest_seconds: 90 }
      ]
    },
    {
      user_id: null,
      name: 'Full Body (Beginner)',
      description: 'Complete full body workout for beginners',
      is_public: true,
      created_by: 'system',
      exercises: [
        { exercise_library_id: null, name: 'Squats', sets: 3, reps: 10, rest_seconds: 90 },
        { exercise_library_id: null, name: 'Bench Press', sets: 3, reps: 10, rest_seconds: 90 },
        { exercise_library_id: null, name: 'Barbell Rows', sets: 3, reps: 10, rest_seconds: 90 },
        { exercise_library_id: null, name: 'Shoulder Press', sets: 3, reps: 10, rest_seconds: 90 },
        { exercise_library_id: null, name: 'Plank', sets: 3, reps: 30, rest_seconds: 60 }
      ]
    },
    {
      user_id: null,
      name: 'HIIT Cardio (Intermediate)',
      description: 'High-intensity interval training for cardio',
      is_public: true,
      created_by: 'system',
      exercises: [
        { exercise_library_id: null, name: 'Burpees', sets: 4, reps: 10, rest_seconds: 30 },
        { exercise_library_id: null, name: 'Mountain Climbers', sets: 4, reps: 20, rest_seconds: 30 },
        { exercise_library_id: null, name: 'Jump Squats', sets: 4, reps: 15, rest_seconds: 30 },
        { exercise_library_id: null, name: 'High Knees', sets: 4, reps: 30, rest_seconds: 30 }
      ]
    }
  ];

  // Insert via REST API
  const fetch = require('node-fetch') || (await import('node-fetch')).default;

  try {
    // First, delete existing system templates
    const deleteResponse = await fetch(
      `${SUPABASE_URL}/rest/v1/workout_templates?created_by=eq.system`,
      {
        method: 'DELETE',
        headers: {
          'apikey': SERVICE_ROLE_KEY,
          'Authorization': `Bearer ${SERVICE_ROLE_KEY}`
        }
      }
    );
    console.log('✓ Deleted existing system templates');

    // Insert new templates
    const insertResponse = await fetch(
      `${SUPABASE_URL}/rest/v1/workout_templates`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': SERVICE_ROLE_KEY,
          'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
          'Prefer': 'return=representation'
        },
        body: JSON.stringify(templates)
      }
    );

    if (insertResponse.ok) {
      const data = await insertResponse.json();
      console.log(`✓ Inserted ${data.length} system workout templates\n`);

      console.log('📋 Templates created:');
      data.forEach(t => {
        console.log(`  - ${t.name}`);
      });
    } else {
      const error = await insertResponse.text();
      console.error('❌ Failed to insert templates:', error);
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

main();
