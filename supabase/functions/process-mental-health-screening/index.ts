// Edge Function: process-mental-health-screening
// Purpose: Calculate mental health screening scores and detect crisis thresholds
// Sprint: S0.7
// Blocks: FR66-70

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ScreeningRequest {
  user_id: string
  screening_type: 'GAD-7' | 'PHQ-9'
  answers: number[] // Array of scores (0-3 for each question)
  encrypted_answers: string
  encryption_iv: string
}

interface ScreeningResponse {
  id: string
  score: number
  severity: string
  crisis_threshold_reached: boolean
  recommendations: string[]
}

// Severity thresholds based on clinical guidelines
const GAD7_THRESHOLDS = {
  minimal: { min: 0, max: 4 },
  mild: { min: 5, max: 9 },
  moderate: { min: 10, max: 14 },
  severe: { min: 15, max: 21 }
}

const PHQ9_THRESHOLDS = {
  minimal: { min: 0, max: 4 },
  mild: { min: 5, max: 9 },
  moderate: { min: 10, max: 14 },
  moderately_severe: { min: 15, max: 19 },
  severe: { min: 20, max: 27 }
}

function calculateSeverity(score: number, type: 'GAD-7' | 'PHQ-9'): string {
  const thresholds = type === 'GAD-7' ? GAD7_THRESHOLDS : PHQ9_THRESHOLDS

  for (const [severity, range] of Object.entries(thresholds)) {
    if (score >= range.min && score <= range.max) {
      return severity
    }
  }
  return 'unknown'
}

function detectCrisisThreshold(
  score: number,
  type: 'GAD-7' | 'PHQ-9',
  answers: number[]
): boolean {
  // Crisis thresholds:
  // - GAD-7 >= 15 (severe anxiety)
  // - PHQ-9 >= 20 (severe depression)
  // - PHQ-9 Question 9 (self-harm) >= 2 ("more than half the days" or worse)

  if (type === 'GAD-7' && score >= 15) {
    return true
  }

  if (type === 'PHQ-9') {
    if (score >= 20) {
      return true
    }
    // Question 9 is the last question (index 8) about self-harm thoughts
    if (answers.length >= 9 && answers[8] >= 2) {
      return true
    }
  }

  return false
}

function generateRecommendations(
  severity: string,
  type: 'GAD-7' | 'PHQ-9',
  crisisReached: boolean
): string[] {
  const recommendations: string[] = []

  if (crisisReached) {
    recommendations.push('Please consider speaking with a mental health professional immediately')
    recommendations.push('If you are in crisis, contact emergency services or a crisis hotline')
    return recommendations
  }

  switch (severity) {
    case 'minimal':
      recommendations.push('Continue practicing self-care and mindfulness')
      recommendations.push('Maintain healthy sleep and exercise habits')
      break
    case 'mild':
      recommendations.push('Consider trying relaxation techniques or meditation')
      recommendations.push('Track your mood patterns to identify triggers')
      recommendations.push('Reach out to friends or family for support')
      break
    case 'moderate':
      recommendations.push('Consider scheduling an appointment with a mental health professional')
      recommendations.push('Try structured relaxation exercises daily')
      recommendations.push('Limit caffeine and alcohol intake')
      break
    case 'moderately_severe':
    case 'severe':
      recommendations.push('Please consult with a mental health professional')
      recommendations.push('Consider therapy options like CBT')
      recommendations.push('Ensure you have a support system in place')
      break
  }

  return recommendations
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

    const body: ScreeningRequest = await req.json()

    // Validate input
    if (!body.user_id || !body.screening_type || !body.answers || !body.encrypted_answers || !body.encryption_iv) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Calculate score (sum of all answers)
    const score = body.answers.reduce((sum, val) => sum + val, 0)

    // Determine severity
    const severity = calculateSeverity(score, body.screening_type)

    // Check for crisis threshold
    const crisisReached = detectCrisisThreshold(score, body.screening_type, body.answers)

    // Generate recommendations
    const recommendations = generateRecommendations(severity, body.screening_type, crisisReached)

    // Insert into database
    const { data, error } = await supabaseClient
      .from('mental_health_screenings')
      .insert({
        user_id: body.user_id,
        screening_type: body.screening_type,
        score: score,
        severity: severity,
        encrypted_answers: body.encrypted_answers,
        encryption_iv: body.encryption_iv,
        crisis_threshold_reached: crisisReached,
        crisis_modal_shown: false
      })
      .select('id')
      .single()

    if (error) {
      console.error('Database error:', error)
      return new Response(
        JSON.stringify({ error: 'Failed to save screening result' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const response: ScreeningResponse = {
      id: data.id,
      score: score,
      severity: severity,
      crisis_threshold_reached: crisisReached,
      recommendations: recommendations
    }

    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Error processing screening:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
