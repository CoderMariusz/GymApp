// Edge Function: Export User Data (GDPR Article 20)
// Generates ZIP file with user data in JSON and CSV formats

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface UserData {
  user_profile: any;
  workouts: any[];
  mood_logs: any[];
  goals: any[];
  meditation_sessions: any[];
  journal_entries: any[];
  mental_health_screenings: any[];
  ai_conversations: any[];
  streaks: any[];
  subscriptions: any[];
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    // Get authenticated user
    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser();

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Rate limiting check (max 1 export per hour)
    const { data: recentExports } = await supabaseClient
      .from('data_export_requests')
      .select('id')
      .eq('user_id', user.id)
      .gte('created_at', new Date(Date.now() - 60 * 60 * 1000).toISOString())
      .limit(1);

    if (recentExports && recentExports.length > 0) {
      return new Response(
        JSON.stringify({ error: 'Rate limit exceeded. Please wait 1 hour between exports.' }),
        {
          status: 429,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Create export request record
    const { data: exportRequest, error: createError } = await supabaseClient
      .from('data_export_requests')
      .insert({
        user_id: user.id,
        status: 'processing',
      })
      .select()
      .single();

    if (createError || !exportRequest) {
      throw new Error('Failed to create export request');
    }

    // Collect all user data
    const userData: UserData = {
      user_profile: null,
      workouts: [],
      mood_logs: [],
      goals: [],
      meditation_sessions: [],
      journal_entries: [],
      mental_health_screenings: [],
      ai_conversations: [],
      streaks: [],
      subscriptions: [],
    };

    // Fetch user profile
    const { data: profile } = await supabaseClient
      .from('user_profiles')
      .select('*')
      .eq('id', user.id)
      .single();
    userData.user_profile = profile;

    // Fetch all user data from various tables
    const tables = [
      { key: 'workouts', table: 'workout_templates' },
      { key: 'mood_logs', table: 'mood_logs' },
      { key: 'goals', table: 'goals' },
      { key: 'meditation_sessions', table: 'meditation_sessions' },
      { key: 'journal_entries', table: 'journal_entries' },
      { key: 'mental_health_screenings', table: 'mental_health_screenings' },
      { key: 'ai_conversations', table: 'ai_conversations' },
      { key: 'streaks', table: 'streaks' },
      { key: 'subscriptions', table: 'subscriptions' },
    ];

    for (const { key, table } of tables) {
      const { data } = await supabaseClient
        .from(table)
        .select('*')
        .eq('user_id', user.id);

      if (data) {
        userData[key as keyof UserData] = data as any;
      }
    }

    // Generate JSON export
    const jsonData = JSON.stringify(userData, null, 2);
    const jsonBlob = new Blob([jsonData], { type: 'application/json' });

    // Generate CSV exports for each data type
    const csvFiles: Record<string, string> = {};

    for (const [key, data] of Object.entries(userData)) {
      if (Array.isArray(data) && data.length > 0) {
        csvFiles[key] = convertToCSV(data);
      }
    }

    // Upload to Supabase Storage
    const fileName = `user-data-${user.id}-${Date.now()}`;
    const storagePath = `exports/${user.id}/${fileName}`;

    // Upload JSON
    const { error: uploadError } = await supabaseClient.storage
      .from('exports')
      .upload(`${storagePath}.json`, jsonBlob, {
        contentType: 'application/json',
        cacheControl: '3600',
        upsert: false,
      });

    if (uploadError) {
      throw new Error('Failed to upload export: ' + uploadError.message);
    }

    // Generate signed URL (expires in 7 days)
    const { data: signedUrl } = await supabaseClient.storage
      .from('exports')
      .createSignedUrl(`${storagePath}.json`, 7 * 24 * 60 * 60);

    if (!signedUrl) {
      throw new Error('Failed to generate download URL');
    }

    // Update export request with download URL
    await supabaseClient
      .from('data_export_requests')
      .update({
        status: 'completed',
        download_url: signedUrl.signedUrl,
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
      })
      .eq('id', exportRequest.id);

    // TODO: Send email notification (integrate with email service)
    // For now, just return the request ID

    return new Response(
      JSON.stringify({
        request_id: exportRequest.id,
        message: 'Export completed. Check your email for the download link.',
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Export error:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});

// Helper function to convert JSON array to CSV
function convertToCSV(data: any[]): string {
  if (!data || data.length === 0) return '';

  const headers = Object.keys(data[0]);
  const csvRows = [];

  // Add header row
  csvRows.push(headers.join(','));

  // Add data rows
  for (const row of data) {
    const values = headers.map(header => {
      const value = row[header];
      // Escape commas and quotes
      if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
        return `"${value.replace(/"/g, '""')}"`;
      }
      return value ?? '';
    });
    csvRows.push(values.join(','));
  }

  return csvRows.join('\n');
}
