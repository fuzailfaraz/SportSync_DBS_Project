USE SportSync;
--emptying the database
DELETE FROM Player_Event

DELETE FROM Player

UPDATE Team
SET CurrentMembers = 0
SELECT * FROM Team

--Full Schedule 
SELECT 
	s.MatchID,
	t1.TeamName AS Team1,
	t2.TeamName AS Team2,
	e.EventName AS Sport,
	v.VenueName AS Venue,
	h.HeadName AS Head,
	m.matchStatus,
	s.MatchDate,
	s.MatchTime
FROM Schedule s
JOIN Team t1 ON s.TeamNo1 = t1.TeamID
JOIN Team t2 ON s.TeamNo2 = t2.TeamID
JOIN SportsEvent e ON s.EventID = e.EventID
JOIN Matches m ON s.MatchID = m.MatchID
JOIN Venue v ON m.VenueID = v.VenueID
JOIN Head h ON e.HeadID = h.HeadID
ORDER BY s.MatchDate, s.MatchTime, s.MatchID

--View only a team matches
DECLARE @TeamName NVARCHAR(100);		--declaring a variable
SET @TeamName = 'CS';		--dynamically assign teamname, this value changes -> timetable of different team called.
SELECT 
	s.MatchID,
	t1.TeamName AS Team1,
	t2.TeamName AS Team2,
	e.EventName AS Sport,
	v.VenueName AS Venue,
	h.HeadName AS Head,
	m.MatchStatus,
	s.MatchDate,
	s.MatchTime
FROM Schedule s
JOIN Team t1 ON s.TeamNo1 = t1.TeamID
JOIN Team t2 ON s.TeamNo2 = t2.TeamID
JOIN SportsEvent e ON s.EventID = e.EventID
JOIN Matches m ON s.MatchID = m.MatchID
JOIN Venue v ON m.VenueID = v.VenueID
JOIN Head h ON e.HeadID = h.HeadID
WHERE t1.TeamName = @TeamName OR t2.TeamName = @TeamName
ORDER BY s.MatchDate, s.MatchTime, s.MatchID

--for individual player schedule
DECLARE @playerID INT = 1234; --replace with actual playerid

SELECT 
  p.PlayerID,
  p.PlayerName,
  p.Department,
  t.TeamName,
  e.EventName,
  s.MatchID,
  v.VenueName,
  m.MatchStatus,
  s.MatchDate,
  s.MatchTime,
  t1.TeamName AS OpponentTeam
FROM Player p
JOIN Team t ON p.TeamID = t.TeamID
JOIN Player_Event pe ON p.PlayerID = pe.PlayerID
JOIN SportsEvent e ON pe.EventID = e.EventID
LEFT JOIN Schedule s ON s.EventID = e.EventID 
    AND (s.TeamNo1 = p.TeamID OR s.TeamNo2 = p.TeamID)
LEFT JOIN Matches m ON s.MatchID = m.MatchID
LEFT JOIN Venue v ON m.VenueID = v.VenueID
LEFT JOIN Team t1 ON 
    (s.TeamNo1 = p.TeamID AND s.TeamNo2 = t1.TeamID) OR 
    (s.TeamNo2 = p.TeamID AND s.TeamNo1 = t1.TeamID)
WHERE p.PlayerID = @playerID
ORDER BY e.EventName, s.MatchDate, s.MatchTime;

--Schedule by event
DECLARE @eventName NVARCHAR(100);		--declaring a variable
SET @EventName = 'Football';	
SELECT 
	s.MatchID,
	t1.TeamName AS Team1,
	t2.TeamName AS Team2,
	e.EventName AS Sport,
	v.VenueName AS Venue,
	h.HeadName AS Head,
	m.MatchStatus,
	s.MatchDate,
	s.MatchTime
FROM Schedule s
JOIN Team t1 ON s.TeamNo1 = t1.TeamID
JOIN Team t2 ON s.TeamNo2 = t2.TeamID
JOIN SportsEvent e ON s.EventID = e.EventID
JOIN Matches m ON s.MatchID = m.MatchID
JOIN Venue v ON m.VenueID = v.VenueID
JOIN Head h ON e.HeadID = h.HeadID
WHERE e.EventName = @eventName
ORDER BY s.MatchDate, s.MatchTime, s.MatchID


--automatically incrementing current members in team
CREATE TRIGGER UpdateCurrentMembers_AfterInsert
ON Player
AFTER INSERT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		-- Add the inserted players to the team's current member count
		UPDATE t
		SET t.CurrentMembers = t.CurrentMembers + c.NumPlayers
		FROM Team t
		JOIN (
			SELECT TeamID, COUNT(*) AS NumPlayers
			FROM inserted
			GROUP BY TeamID
		) c ON t.TeamID = c.TeamID;

		COMMIT;
	END TRY
	BEGIN CATCH		--if an error occurs, it rollbacks
		ROLLBACK;
		THROW;
	END CATCH;
END;

--Scoreboard view 
SELECT 
    s.MatchID, 
    t1.TeamName AS Team1, 
    t2.TeamName AS Team2, 
    s.Team1Score, 
    s.Team2Score, 
    ISNULL(t3.TeamName, 'Match Undecided') AS Winner
FROM Scoreboard s
JOIN Team t1 ON s.Team1ID = t1.TeamID
JOIN Team t2 ON s.Team2ID = t2.TeamID
LEFT JOIN Team t3 ON s.WinnerTeamID = t3.TeamID
ORDER BY s.MatchID;

-- Updating Scoreboard for ADMIN:

CREATE Procedure AdminUpdateScoreboard  
    @UserID INT, 
    @MatchID INT, 
    @Team1Score INT, 
    @Team2Score INT, 
    @WinnerTeamID INT
AS
BEGIN
    -- Check if the user exists (assuming Admins have specific UserIDs)
    IF @UserID NOT IN (1234, 5678) -- Replace with actual Admin UserIDs
    BEGIN
        PRINT 'Access Denied: Only authorized users can modify match scores!';
        RETURN; -- Immediately exit procedure
    END

    -- Update Scoreboard only if user is authorized
    UPDATE Scoreboard
    SET Team1Score = @Team1Score, 
        Team2Score = @Team2Score, 
        WinnerTeamID = @WinnerTeamID
    WHERE MatchID = @MatchID;
END;

