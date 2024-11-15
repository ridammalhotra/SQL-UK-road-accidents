--Create tables accidents and vehicle
CREATE TABLE accidents
(
AccidentIndex VARCHAR(50) PRIMARY KEY,
Severity VARCHAR(50),
Date DATE,
Day	VARCHAR(20),
SpeedLimit	INT,
LightConditions	VARCHAR(20),
WeatherConditions VARCHAR(50),
RoadConditions	VARCHAR(20),
Area VARCHAR(10)
)

Create Table vehicle
(VehicleID	VARCHAR(50) PRIMARY KEY,
AccidentIndex VARCHAR(50), 
VehicleType	VARCHAR(20),
PointImpact	VARCHAR(50),
LeftHand VARCHAR(10),
JourneyPurpose	VARCHAR(50),
Propulsion	VARCHAR(50),
AgeVehicle INTEGER,
CONSTRAINT fk_vehicle FOREIGN KEY(AccidentIndex) REFERENCES accidents(AccidentIndex)
)

SELECT * FROM accidents
SELECT * FROM vehicle

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------Business Queries--------------------------------------
--1: How many accidents have occurred in urban areas versus rural areas?
SELECT area, COUNT(accidentindex)as number
FROM accidents
GROUP BY area


--2: Which day of the week has the highest number of accidents?
SELECT day, COUNT(accidentindex) as number
FROM accidents
GROUP BY day
ORDER BY number desc
LIMIT 1

--3: What is the average age of vehicles involved in accidents based on their type?
SELECT ROUND(AVG(agevehicle),2) 
FROM vehicle

--4: Can we identify any trends in accidents based on the age of vehicles involved?
SELECT 
(CASE 
WHEN agevehicle BETWEEN 1 AND 5 THEN '1-5'
WHEN agevehicle BETWEEN 5 AND 10 THEN '5-10'
WHEN agevehicle BETWEEN 10 AND 15 THEN '10-15'
WHEN agevehicle BETWEEN 15 AND 25 THEN '15-25'
WHEN agevehicle BETWEEN 25 AND 50 THEN '25-50'
ELSE '>50'
END) AS age_of_vehicle,
COUNT(accidentindex) as number
FROM vehicle
WHERE agevehicle IS NOT NULL
GROUP BY age_of_vehicle
ORDER BY number desc


--5: Are there any specific weather conditions that contribute to severe accidents?
SELECT weatherconditions, COUNT(accidentindex) as number
FROM accidents
WHERE weatherconditions <> 'Unknown' AND weatherconditions <> 'Other'
GROUP BY weatherconditions
ORDER BY number desc

--6: Do accidents often involve impacts on the left-hand side of vehicles?
SELECT (COUNT(lefty)-SUM(lefty))as rightside, SUM(lefty) as leftside
FROM 
(SELECT 
(CASE WHEN lefthand = 'Yes' Then 1 ELSE 0
END)
as lefty
FROM vehicle)

 
--7: Are there any relationships between journey purposes and the severity of accidents?
SELECT vehicle.journeypurpose,
SUM(CASE 
WHEN  accidents.severity = 'Slight' then 1 ELSE 0
END) as slight,
SUM(CASE 
WHEN  accidents.severity = 'Serious' then 1 ELSE 0
END) as serious,
SUM(CASE 
WHEN  accidents.severity = 'Fatal' then 1 ELSE 0
END) as fatal
FROM accidents
LEFT JOIN vehicle
ON accidents.accidentindex= vehicle.accidentindex
WHERE vehicle.journeypurpose NOT IN ('Not known', 'Other', 'Data missing or out of range')
GROUP BY vehicle.journeypurpose

--8: Calculate the average age of vehicles involved in accidents , considering Day light and point of impact:
SELECT vehicle.pointimpact, ROUND(AVG(vehicle.agevehicle),2)
FROM accidents
LEFT JOIN vehicle
ON accidents.accidentindex= vehicle.accidentindex
WHERE accidents.lightconditions= 'Daylight' 
GROUP BY vehicle.pointimpact
ORDER BY round desc

--9: What are the number of casualties in each month?
SELECT EXTRACT(MONTH FROM to_date(date, 'DD/MM/YYYY')) as month,
COUNT(accidentindex)
FROM accidents
GROUP BY month
ORDER BY month asc


--10: What are the most frequent weather conditions associated with accidents?
SELECT weatherconditions, COUNT(accidentindex)
FROM accidents
GROUP BY weatherconditions 
ORDER BY COUNT(accidentindex) desc

--11: What are the most common types of vehicles involved in accidents?
SELECT vehicletype, COUNT(accidentindex)
FROM vehicle
GROUP BY vehicletype
ORDER BY COUNT(accidentindex) desc

--12: Verify if most accidents happens during the night or day.
SELECT lightconditions, COUNT(accidentindex)
FROM accidents
GROUP BY lightconditions
ORDER BY COUNT(accidentindex) desc
