USE SportSync;
-- head: relation with event, schedule

CREATE TABLE Head (
    HeadID INT PRIMARY KEY,
    HeadName VARCHAR(100),
    DeptName VARCHAR(100) 
);

--systemUser
CREATE TABLE SystemUser (
   UserID INT PRIMARY KEY,
   UserName VARCHAR(100),
   Passcode VARCHAR(50) );

-- team, relation with player, schedule
CREATE TABLE Team (
    TeamID INT PRIMARY KEY,
    TeamName VARCHAR(100), 
	TotalMembers INT,
    CurrentMembers INT
);

-- player: relation with team
CREATE TABLE Player (
    PlayerID INT PRIMARY KEY,
    PlayerName VARCHAR(100),
    KitNo VARCHAR(50),		
    Age INT,
    Department VARCHAR(100),
	TeamID INT,
	FOREIGN KEY(TeamID) REFERENCES Team(TeamID)
);

-- venue: relation with matches,schedule
CREATE TABLE Venue (
    VenueID INT PRIMARY KEY,
    VenueName VARCHAR(100),
    VenueStatus VARCHAR(50) -- like available, booked
);

-- matches: match details || relation with venue, schedule	
CREATE TABLE Matches (
    MatchID INT PRIMARY KEY,
    VenueID INT, 
    MatchStatus VARCHAR(50),
    FOREIGN KEY (VenueID) REFERENCES Venue(VenueID)
);

-- event: every event is managed by a head
CREATE TABLE SportsEvent (	
    EventID INT PRIMARY KEY,
    EventName VARCHAR(100),
    HeadID INT,
	FOREIGN KEY (HeadID) REFERENCES Head (HeadID)
);

CREATE TABLE Player_Event(
	PlayerID INT,
	EventID INT,
	FOREIGN KEY(PlayerID) REFERENCES Player(PlayerID),
	FOREIGN KEY(EventID) REFERENCES SportsEvent(EventID)
);

-- schedule: main association to view the timetable
--
CREATE TABLE Schedule (
    MatchID INT NOT NULL, -- connects to matches table
    TeamNo1 INT NOT NULL, --TeamID 1
	TeamNo2 INT NOT NULL, --TeamId 2
	EventID INT NOT NULL,
    MatchDate DATE,
    MatchTime TIME,
    FOREIGN KEY (MatchID) REFERENCES Matches(MatchID),
    FOREIGN KEY (TeamNo1) REFERENCES Team(TeamID),
	FOREIGN KEY (TeamNo2) REFERENCES Team(TeamID),
	FOREIGN KEY (EventID) REFERENCES SportsEvent(EventID)
);

-- relation between team and player; associative table
CREATE TABLE Player_in_Team(
	PlayerID INT,
	TeamID INT,
	FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID),
	FOREIGN KEY (TeamID) REFERENCES Team(TeamID)
);
SELECT * FROM Player_in_Team;

--scoreboard
CREATE TABLE Scoreboard (
    ScoreboardID INT PRIMARY KEY IDENTITY(1,1),
    MatchID INT NOT NULL,
    Team1ID INT NOT NULL,
    Team2ID INT NOT NULL,
    Team1Score INT NOT NULL DEFAULT 0,
    Team2Score INT NOT NULL DEFAULT 0,
    WinnerTeamID INT NULL, -- NULL until the match is decided
    FOREIGN KEY (MatchID) REFERENCES Matches(MatchID),
    FOREIGN KEY (Team1ID) REFERENCES Team(TeamID),
    FOREIGN KEY (Team2ID) REFERENCES Team(TeamID),
    FOREIGN KEY (WinnerTeamID) REFERENCES Team(TeamID)
);
SELECT * FROM Scoreboard;

DROP TABLE Player_in_Team;
DROP TABLE Schedule;
DROP TABLE SportsEvent;
DROP TABLE Matches;
DROP TABLE Venue;
DROP TABLE Team;
DROP TABLE Player;
DROP TABLE Head;
