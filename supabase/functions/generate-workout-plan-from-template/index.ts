// Edge Function: generate-workout-plan-from-template
// Purpose: Convert workout template to actual workout with Smart Pattern Memory
// Sprint: S0.7
// Blocks: FR43-46

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface Exercise {
  exercise_library_id: string | null
  name: string
  sets: number
  reps: number
  rest_seconds: number
}

interface TemplateRequest {
  user_id: string
  template_id: string
  scheduled_date?: string // Optional: when to schedule the workout
  adjustments?: {
    exercise_id?: string
    sets?: number
    reps?: number
    weight?: number
  }[]
}

interface WorkoutPlan {
  id: string
  user_id: string
  name: string
  exercises: WorkoutExercise[]
  scheduled_date: string | null
  created_from_template: string
}

interface WorkoutExercise {
  exercise_library_id: string | null
  name: string
  sets: number
  reps: number
  rest_seconds: number
  target_weight?: number
  notes?: string
}

// Smart Pattern Memory: Suggest weights based on user history
async function getSuggestedWeights(
  supabase: any,
  userId: string,
  exercises: Exercise[]
): Promise<Map<string, number>> {
  const weights = new Map<string, number>()

  // Get user's last workout data for each exercise
  // This would query workout_logs or similar table
  // For now, return empty map (to be implemented with workout tracking)

  return weights
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const body: TemplateRequest = await req.json()

    // Validate input
    if (!body.user_id || !body.template_id) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: user_id and template_id' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Fetch the template
    const { data: template, error: templateError } = await supabaseClient
      .from('workout_templates')
      .select('*')
      .eq('id', body.template_id)
      .single()

    if (templateError || !template) {
      return new Response(
        JSON.stringify({ error: 'Template not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if user has access to template (own template or public)
    if (template.user_id !== body.user_id && !template.is_public) {
      return new Response(
        JSON.stringify({ error: 'Access denied to this template' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Parse exercises from template
    const templateExercises: Exercise[] = template.exercises

    // Get suggested weights from Smart Pattern Memory
    const suggestedWeights = await getSuggestedWeights(
      supabaseClient,
      body.user_id,
      templateExercises
    )

    // Convert template exercises to workout exercises
    const workoutExercises: WorkoutExercise[] = templateExercises.map((exercise) => {
      // Check if user provided adjustments for this exercise
      const adjustment = body.adjustments?.find(
        adj => adj.exercise_id === exercise.exercise_library_id
      )

      return {
        exercise_library_id: exercise.exercise_library_id,
        name: exercise.name,
        sets: adjustment?.sets ?? exercise.sets,
        reps: adjustment?.reps ?? exercise.reps,
        rest_seconds: exercise.rest_seconds,
        target_weight: adjustment?.weight ?? suggestedWeights.get(exercise.name) ?? undefined,
        notes: undefined
      }
    })

    // Create workout plan object
    const workoutPlan: Omit<WorkoutPlan, 'id'> = {
      user_id: body.user_id,
      name: template.name,
      exercises: workoutExercises,
      scheduled_date: body.scheduled_date || null,
      created_from_template: body.template_id
    }

    // Note: This would insert into a workouts table when it exists
    // For now, return the generated plan without saving
    // TODO: Implement workouts table in future sprint

    const response = {
      success: true,
      workout_plan: {
        id: crypto.randomUUID(), // Temporary ID
        ...workoutPlan
      },
      template_name: template.name,
      template_description: template.description,
      exercise_count: workoutExercises.length,
      total_sets: workoutExercises.reduce((sum, ex) => sum + ex.sets, 0),
      estimated_duration_minutes: calculateEstimatedDuration(workoutExercises)
    }

    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Error generating workout plan:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

function calculateEstimatedDuration(exercises: WorkoutExercise[]): number {
  let totalSeconds = 0

  for (const exercise of exercises) {
    // Estimate time per set (30 seconds for execution + rest time)
    const timePerSet = 30 + exercise.rest_seconds
    totalSeconds += exercise.sets * timePerSet
  }

  // Add warm-up time (5 minutes)
  totalSeconds += 300

  // Convert to minutes and round up
  return Math.ceil(totalSeconds / 60)
}
