--INSERT QUERIES
USE SportSync;

INSERT INTO Head (HeadID, HeadName, DeptName) VALUES
(101, 'Tufail Sajjad', 'Computer Science'),
(102, 'Shazia Noor', 'Mechanical Engineering'),
(103, 'Ahmed Iqbal', 'Electrical Engineering'),
(104, 'Fawad Khan', 'Space Science'),
(105, 'Nadeem Yousaf', 'Aerospace Engineering'),
(106, 'Filza Fatima', 'Material Sciences');
SELECT * FROM Head;

INSERT INTO SystemUser(UserID,UserName, Passcode) VALUES
(1234,'Shehla Gul', '0000'),
(5678,'Shakira Baig', '1234');
SELECT * FROM SystemUser;

INSERT INTO Player(PlayerID,PlayerName, KitNo,Age,Department) VALUES
(241201010,'Fuzail Faraz', 10, 19, 'Computer Science');
SELECT * FROM Player;
	
INSERT INTO Team(TeamID,TeamName,TotalMembers,CurrentMembers) VALUES
(1,'CS',10,4),
(2,'ME',10,9),
(3,'EE',10,6),
(4,'SS',10,7),
(5,'AE',10,1),
(6,'MS',10,5);
SELECT * FROM Team;

INSERT INTO Venue(VenueID,VenueName,VenueStatus) VALUES
--initially all venues available
(1,'Futsal Court', 'Available'),
(2, 'Football Ground','Available'),
(3,'Badminton Court','Available'),
(4,'Tennis Court','Available'),
(5,'BasketBall Court','Available');
SELECT * FROM Venue;

-- Matches for 6 events × 6 matches = 36
INSERT INTO Matches (MatchID, VenueID, MatchStatus) VALUES
-- Futsal Matches (VenueID = 1)
(1, 1, 'Not Started'), (2, 1, 'Not Started'), (3, 1, 'Not Started'),
(4, 1, 'Not Started'), (5, 1, 'Not Started'), (6, 1, 'Not Started'),
-- Football Matches (VenueID = 2)
(7, 2, 'Not Started'), (8, 2, 'Not Started'), (9, 2, 'Not Started'),
(10, 2, 'Not Started'), (11, 2, 'Not Started'), (12, 2, 'Not Started'),
-- Badminton Matches (VenueID = 3)
(13, 3, 'Not Started'), (14, 3, 'Not Started'), (15, 3, 'Not Started'),
(16, 3, 'Not Started'), (17, 3, 'Not Started'), (18, 3, 'Not Started'),
-- Tennis Matches (VenueID = 4)
(19, 4, 'Not Started'), (20, 4, 'Not Started'), (21, 4, 'Not Started'),
(22, 4, 'Not Started'), (23, 4, 'Not Started'), (24, 4, 'Not Started'),
-- Basketball Matches (VenueID = 5)
(25, 5, 'Not Started'), (26, 5, 'Not Started'), (27, 5, 'Not Started'),
(28, 5, 'Not Started'), (29, 5, 'Not Started'), (30, 5, 'Not Started'),
-- Tug of War Matches (VenueID = 2)
(31, 2, 'Not Started'), (32, 2, 'Not Started'), (33, 2, 'Not Started'),
(34, 2, 'Not Started'), (35, 2, 'Not Started'), (36, 2, 'Not Started');
SELECT * FROM Matches;


INSERT INTO SportsEvent (EventID,EventName,HeadID) VALUES 
(1,'Football',101),
(2,'Futsal',105),
(3,'Badminton',102),
(5,'BasketBall',104),
(4,'Tennis',103),
(6,'Tug of War',106);
SELECT * FROM SportsEvent;

-- Use this match pattern each time:
-- CS vs EE (1 vs 3)
-- MS vs ME (6 vs 2)
-- SS vs AE (4 vs 5)
-- AE vs CS (5 vs 1)
-- SS vs MS (4 vs 6)
-- EE vs ME (3 vs 2)

-- Helper: EventID Mapping
-- 1 = Football, 2 = Futsal, 3 = Badminton, 4 = Basketball, 5 = Tennis, 6 = Tug of War

INSERT INTO Schedule (MatchID, TeamNo1, TeamNo2, EventID, MatchDate, MatchTime) VALUES
-- DAY 1 (2023-04-13)
(1, 1, 3, 2, '2023-04-13', '09:00:00'), -- CS vs EE - Futsal
(7, 6, 2, 1, '2023-04-13', '09:00:00'), -- MS vs ME - Football 
(13, 4, 5, 3, '2023-04-13', '10:00:00'), -- SS vs AE - Badminton
(19, 5, 1, 5, '2023-04-13', '11:00:00'), -- AE vs CS - Tennis
(25, 4, 6, 4, '2023-04-13', '11:00:00'), -- SS vs MS - BasketBall
(31, 3, 2, 6, '2023-04-13', '12:00:00'), -- EE vs ME - Tug of War

-- DAY 2 (2023-04-14)
(2, 1, 3, 2, '2023-04-14', '09:00:00'), -- CS vs EE - Futsal
(14, 6, 2, 3, '2023-04-14', '09:00:00'), -- MS vs ME - Badminton 
(26, 4, 5, 4, '2023-04-14', '10:00:00'), -- SS vs AE - Basketball
(20, 5, 1, 5, '2023-04-14', '11:00:00'), -- AE vs CS - Tennis
(32, 4, 6, 6, '2023-04-14', '11:00:00'), -- SS vs MS - Tug of War
(8, 3, 2, 1, '2023-04-14', '12:00:00'), -- EE vs ME - Football

-- DAY 3 (2023-04-15)
(15, 1, 3, 3, '2023-04-15', '09:00:00'), -- CS vs EE - Badminton
(27, 6, 2, 4, '2023-04-15', '09:00:00'), -- MS vs ME - Basketball
(21, 4, 5, 5, '2023-04-15', '10:00:00'), -- SS vs AE - Tennis
(33, 5, 1, 6, '2023-04-15', '11:00:00'), -- AE vs CS - Tug of War
(9, 4, 6, 1, '2023-04-15', '11:00:00'), -- SS vs MS - Football 
(3, 3, 2, 2, '2023-04-15', '12:00:00'), -- EE vs ME - Futsal


-- DAY 4 (2023-04-16)
(28, 1, 3, 4, '2023-04-16', '09:00:00'), -- CS vs EE - Basketball
(22, 6, 2, 5, '2023-04-16', '09:00:00'), -- MS vs ME - Tennis
(34, 4, 5, 6, '2023-04-16', '10:00:00'), -- SS vs AE - Tug of War
(10, 5, 1, 1, '2023-04-16', '11:00:00'), -- AE vs CS - Football
(4, 4, 6, 2, '2023-04-16', '11:00:00'), -- SS vs MS - Futsal 
(16, 3, 2, 3, '2023-04-16', '12:00:00'), -- EE vs ME - Badminton

-- DAY 5 (2023-04-16)
(23, 1, 3, 5, '2023-04-17', '09:00:00'), -- CS vs EE - Tennis
(35, 6, 2, 6, '2023-04-17', '09:00:00'), -- MS vs ME - Tug of war    
(11, 4, 5, 1, '2023-04-17', '10:00:00'), -- SS vs AE - Football
(5, 5, 1, 2, '2023-04-17', '11:00:00'), -- AE vs CS - Futsal
(17, 4, 6, 3, '2023-04-17', '11:00:00'), -- SS vs MS - Badminton
(29, 3, 2, 4, '2023-04-17', '12:00:00'), -- EE vs ME - Basketball
-- DAY 6 (2023-04-18)
(36, 1, 3, 6, '2023-04-18', '09:00:00'), -- CS vs EE - Tug of war
(12, 6, 2, 1, '2023-04-18', '09:00:00'), -- MS vs ME - Football
(6, 4, 5, 2, '2023-04-18', '10:00:00'), -- SS vs AE - Futsal
(18, 5, 1, 3, '2023-04-18', '11:00:00'), -- AE vs CS - Badminton
(30, 4, 6, 4, '2023-04-18', '11:00:00'), -- SS vs MS - BasketBall
(24, 3, 2, 5, '2023-04-18', '12:00:00'); -- EE vs ME - Tennis

SELECT * FROM Schedule;

SELECT * FROM Player_Event;

INSERT INTO Scoreboard (MatchID, Team1ID, Team2ID, Team1Score, Team2Score, WinnerTeamID) VALUES
(1, 1, 3, 0, 0, NULL),(2, 6, 2, 0, 0, NULL),
(3, 4, 5, 0, 0, NULL),(4, 5, 1, 0, 0, NULL),
(5, 4, 6, 0, 0, NULL),(6, 3, 2, 0, 0, NULL),
(7, 1, 3, 0, 0, NULL),(8, 6, 2, 0, 0, NULL),
(9, 4, 5, 0, 0, NULL),(10, 5, 1, 0, 0, NULL),
(11, 4, 6, 0, 0, NULL),(12, 3, 2, 0, 0, NULL),
(13, 1, 3, 0, 0, NULL),(14, 6, 2, 0, 0, NULL),
(15, 4, 5, 0, 0, NULL),(16, 5, 1, 0, 0, NULL),
(17, 4, 6, 0, 0, NULL),(18, 3, 2, 0, 0, NULL),
(19, 1, 3, 0, 0, NULL),(20, 6, 2, 0, 0, NULL),
(21, 4, 5, 0, 0, NULL),(22, 5, 1, 0, 0, NULL),
(23, 4, 6, 0, 0, NULL),(24, 3, 2, 0, 0, NULL),
(25, 1, 3, 0, 0, NULL),(26, 6, 2, 0, 0, NULL),
(27, 4, 5, 0, 0, NULL),(28, 5, 1, 0, 0, NULL),
(29, 4, 6, 0, 0, NULL),(30, 3, 2, 0, 0, NULL),
(31, 1, 3, 0, 0, NULL),(32, 6, 2, 0, 0, NULL),
(33, 4, 5, 0, 0, NULL),(34, 5, 1, 0, 0, NULL),
(35, 4, 6, 0, 0, NULL),(36, 3, 2, 0, 0, NULL);
Select *from Scoreboard;
