-- ============================================================
-- PROJECT: Cyberpunk 2077 — Phantom Liberty Mission Analytics
-- DESCRIPTION: Loads the Data into the corresponding tables 
-- ============================================================

USE phantom_liberty_analytics;

-- Using Load Data infile to load the Data into Mysql
SET GLOBAL local_infile = 1

-- 1. missions (load first — no foreign keys)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/phantom_liberty_analytics/missions.csv'
INTO TABLE missions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(mission_id, mission_name, mission_type, act, district,
 base_difficulty, estimated_playtime_mins, eddies_reward,
 xp_reward, has_multiple_endings);


-- 2. players (load second — no foreign keys)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/phantom_liberty_analytics/players.csv'
INTO TABLE players
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(player_id, platform, region, playstyle, default_difficulty,
 player_level_start, total_hours_played, dlc_purchased_date);


-- 3. player_mission_attempts (load after missions + players)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/phantom_liberty_analytics/player_mission_attempts.csv'
INTO TABLE player_mission_attempts
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(attempt_id, player_id, mission_id, attempt_date,
 difficulty_selected, actual_playtime_mins, completed,
 deaths_count, used_stealth, outcome, attempt_number);


-- 4. mission_ratings (load last)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/phantom_liberty_analytics/mission_ratings.csv'
INTO TABLE mission_ratings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(rating_id, player_id, mission_id, story_rating,
 gameplay_rating, difficulty_felt, replay_value, submitted_date);
 
 -- Verifying the loaded data
 USE phantom_liberty;
SELECT 'missions',               COUNT(*) FROM missions               UNION ALL
SELECT 'players',                COUNT(*) FROM players                UNION ALL
SELECT 'player_mission_attempts',COUNT(*) FROM player_mission_attempts UNION ALL
SELECT 'mission_ratings',        COUNT(*) FROM mission_ratings;

/*Expected output:
TableCountmissions 			35
players 					900
player_mission_attempts		35 000
mission_ratings				14 600
*/