-- ============================================================
-- PROJECT: Cyberpunk 2077 — Phantom Liberty Mission Analytics
-- DESCRIPTION: Creates the analytical views that act as a
--              lightweight datamart layer. These views are what
--              the analysis queries and Tableau connect to.
-- ============================================================
 
USE phantom_liberty_analytics;
 
-- ──────────────────────────────────────────────────────────────
-- VIEW 1: vw_mission_attempt_detail
-- Flat view joining every attempt with mission and player info.
-- The main working surface for most analytical queries.
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_mission_attempt_detail AS
SELECT
    a.attempt_id,
    a.attempt_date,
    a.attempt_number,
 
    -- Player dimensions
    p.player_id,
    p.platform,
    p.region,
    p.playstyle,
    p.default_difficulty,
    p.player_level_start,
    p.total_hours_played,
 
    -- Mission dimensions
    m.mission_id,
    m.mission_name,
    m.mission_type,
    m.act,
    m.district,
    m.base_difficulty,
    m.estimated_playtime_mins,
    m.eddies_reward,
    m.xp_reward,
    m.has_multiple_endings,
 
    -- Attempt facts
    a.difficulty_selected,
    a.actual_playtime_mins,
    a.completed,
    a.deaths_count,
    a.used_stealth,
    a.outcome
 
FROM player_mission_attempts a
JOIN players  p ON a.player_id  = p.player_id
JOIN missions m ON a.mission_id = m.mission_id;
 
 
-- ──────────────────────────────────────────────────────────────
-- VIEW 2: vw_mission_performance_summary
-- Pre-aggregated mission-level KPIs — one row per mission.
-- Useful for quick lookups and as a base for rankings.
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_mission_performance_summary AS
SELECT
    m.mission_id,
    m.mission_name,
    m.mission_type,
    m.act,
    m.base_difficulty,
    m.estimated_playtime_mins,
    m.has_multiple_endings,
 
    COUNT(a.attempt_id)                                         AS total_attempts,
    SUM(a.completed)                                            AS total_completions,
    ROUND(SUM(a.completed) / COUNT(a.attempt_id) * 100, 2)     AS completion_rate_pct,
 
    ROUND(AVG(a.actual_playtime_mins), 1)                       AS avg_playtime_mins,
    ROUND(AVG(CASE WHEN a.completed = 1
                   THEN a.actual_playtime_mins END), 1)         AS avg_playtime_completions_only,
 
    ROUND(AVG(a.deaths_count), 2)                               AS avg_deaths,
    ROUND(AVG(CASE WHEN a.completed = 1
                   THEN a.deaths_count END), 2)                 AS avg_deaths_on_success,
 
    SUM(CASE WHEN a.outcome = 'Abandoned' THEN 1 ELSE 0 END)   AS total_abandoned,
    ROUND(SUM(CASE WHEN a.outcome = 'Abandoned' THEN 1 ELSE 0 END)
          / COUNT(a.attempt_id) * 100, 2)                       AS abandonment_rate_pct
 
FROM missions m
LEFT JOIN player_mission_attempts a ON m.mission_id = a.mission_id
GROUP BY
    m.mission_id, m.mission_name, m.mission_type,
    m.act, m.base_difficulty, m.estimated_playtime_mins, m.has_multiple_endings;
 
 
-- ──────────────────────────────────────────────────────────────
-- VIEW 3: vw_mission_ratings_summary
-- Aggregated rating scores per mission.
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_mission_ratings_summary AS
SELECT
    r.mission_id,
    m.mission_name,
    m.mission_type,
    m.act,
    m.base_difficulty,
    m.has_multiple_endings,
 
    COUNT(r.rating_id)                          AS total_ratings,
    ROUND(AVG(r.story_rating),    2)            AS avg_story_rating,
    ROUND(AVG(r.gameplay_rating), 2)            AS avg_gameplay_rating,
    ROUND(AVG(r.difficulty_felt), 2)            AS avg_difficulty_felt,
    ROUND(AVG(r.replay_value),    2)            AS avg_replay_value,
 
    -- Overall score = equal-weight average of all four dimensions
    ROUND((AVG(r.story_rating) + AVG(r.gameplay_rating)
         + AVG(r.replay_value)) / 3.0, 2)       AS avg_overall_score
 
FROM mission_ratings r
JOIN missions m ON r.mission_id = m.mission_id
GROUP BY
    r.mission_id, m.mission_name, m.mission_type,
    m.act, m.base_difficulty, m.has_multiple_endings;
 
 
-- ──────────────────────────────────────────────────────────────
-- VIEW 4: vw_player_engagement_summary
-- One row per player summarising their whole PL journey.
-- Used for player-level analysis and platform comparisons.
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_player_engagement_summary AS
SELECT
    p.player_id,
    p.platform,
    p.region,
    p.playstyle,
    p.default_difficulty,
    p.player_level_start,
    p.total_hours_played,
 
    COUNT(DISTINCT a.mission_id)                                AS unique_missions_attempted,
    COUNT(a.attempt_id)                                         AS total_attempts,
    SUM(a.completed)                                            AS total_completions,
    ROUND(SUM(a.completed) / COUNT(a.attempt_id) * 100, 2)     AS personal_completion_rate,
 
    ROUND(SUM(a.actual_playtime_mins) / 60.0, 1)               AS total_playtime_hours,
    SUM(a.deaths_count)                                         AS total_deaths,
 
    COUNT(DISTINCT CASE WHEN a.mission_id IN
          (SELECT mission_id FROM missions WHERE mission_type = 'Main')
          AND a.completed = 1 THEN a.mission_id END)            AS main_missions_completed,
 
    COUNT(DISTINCT CASE WHEN a.mission_id IN
          (SELECT mission_id FROM missions WHERE mission_type IN ('Gig','NCPD'))
          AND a.completed = 1 THEN a.mission_id END)            AS side_content_completed
 
FROM players p
LEFT JOIN player_mission_attempts a ON p.player_id = a.player_id
GROUP BY
    p.player_id, p.platform, p.region, p.playstyle,
    p.default_difficulty, p.player_level_start, p.total_hours_played;