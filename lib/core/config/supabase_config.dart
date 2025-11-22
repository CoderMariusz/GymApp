class SupabaseConfig {
  // Supabase configuration for LifeOS
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://neyxqfrtygpatwopeqqe.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5leXhxZnJ0eWdwYXR3b3BlcXFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1MDIwNjUsImV4cCI6MjA3OTA3ODA2NX0.p7E_CLOo9HfcoZBvuVK-GshYO7Rqxvu7-up4zZ5YPZs',
  );

  // Service role key (for admin operations - use with caution)
  static const String supabaseServiceRoleKey = String.fromEnvironment(
    'SUPABASE_SERVICE_ROLE_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5leXhxZnJ0eWdwYXR3b3BlcXFlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzUwMjA2NSwiZXhwIjoyMDc5MDc4MDY1fQ.ObM1DKzXiJ5O1gpuLM5CKg6SSuFQKWn6UBwQlgquz4M',
  );
}
