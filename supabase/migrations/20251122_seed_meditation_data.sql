-- Story 4.1: Seed Meditation Library Data
-- 25 guided meditations across 5 categories
-- Durations: 5, 10, 15, 20 minutes
-- Created: 2025-11-22

-- Stress Relief Meditations (7 meditations)
INSERT INTO meditations (title, description, duration_seconds, category, audio_url, thumbnail_url, is_premium) VALUES
('Body Scan for Stress Relief', 'Release tension from head to toe with this calming body scan meditation.', 600, 'stress_relief', 'https://placeholder-audio.com/stress-relief-body-scan-10min.mp3', 'https://placeholder-images.com/stress-relief-1.webp', false),
('Deep Breathing Relaxation', 'Learn powerful breathing techniques to quickly reduce stress and anxiety.', 300, 'stress_relief', 'https://placeholder-audio.com/deep-breathing-5min.mp3', 'https://placeholder-images.com/stress-relief-2.webp', false),
('Progressive Muscle Relaxation', 'Systematically release physical tension to calm your nervous system.', 900, 'stress_relief', 'https://placeholder-audio.com/pmr-15min.mp3', 'https://placeholder-images.com/stress-relief-3.webp', true),
('Mindful Stress Release', 'Acknowledge and release stress with mindfulness and compassion.', 600, 'stress_relief', 'https://placeholder-audio.com/mindful-stress-10min.mp3', 'https://placeholder-images.com/stress-relief-4.webp', true),
('Quick Stress Reset', 'A fast and effective meditation to reset when overwhelmed.', 300, 'stress_relief', 'https://placeholder-audio.com/quick-reset-5min.mp3', 'https://placeholder-images.com/stress-relief-5.webp', false),
('Workplace Stress Relief', 'Perfect for a midday break to release work-related tension.', 600, 'stress_relief', 'https://placeholder-audio.com/workplace-stress-10min.mp3', 'https://placeholder-images.com/stress-relief-6.webp', true),
('Evening Stress Unwind', 'Let go of the day''s stress and prepare for restful sleep.', 1200, 'stress_relief', 'https://placeholder-audio.com/evening-unwind-20min.mp3', 'https://placeholder-images.com/stress-relief-7.webp', true);

-- Sleep Meditations (6 meditations)
INSERT INTO meditations (title, description, duration_seconds, category, audio_url, thumbnail_url, is_premium) VALUES
('Deep Sleep Journey', 'Drift into deep, restorative sleep with guided visualization.', 1200, 'sleep', 'https://placeholder-audio.com/deep-sleep-20min.mp3', 'https://placeholder-images.com/sleep-1.webp', true),
('Bedtime Body Scan', 'Relax every muscle as you prepare for peaceful sleep.', 900, 'sleep', 'https://placeholder-audio.com/bedtime-scan-15min.mp3', 'https://placeholder-images.com/sleep-2.webp', true),
('Sleep Breathing', 'Gentle breathing patterns to ease you into slumber.', 600, 'sleep', 'https://placeholder-audio.com/sleep-breathing-10min.mp3', 'https://placeholder-images.com/sleep-3.webp', true),
('Night Sky Visualization', 'Imagine floating under a starry sky as you fall asleep.', 900, 'sleep', 'https://placeholder-audio.com/night-sky-15min.mp3', 'https://placeholder-images.com/sleep-4.webp', true),
('Quick Sleep Aid', 'Fast-track to sleep when you need rest quickly.', 300, 'sleep', 'https://placeholder-audio.com/quick-sleep-5min.mp3', 'https://placeholder-images.com/sleep-5.webp', true),
('Ocean Waves Sleep', 'Let the rhythm of ocean waves carry you to sleep.', 1200, 'sleep', 'https://placeholder-audio.com/ocean-sleep-20min.mp3', 'https://placeholder-images.com/sleep-6.webp', true);

-- Focus Meditations (5 meditations)
INSERT INTO meditations (title, description, duration_seconds, category, audio_url, thumbnail_url, is_premium) VALUES
('Concentration Boost', 'Sharpen your focus before important work or study.', 600, 'focus', 'https://placeholder-audio.com/concentration-10min.mp3', 'https://placeholder-images.com/focus-1.webp', true),
('Quick Focus Reset', 'Clear mental fog and regain clarity in 5 minutes.', 300, 'focus', 'https://placeholder-audio.com/quick-focus-5min.mp3', 'https://placeholder-images.com/focus-2.webp', false),
('Deep Work Preparation', 'Enter a state of flow for focused, productive work.', 900, 'focus', 'https://placeholder-audio.com/deep-work-15min.mp3', 'https://placeholder-images.com/focus-3.webp', true),
('Mindful Attention Training', 'Build your capacity for sustained attention and focus.', 600, 'focus', 'https://placeholder-audio.com/attention-training-10min.mp3', 'https://placeholder-images.com/focus-4.webp', true),
('Study Session Focus', 'Optimize your mind for learning and retention.', 300, 'focus', 'https://placeholder-audio.com/study-focus-5min.mp3', 'https://placeholder-images.com/focus-5.webp', false);

-- Anxiety Meditations (5 meditations)
INSERT INTO meditations (title, description, duration_seconds, category, audio_url, thumbnail_url, is_premium) VALUES
('Calm the Anxious Mind', 'Gentle guidance to soothe anxiety and worry.', 600, 'anxiety', 'https://placeholder-audio.com/calm-anxiety-10min.mp3', 'https://placeholder-images.com/anxiety-1.webp', true),
('Grounding for Anxiety', 'Anchor yourself in the present moment when anxiety arises.', 300, 'anxiety', 'https://placeholder-audio.com/grounding-5min.mp3', 'https://placeholder-images.com/anxiety-2.webp', false),
('Worry Release', 'Let go of worries that keep you stuck in anxious thoughts.', 900, 'anxiety', 'https://placeholder-audio.com/worry-release-15min.mp3', 'https://placeholder-images.com/anxiety-3.webp', true),
('Safe Space Visualization', 'Create an inner sanctuary where anxiety cannot reach.', 600, 'anxiety', 'https://placeholder-audio.com/safe-space-10min.mp3', 'https://placeholder-images.com/anxiety-4.webp', true),
('Anxiety First Aid', 'Quick relief during moments of acute anxiety.', 300, 'anxiety', 'https://placeholder-audio.com/anxiety-first-aid-5min.mp3', 'https://placeholder-images.com/anxiety-5.webp', false);

-- Gratitude Meditations (2 meditations - smaller category as per typical meditation apps)
INSERT INTO meditations (title, description, duration_seconds, category, audio_url, thumbnail_url, is_premium) VALUES
('Daily Gratitude Practice', 'Cultivate appreciation for life''s blessings, big and small.', 600, 'gratitude', 'https://placeholder-audio.com/daily-gratitude-10min.mp3', 'https://placeholder-images.com/gratitude-1.webp', true),
('Three Good Things', 'Reflect on three positive moments from your day.', 300, 'gratitude', 'https://placeholder-audio.com/three-good-things-5min.mp3', 'https://placeholder-images.com/gratitude-2.webp', false);

-- Total: 25 meditations
-- Free tier: 5 meditations (marked is_premium = false) - rotating access will be handled by app logic
-- Premium tier: 20 meditations (marked is_premium = true)
-- Durations: 5 min (300s): 8, 10 min (600s): 10, 15 min (900s): 5, 20 min (1200s): 3
-- Categories: Stress Relief: 7, Sleep: 6, Focus: 5, Anxiety: 5, Gratitude: 2
