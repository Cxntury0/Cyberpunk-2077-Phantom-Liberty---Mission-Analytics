-- ============================================================
-- PROJECT: Cyberpunk 2077 — Phantom Liberty Mission Analytics
-- DESCRIPTION: Creates the Databse and the four core tables for the project.
-- ============================================================
 
CREATE DATABASE IF NOT EXISTS phantom_liberty_analytics;

USE phantom_liberty_analytics;
 
-- ──────────────────────────────────────────────────────────────
-- TABLE 1: missions
-- One row per mission. Static reference / dimension table.
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS missions (
    mission_id              INT             PRIMARY KEY,
    mission_name            VARCHAR(100)    NOT NULL,
    mission_type            VARCHAR(20)     NOT NULL,   -- Main / Side / Gig / NCPD
    act                     TINYINT         NOT NULL,   -- 1 / 2 / 3
    district                VARCHAR(50)     NOT NULL,
    base_difficulty         TINYINT         NOT NULL,   -- 1 (Easy) to 5 (Very Hard)
    estimated_playtime_mins SMALLINT        NOT NULL,
    eddies_reward           INT             NOT NULL,
    xp_reward               INT             NOT NULL,
    has_multiple_endings    TINYINT         NOT NULL DEFAULT 0
);
 
 
-- ──────────────────────────────────────────────────────────────
-- TABLE 2: players
-- One row per player. Dimension table.
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS players (
    player_id               INT             PRIMARY KEY,
    platform                VARCHAR(20)     NOT NULL,   -- PC / PS5 / Xbox Series X
    region                  VARCHAR(30)     NOT NULL,
    playstyle               VARCHAR(20)     NOT NULL,   -- Combat / Stealth / Netrunner / Balanced
    default_difficulty      VARCHAR(20)     NOT NULL,   -- Easy / Normal / Hard / Very Hard
    player_level_start      TINYINT         NOT NULL,
    total_hours_played      DECIMAL(6,1)    NOT NULL,
    dlc_purchased_date      DATE            NOT NULL
);
 
 
-- ──────────────────────────────────────────────────────────────
-- TABLE 3: player_mission_attempts
-- One row per attempt. Core fact table.
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS player_mission_attempts (
    attempt_id              INT             PRIMARY KEY,
    player_id               INT             NOT NULL,
    mission_id              INT             NOT NULL,
    attempt_date            DATE            NOT NULL,
    difficulty_selected     VARCHAR(20)     NOT NULL,
    actual_playtime_mins    DECIMAL(6,1)    NOT NULL,
    completed               TINYINT         NOT NULL DEFAULT 0,
    deaths_count            SMALLINT        NOT NULL DEFAULT 0,
    used_stealth            TINYINT         NOT NULL DEFAULT 0,
    outcome                 VARCHAR(20)     NOT NULL,   -- Completed / Failed / Abandoned
    attempt_number          TINYINT         NOT NULL DEFAULT 1,
 
    FOREIGN KEY (player_id)  REFERENCES players(player_id),
    FOREIGN KEY (mission_id) REFERENCES missions(mission_id)
);
 
 
-- ──────────────────────────────────────────────────────────────
-- TABLE 4: mission_ratings
-- Post-completion ratings left by players.
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS mission_ratings (
    rating_id               INT             PRIMARY KEY,
    player_id               INT             NOT NULL,
    mission_id              INT             NOT NULL,
    story_rating            TINYINT         NOT NULL,   -- 1–5
    gameplay_rating         TINYINT         NOT NULL,   -- 1–5
    difficulty_felt         TINYINT         NOT NULL,   -- 1–5
    replay_value            TINYINT         NOT NULL,   -- 1–5
    submitted_date          DATE            NOT NULL,
 
    FOREIGN KEY (player_id)  REFERENCES players(player_id),
    FOREIGN KEY (mission_id) REFERENCES missions(mission_id)
);