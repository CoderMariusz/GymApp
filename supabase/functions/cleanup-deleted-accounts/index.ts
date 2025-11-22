// Edge Function: Cleanup Deleted Accounts (Cron Job)
// Runs daily to permanently delete accounts after 7-day grace period
// Schedule in Supabase: 0 2 * * * (daily at 2 AM)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify cron secret to prevent unauthorized access
    const authHeader = req.headers.get('Authorization');
    const cronSecret = Deno.env.get('CRON_SECRET');

    if (!cronSecret || authHeader !== `Bearer ${cronSecret}`) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Initialize Supabase admin client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Find accounts scheduled for deletion that are past the grace period
    const now = new Date().toISOString();
    const { data: accountsToDelete, error: fetchError } = await supabaseAdmin
      .from('account_deletion_requests')
      .select('id, user_id, scheduled_deletion_at')
      .eq('status', 'pending')
      .lte('scheduled_deletion_at', now);

    if (fetchError) {
      throw new Error('Failed to fetch accounts to delete: ' + fetchError.message);
    }

    if (!accountsToDelete || accountsToDelete.length === 0) {
      return new Response(
        JSON.stringify({
          message: 'No accounts to delete',
          deleted_count: 0,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    const deletedAccounts = [];
    const errors = [];

    // Process each account
    for (const account of accountsToDelete) {
      try {
        // Delete user from auth.users (this will cascade to all related tables due to ON DELETE CASCADE)
        const { error: deleteAuthError } = await supabaseAdmin.auth.admin.deleteUser(
          account.user_id
        );

        if (deleteAuthError) {
          throw new Error(`Failed to delete auth user: ${deleteAuthError.message}`);
        }

        // Mark deletion request as completed
        await supabaseAdmin
          .from('account_deletion_requests')
          .update({
            status: 'completed',
            deleted_at: new Date().toISOString(),
          })
          .eq('id', account.id);

        deletedAccounts.push({
          user_id: account.user_id,
          deletion_request_id: account.id,
        });

        console.log(`Successfully deleted account: ${account.user_id}`);
      } catch (error) {
        console.error(`Error deleting account ${account.user_id}:`, error);
        errors.push({
          user_id: account.user_id,
          error: error.message,
        });

        // Mark as failed for manual review
        await supabaseAdmin
          .from('account_deletion_requests')
          .update({
            status: 'failed',
            error_message: error.message,
          })
          .eq('id', account.id);
      }
    }

    // TODO: Send notification to admin if there were any errors
    // TODO: Log to monitoring service

    return new Response(
      JSON.stringify({
        message: 'Cleanup completed',
        deleted_count: deletedAccounts.length,
        error_count: errors.length,
        deleted_accounts: deletedAccounts,
        errors: errors,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Cleanup error:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
