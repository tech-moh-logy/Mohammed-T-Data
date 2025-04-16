-- Create the database if it doesn't already exist
DROP DATABASE IF EXISTS SocialMediaApp;
CREATE DATABASE IF NOT EXISTS SocialMediaApp;
USE SocialMediaApp;

-- ================================
-- USERS TABLE: Stores basic user info
-- ================================
CREATE TABLE Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  password_salt VARCHAR(255) NOT NULL,
  profile TEXT,
  is_private BOOLEAN DEFAULT FALSE,
  role ENUM('admin', 'user', 'moderator') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==================================
-- TWEET TABLE: Stores all tweets
-- ==================================
CREATE TABLE Tweet (
  tweet_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  content VARCHAR(280) NOT NULL,
  time_tweeted DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- =====================================
-- HASHTAG TABLE: Stores unique hashtags
-- =====================================
CREATE TABLE Hashtags (
  hashtag_id INT AUTO_INCREMENT PRIMARY KEY,
  hashtag_name VARCHAR(50) UNIQUE NOT NULL
);

-- ==============================================
-- FOLLOW TABLE: Maps user follow relationships
-- ==============================================
CREATE TABLE Follow (
  follower_id INT NOT NULL,
  followee_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (follower_id, followee_id),
  FOREIGN KEY (follower_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (followee_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ==================================================
-- LIKE_TWEET TABLE: Records which users like tweets
-- ==================================================
CREATE TABLE LikeTweet (
  like_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  tweet_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (tweet_id) REFERENCES Tweet(tweet_id) ON DELETE CASCADE
);

-- ====================================================
-- TWEET_HASHTAG TABLE: Many-to-many for tweets/hashtags
-- ====================================================
CREATE TABLE TweetHashtag (
  tweet_id INT NOT NULL,
  hashtag_id INT NOT NULL,
  PRIMARY KEY (tweet_id, hashtag_id),
  FOREIGN KEY (tweet_id) REFERENCES Tweet(tweet_id) ON DELETE CASCADE,
  FOREIGN KEY (hashtag_id) REFERENCES Hashtags(hashtag_id) ON DELETE CASCADE
);

-- ======================================
-- SAMPLE DATA INSERTIONS
-- ======================================

-- Inserting sample users into the Users table
INSERT INTO Users (full_name, username, email, password_hash, password_salt, profile, is_private) VALUES
  ('Sophia Ramirez', 'soph_ram', 'sophia@email.com', 'hashed_password_123', 'salt_123', 'Passionate about coding and tech!', FALSE),
  ('Jason Lee', 'jason_lee', 'jason@email.com', 'hashed_password_456', 'salt_456', 'Tech enthusiast and aspiring developer', FALSE),
  ('Rachel Adams', 'rachel_adams', 'rachel@email.com', 'hashed_password_789', 'salt_789', NULL, TRUE);

-- Inserting sample hashtags into the Hashtags table
INSERT INTO Hashtags (hashtag_name) VALUES
  ('#TechForEveryone'),
  ('#CodeIsLife'),
  ('#InspirationDaily');

-- Inserting sample tweets
INSERT INTO Tweet (user_id, content, time_tweeted) VALUES
  (1, 'Learning new coding languages! #TechForEveryone', '2023-10-01 14:30:00'),
  (2, 'Morning thoughts on innovation! #CodeIsLife', '2023-11-05 08:00:00'),
  (3, 'Find inspiration in every challenge. #InspirationDaily', '2023-12-10 07:45:00');

-- Linking tweets to hashtags
INSERT INTO TweetHashtag (tweet_id, hashtag_id) VALUES
  (1, 1),
  (2, 2),
  (3, 3);

-- Inserting follow relationships
INSERT INTO Follow (follower_id, followee_id) VALUES
  (1, 2), -- Sophia follows Jason
  (2, 1); -- Jason follows Sophia

-- Inserting likes on tweets
INSERT INTO LikeTweet (user_id, tweet_id) VALUES
  (2, 1), -- Jason likes Sophia's tweet
  (3, 2); -- Rachel likes Jason's tweet

-- =========================================
-- ANALYTICS QUERIES
-- =========================================

-- 1. Which user has the most followers?
SELECT 
  u.username,
  COUNT(f.follower_id) AS total_followers
FROM Follow f
JOIN Users u ON u.user_id = f.followee_id
GROUP BY f.followee_id
ORDER BY total_followers DESC
LIMIT 1;

-- 2. For a specific user, list the 5 most recent tweets containing the hashtag "#InspirationDaily"
SELECT 
  t.tweet_id,
  t.content,
  t.time_tweeted
FROM Tweet t
JOIN TweetHashtag th ON t.tweet_id = th.tweet_id
JOIN Hashtags h ON th.hashtag_id = h.hashtag_id
WHERE t.user_id = 3 AND h.hashtag_name = '#InspirationDaily'
ORDER BY t.time_tweeted DESC
LIMIT 5;
