require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function runMigrations() {
  // Load database connection string from environment variables
  const connectionString = process.env.DATABASE_URL;

  if (!connectionString) {
    console.error('❌ Error: Missing required environment variable!');
    console.error('   Required: DATABASE_URL');
    console.error('   Format: postgresql://postgres:PASSWORD@db.PROJECT_ID.supabase.co:5432/postgres');
    console.error('   Please create a .env file with this variable.');
    console.error('   See .env.example for reference.');
    process.exit(1);
  }

  const client = new Client({
    connectionString: connectionString,
    ssl: { rejectUnauthorized: false }
  });

  try {
    console.log('Connecting to Supabase PostgreSQL...');
    await client.connect();
    console.log('Connected successfully!');

    // Check command line args for which migration to run
    const migrationArg = process.argv[2] || 'combined';
    let sqlFile;

    if (migrationArg === 'seed') {
      sqlFile = path.join(__dirname, 'migrations', 'sprint-0', '007_fix_seed_data.sql');
    } else {
      sqlFile = path.join(__dirname, 'migrations', 'sprint-0', 'COMBINED_ALL_MIGRATIONS.sql');
    }

    const sql = fs.readFileSync(sqlFile, 'utf8');

    console.log('Executing migrations...');
    await client.query(sql);
    console.log('✅ All migrations applied successfully!');

    // Verify tables were created
    const result = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name IN (
          'user_daily_metrics',
          'workout_templates',
          'mental_health_screenings',
          'subscriptions',
          'streaks',
          'ai_conversations',
          'mood_logs'
        )
      ORDER BY table_name;
    `);

    console.log('\n📊 Tables created:');
    result.rows.forEach(row => {
      console.log(`  ✓ ${row.table_name}`);
    });

    // Count system templates
    const templates = await client.query(`
      SELECT COUNT(*) as count FROM workout_templates WHERE created_by = 'system';
    `);
    console.log(`\n📋 System workout templates: ${templates.rows[0].count}`);

    // List template names
    if (templates.rows[0].count > 0) {
      const templateList = await client.query(`
        SELECT name, description FROM workout_templates WHERE created_by = 'system' ORDER BY name;
      `);
      console.log('\nSystem templates:');
      templateList.rows.forEach(row => {
        console.log(`  - ${row.name}: ${row.description}`);
      });
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.position) {
      console.error(`   Position: ${error.position}`);
    }
    process.exit(1);
  } finally {
    await client.end();
  }
}

runMigrations();
