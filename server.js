// app.js or server.js
const express = require('express');
const sql = require('mssql');
const cors = require('cors');

const app = express();
app.use(cors()); // allow frontend to call backend
const path = require('path');
app.use(express.json());

// SQL config (adjust as needed)
const config = {
  user: 'sa',
  password: '12345',
  server: 'localhost',
  database: 'SportSync',
  options: {
    encrypt : false,
    trustServerCertificate: true,
    port : 1433
  }
};

let poolPromise = sql.connect(config);

//Route to fetch the full schedule
app.get('/schedule/full',async (req,res)=> {
  try {
    const pool = await poolPromise;
const result = await pool.request().query(`
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
      `);
    res.json(result.recordset);
  } catch(err) {
    console.error('Error fetching full schedule:',err);
    res.status(500).json({error: 'Failed to fetch schedule'});
  }
});

// Add this route to serve index.html by default
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Route to fetch all teams
app.get('/teams', async (req, res) => {
  try {
    const pool = await poolPromise;
const result = await pool.request().query(`SELECT * FROM Team`);
    res.json(result.recordset);
  } catch (err) {
    console.error(err);
    res.status(500).send('Database error');
  }
});

//route to select event
app.get('/events',async(req,res)=>{
  try {
   const pool = await poolPromise;
const result = await pool.request().query(`SELECT * FROM SportsEvent`);
    res.json(result.recordset);
  } catch(err) {
    console.error(err);
    res.status(500).send('Error fetching events');
  }
});

//to display team schedule
app.get('/schedule/team/:teamName', async (req, res) => {
  const teamName = req.params.teamName;
  console.log('Getting schedule for team:', teamName);
  try {
    const pool = await poolPromise;
    const result = await pool.request()
    .input('teamName',sql.NVarChar,teamName)
    .query(`
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
      WHERE t1.TeamName = @teamName OR t2.TeamName = @teamName
      ORDER BY s.MatchDate, s.MatchTime, s.MatchID
    `);

    res.json(result.recordset);
  } catch (error) {
    console.error('Error fetching team schedule:',error);
    res.status(500).send('Error fetching team schedule');
  }
});

//player individual schedule
app.get('/player/:id/schedule', async (req, res) => {
  const playerID = parseInt(req.params.id);

  try {
    const pool = await poolPromise;

    // 1) Get player info
    const playerResult = await pool.request()
      .input('playerID', sql.Int, playerID)
      .query(`
        SELECT p.PlayerID, p.PlayerName, t.TeamName
        FROM Player p
        JOIN Team t ON p.TeamID = t.TeamID
        WHERE p.PlayerID = @playerID
      `);

    if (playerResult.recordset.length === 0) {
      return res.status(404).json({ message: 'Player not found' });
    }

    const player = playerResult.recordset[0];

    // 2) Get player schedule
    const scheduleResult = await pool.request()
      .input('playerID', sql.Int, playerID)
      .query(`
        SELECT 
          e.EventName,
          t1.TeamName AS TeamName,
          v.VenueName,
          m.matchStatus,
          s.MatchDate,
          s.MatchTime,
          t2.TeamName AS OpponentTeam
        FROM Player p
        JOIN Team t1 ON p.TeamID = t1.TeamID
        JOIN Player_Event pe ON p.PlayerID = pe.PlayerID
        JOIN SportsEvent e ON pe.EventID = e.EventID
        LEFT JOIN Schedule s ON s.EventID = e.EventID 
          AND (s.TeamNo1 = p.TeamID OR s.TeamNo2 = p.TeamID)
        LEFT JOIN Matches m ON s.MatchID = m.MatchID
        LEFT JOIN Venue v ON m.VenueID = v.VenueID
        LEFT JOIN Team t2 ON 
          (s.TeamNo1 = p.TeamID AND s.TeamNo2 = t2.TeamID) OR 
          (s.TeamNo2 = p.TeamID AND s.TeamNo1 = t2.TeamID)
        WHERE p.PlayerID = @playerID
        ORDER BY e.EventName, s.MatchDate, s.MatchTime;
      `);

    res.json({
      player,
      schedule: scheduleResult.recordset
    });
  } catch (err) {
    console.error('Error fetching player schedule:', err);
    res.status(500).json({ message: 'Error fetching player schedule' });
  }
});

//schedule by evet
// Route to get event schedule
app.get('/schedule/event/:eventName', async (req, res) => {
  const eventName = req.params.eventName;
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('eventName', sql.NVarChar, eventName)
      .query(`
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
        WHERE e.EventName = @eventName
        ORDER BY s.MatchDate, s.MatchTime, s.MatchID
      `);
    res.json(result.recordset);
  } catch (error) {
    console.error('Error fetching event schedule:', error);
    res.status(500).send('Error fetching event schedule');
  }
});

//route to get scoreboard
app.get('/scoreboard', async (req, res) => {
  try {
    const pool = await poolPromise;
    const result = await pool.request().query(`
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
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error('Error fetching scoreboard:', err);
    res.status(500).json({ error: 'Failed to fetch scoreboard' });
  }
});

//route to update scores
app.put('/scoreboard/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  const { Team1Score, Team2Score,winnerTeamId } = req.body;

  try {
    const pool = await poolPromise;
    await pool.request()
      .input('id', sql.Int, id)
      .input('Team1Score', sql.Int, Team1Score)
      .input('Team2Score', sql.Int, Team2Score)
      .input('WinnerTeamID', sql.Int, winnerTeamId || null)
      .query(`
        UPDATE Scoreboard
        SET Team1Score = @Team1Score,
            Team2Score = @Team2Score,
            WinnerTeamID = @WinnerTeamID
        WHERE ScoreboardID = @id
      `);
    res.json({ message: 'Score updated successfully' });
  } catch (err) {
    console.error('Error updating score:', err);
    res.status(500).json({ error: 'Failed to update score' });
  }
});

//route to verify admin login
app.post('/login', async (req, res) => {
  const { UserID, Passcode } = req.body;
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('UserID', sql.Int, UserID)
      .input('Passcode', sql.VarChar, Passcode)
      .query(`SELECT * FROM SystemUser WHERE UserID = @UserID AND Passcode = @Passcode`);

    if (result.recordset.length === 0) {
      return res.status(401).json({ message: 'Invalid ID or Passcode' });
    }

    res.json({ message: 'Login successful' });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Login failed' });
  }
});


//player registeration
app.post('/register',async (req,res) =>{
    const { PlayerID, PlayerName, KitNo, Age, Department,events} = req.body;
 //Basic validation
  if (
    !PlayerID || !PlayerName || !KitNo || !Age || !Department || Age <= 0) {
    return res.status(400).json({ message: 'Please enter valid data.' });
  }

    try {
        await sql.connect(config);
    //Duplicate‐ID check
    const checkResult = await sql.query`
      SELECT 1 FROM Player WHERE PlayerID = ${PlayerID}
    `;
    if (checkResult.recordset.length > 0) {
      return res.status(400).json({ message: 'Player ID already exists!' });
    }
    const deptFirstWord = Department.split(' ')[0]; //e.g., "Compiter"
    const deptAbbrevMap = {
      'Computer' : 'CS',
      'Mechanical' : 'ME',
      'Electrical' : 'EE',
      'Space' : 'SS',
      'Aerospace' : 'AE',
      'Material' : 'MS'
    };

    const teamAbbrev = deptAbbrevMap[deptFirstWord];
    if(!teamAbbrev) {
      return res.status(400).json({message: 'Invalid department selected.'});
    }

    const teamResult = await sql.query`
    SELECT TeamID FROM Team WHERE TeamName = ${teamAbbrev}
    `;
     if (teamResult.recordset.length === 0) {
      return res.status(400).json({ message: 'No matching team found for department.' });
    }
    const TeamID = teamResult.recordset[0].TeamID;
        const query = `
        INSERT INTO Player (PlayerID, PlayerName, KitNo, Age, Department,TeamID)
        VALUES (@PlayerID, @PlayerName, @KitNo, @Age, @Department,@TeamID)
        `;
        const request = new sql.Request();
        request.input('PlayerID',sql.Int,PlayerID);
        request.input('PlayerName',sql.VarChar(100),PlayerName);
        request.input('KitNo',sql.VarChar(50),KitNo);
        request.input('Age',sql.Int,Age);
        request.input('Department',sql.VarChar(100),Department);
        request.input('TeamID',sql.Int,TeamID);
         await request.query(query);
        //insert selected events into Player_Event table
        if(Array.isArray(events)){
          for(const eventId of events) {
            await sql.query `
            INSERT INTO Player_Event (PlayerID,EventID)
            VALUES (${PlayerID},${parseInt(eventId)})
            `;
          }
        }
       
        res.json({ message: 'Player registered successfully! '});
    } catch(err) {
        console.error(err);
        res.status(500).json({message: 'Registeration failed.'});
    }
});

// Serve your static HTML/CSS/JS files
app.use(express.static(path.join(__dirname, 'public')));

app.listen(3000, () => console.log('Server running on http://localhost:3000'));


