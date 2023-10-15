SELECT *
FROM RaysPitching.dbo.LastPitchRays
SELECT *
FROM RaysPitching.dbo.RaysPitchingStats

--Question 1 AVG Pitches Per at Bat Analysis

--1a AVG Pitches Per At Bat (LastPitchRays)

SELECT AVG(1.00*pitch_number) AvgNumofPitchesPerAtBat
FROM RaysPitching.dbo.LastPitchRays


--1b AVG Pitches Per At Bat Home Vs Away (LastPitchRays) -> Union

SELECT 
	'Home' Typeofgame,
	AVG(1.00*pitch_number) AvgNumofPitchesPerAtBat
	FROM RaysPitching.dbo.LastPitchRays
WHERE home_team = 'TB'
UNION
SELECT 
	'Away' TypeofGame,
	AVG(1.00*pitch_number) AvgNumofPitchesPerAtBat
FROM RaysPitching.dbo.LastPitchRays
WHERE away_team = 'TB'

--1c AVG Pitches Per At Bat Lefty Vs Righty  -> Case Statement 

SELECT 
	AVG(Case when batter_position = 'L' Then 1.00 * pitch_number end) LeftyatBats,
	AVG(Case when batter_position = 'R' Then 1.00 * pitch_number end) RightyatBats
FROM RaysPitching.dbo.LastPitchRays

--1d AVG Pitches Per At Bat Lefty Vs Righty Pitcher | Each Away Team -> Partition By

SELECT DISTINCT
	home_team,
	pitcher_position,
	AVG(1.00*pitch_number) OVER (Partition by home_team, pitcher_position) AvgatBats
FROM RaysPitching.dbo.LastPitchRays
WHERE away_team = 'TB'

--1e Top 3 Most Common Pitch for at bat 1 through 10, and total amounts (LastPitchRays)

WITH totalpitchsequence as (
	SELECT DISTINCT
		pitch_name,
		pitch_number,
		count(pitch_name) OVER (Partition by pitch_name, pitch_number) PitchFrequency
	FROM RaysPitching.dbo.LastPitchRays
	WHERE pitch_number <11
),
pitchfrequencyrankquery as (
	SELECT
	pitch_name,
	pitch_number,
	PitchFrequency,
	rank() OVER (Partition by pitch_number order by PitchFrequency desc) PitchFrequencyRanking
FROM totalpitchsequence
)
SELECT *
FROM pitchfrequencyrankquery
WHERE PitchFrequencyRanking < 4


--1f AVG Pitches Per at Bat Per Pitcher with 20+ Innings | Order in descending (LastPitchRays + RaysPitchingStats)

SELECT *
FROM  RaysPitching.dbo.LastPitchRays LPR
JOIN RaysPitching.dbo.RaysPitchingStats RPS ON RPS.Pitcher = LPR.pitcher

SELECT 
	RPS.Name, 
	AVG(1.00*pitch_number) AVGPitches
FROM RaysPitching.dbo.LastPitchRays LPR
JOIN RaysPitching.dbo.RaysPitchingStats RPS ON RPS.Pitcher = LPR.pitcher
WHERE IP >= 20
group by RPS.Name
order by AVG(1.00*pitch_number) DESC

--Question 2 Last Pitch Analysis

--2a Count of the Last Pitches Thrown in Desc Order (LastPitchRays)
--2b Count of the different last pitches Fastball or Offspeed (LastPitchRays)
--2c Percentage of the different last pitches Fastball or Offspeed (LastPitchRays)
--2d Top 5 Most common last pitch for a Relief Pitcher vs Starting Pitcher (LastPitchRays + RaysPitchingStats)

--Question 3 Homerun analysis

--3a What pitches have given up the most HRs (LastPitchRays) 
--3b Show HRs given up by zone and pitch, show top 5 most common
--3c Show HRs for each count type -> Balls/Strikes + Type of Pitcher
--3d Show Each Pitchers Most Common count to give up a HR (Min 30 IP)


--Question 4 Shane McClanahan

--4a AVG Release speed, spin rate,  strikeouts, most popular zone ONLY USING LastPitchRays
--4b top pitches for each infield position where total pitches are over 5, rank them
--4c Show different balls/strikes as well as frequency when someone is on base 
--4d What pitch causes the lowest launch speed