-- Drop the database if it exists
DROP DATABASE IF EXISTS Users;

-- Create the database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS Users;

-- Use the newly created database
USE Users;

-- ================================
-- USERS TABLE: Stores basic user info
-- ================================
CREATE TABLE Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  profile TEXT, -- Changed to TEXT for longer bios
  is_private BOOLEAN DEFAULT FALSE
);

-- ==================================
-- TWEET TABLE: Stores all tweets
-- ==================================
CREATE TABLE Tweet (
  tweet_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  content VARCHAR(280) NOT NULL, -- Increased to reflect real Twitter limit
  time_tweeted DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- =====================================
-- HASHTAG TABLE: Stores unique hashtags
-- =====================================
CREATE TABLE Hashtag (
  hashtag_id INT AUTO_INCREMENT PRIMARY KEY,
  hashtag_name VARCHAR(50) UNIQUE NOT NULL
);

-- ==============================================
-- FOLLOW TABLE: Maps user follow relationships
-- ==============================================
CREATE TABLE Follow (
  follower_id INT NOT NULL,
  followee_id INT NOT NULL,
  PRIMARY KEY (follower_id, followee_id),
  FOREIGN KEY (follower_id) REFERENCES Users(user_id),
  FOREIGN KEY (followee_id) REFERENCES Users(user_id)
);

-- ==================================================
-- LIKE_TWEET TABLE: Records which users like tweets
-- ==================================================
CREATE TABLE LikeTweet (
  like_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  tweet_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Users(user_id),
  FOREIGN KEY (tweet_id) REFERENCES Tweet(tweet_id)
);

-- ====================================================
-- TWEET_HASHTAG TABLE: Many-to-many for tweets/hashtags
-- ====================================================
CREATE TABLE TweetHashtag (
  tweet_id INT NOT NULL,
  hashtag_id INT NOT NULL,
  PRIMARY KEY (tweet_id, hashtag_id),
  FOREIGN KEY (tweet_id) REFERENCES Tweet(tweet_id),
  FOREIGN KEY (hashtag_id) REFERENCES Hashtag(hashtag_id)
);

-- ======================================
-- SAMPLE DATA INSERTIONS
-- ======================================

-- Insert example users
INSERT INTO Users (user_id, full_name, username, email, password, profile, is_private) VALUES
  (1, 'Mariam Khalil', 'mariamkhalil', 'khalil@email.com', 'password123', 'I love tweeting!', FALSE),
  (2, 'Mel Smith', 'melsmith', 'smith@email.com', 'password456', 'Tweeting enthusiast', FALSE),
  (3, 'Bob Johnson', 'bobjohnson', 'bob@email.com', 'password789', NULL, TRUE);

-- Insert example hashtags
INSERT INTO Hashtag (hashtag_id, hashtag_name) VALUES
  (1, '#newusertoKhourytwitter'),
  (2, '#MondayMotivation'),
  (3, '#NEU');

-- Insert example tweets
INSERT INTO Tweet (tweet_id, user_id, content, time_tweeted) VALUES
  (1, 1, 'My first tweet! #newusertoKhourytwitter', '2023-10-01 12:00:00'),
  (2, 2, 'Good morning everyone! #MondayMotivation', '2023-02-06 09:15:00'),
  (3, 1, 'Excited to be at #NEU!', '2023-11-01 08:30:00');

-- Link tweets to hashtags
INSERT INTO TweetHashtag (tweet_id, hashtag_id) VALUES
  (1, 1),
  (2, 2),
  (3, 3);

-- Insert follow relationships
INSERT INTO Follow (follower_id, followee_id) VALUES
  (1, 2), -- Mariam follows Mel
  (2, 1); -- Mel follows Mariam

-- Insert likes
INSERT INTO LikeTweet (like_id, user_id, tweet_id) VALUES
  (1, 2, 1),
  (2, 1, 2);

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

-- 2. For a specific user, list the 5 most recent tweets containing the hashtag "#NEU"
SELECT 
  t.tweet_id,
  t.content,
  t.time_tweeted
FROM Tweet t
JOIN TweetHashtag th ON t.tweet_id = th.tweet_id
JOIN Hashtag h ON th.hashtag_id = h.hashtag_id
WHERE t.user_id = 1 AND h.hashtag_name = '#NEU'
ORDER BY t.time_tweeted DESC
LIMIT 5;
