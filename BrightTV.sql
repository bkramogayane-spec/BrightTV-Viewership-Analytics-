---Data checks 
---Check all column names and data types
SELECT*
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA;

SELECT*
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA;

---Returns only records with matching UserID in both tables
SELECT v.*, u.*
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA v
INNER JOIN BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA u ON v.UserID = u.UserID;

---Returns all records from Viewership, and matched records from UserProfiles.
SELECT v.*, u.*
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA v
LEFT JOIN BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA u ON v.UserID = u.UserID;

---Returns all records from UserProfiles, and matched records from Viewership.
SELECT v.channel2,
COUNT(DISTINCT v.USERID) AS TotalUsers
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA v
INNER JOIN BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA u ON v.UserID = u.UserID
GROUP BY v.Channel2;

---User and Usage Trends 
---5375 recorded
SELECT UserID
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA
UNION
SELECT UserID 
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA;


SELECT 
    v.Channel2,
    COUNT(DISTINCT u.UserID) AS TotalUsers
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA u
JOIN BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA v
    ON u.UserID = v.UserID
GROUP BY v.Channel2
ORDER BY TotalUsers DESC;



SELECT 
    v.Channel2,
    COUNT(DISTINCT u.UserID) AS TotalUsers
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA u
JOIN BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA v
    ON u.UserID = v.UserID
GROUP BY v.Channel2
ORDER BY TotalUsers DESC;


---10 000 recorded
SELECT COUNT(*) AS TotalSessions 
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA;

---Factors Influencing Consumption 
---sessions per age group
SELECT AGE, 
COUNT(*) AS Sessions 
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA 
JOIN BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA USING(UserID) 
GROUP BY AGE 
ORDER BY Sessions DESC;

---Group sessions by gender including non-allocated
SELECT Gender, 
COUNT(*) AS Sessions 
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA 
JOIN BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA USING(UserID) 
GROUP BY Gender 
ORDER BY Sessions DESC;

---Group sessions by provinces including non-allocated
SELECT province, 
COUNT(*) AS Sessions 
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA
JOIN BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA USING(UserID) 
GROUP BY province 
ORDER BY Sessions DESC;

---UTC to SAST Conversion---Time & Date
-------Function to split the tiem and date in the RecordDate2 column
SELECT 
    RecordDate2,
    split_part(RecordDate2, ' ', 1) AS date_part,
    split_part(RecordDate2, ' ', 2) AS time_part, 
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA;

---function to convert date into date format and time into time format
SELECT 
    RecordDate2,
    TO_DATE(REPLACE(SPLIT_PART(RecordDate2, ' ', 1), '/', '-'), 'YYYY-MM-DD') AS date_part,
    CAST(SPLIT_PART(RecordDate2, ' ', 2) AS TIME) AS time_part
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA;

SELECT
    RecordDate2,
    -- Convert string to timestamp in UTC and then to RSA time
    CONVERT_TIMEZONE(
        'UTC', 
        'Africa/Johannesburg', 
        TO_TIMESTAMP(RecordDate2, 'YYYY/MM/DD HH24:MI')
    ) AS rsa_timestamp,
    -- Extract date and time separately if needed
    DATE(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', TO_TIMESTAMP(RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS rsa_date,
    TIME(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', TO_TIMESTAMP(RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS rsa_time
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA;

---Viewership by Province
SELECT u.province
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA v
INNER JOIN BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA u ON v.UserID = u.UserID
GROUP BY u.Province;

---Viewership by Age Group
SELECT 
    CASE 
        WHEN u.Age < 18 THEN '<18'
        WHEN u.Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN u.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN u.Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN u.Age BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60+'
    END AS AgeGroup,
    COUNT(*) AS Sessions,
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA v
INNER JOIN BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA u ON v.UserID = u.UserID
GROUP BY CASE 
        WHEN u.Age < 18 THEN '<18'
        WHEN u.Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN u.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN u.Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN u.Age BETWEEN 45 AND 59 THEN '45-59'
        ELSE '60+'
    END;
---ORDER BY TotalMinutes DESC;
---Sessions by age group
SELECT 
     CASE
          WHEN Age BETWEEN 0 AND 17 THEN 'Under 18'
           WHEN Age BETWEEN 18 AND 25 THEN '18-25'
           WHEN Age BETWEEN 26 AND 35 THEN '26-35'
           WHEN Age BETWEEN 36 AND 45 THEN '36-45'
           WHEN Age BETWEEN 46 AND 60 THEN '46-60'
           ELSE '60+'
      END AS AgeGroup,
      COUNT(*) AS Sessions
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA
JOIN BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA USING(UserID)
GROUP BY AgeGroup
ORDER BY Sessions DESC;

-- Sessions by gender
SELECT Gender, COUNT(*) AS Sessions
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA
JOIN BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA USING(UserID)
GROUP BY Gender
ORDER BY Sessions DESC;

-- Sessions by province
SELECT Province, COUNT(*) AS Sessions
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA
JOIN BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA USING(UserID)
GROUP BY Province
ORDER BY Sessions DESC;

---Top 10 Channels by Viewership
SELECT 
    v.Channel2,
    SUM(DATEDIFF(MINUTE, '00:00:00', v.Duration2)) AS TotalMinutes
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA v
GROUP BY v.Channel2
ORDER BY TotalMinutes DESC
LIMIT 10;

-- Average session duration (in seconds)
SELECT 
    AVG(
        SPLIT_PART(Duration2, ':', 1)::INT * 3600 +
        SPLIT_PART(Duration2, ':', 2)::INT * 60 +
        SPLIT_PART(Duration2, ':', 3)::INT
    ) AS avg_seconds
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA;

--- Identify low-consumption days (below average sessions)
SELECT rsa_date,Sessions
FROM (
    SELECT 
        DATE(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', TO_TIMESTAMP(RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS rsa_date,
           COUNT(*) AS Sessions
    FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA
    GROUP BY rsa_date
) AS Daily
WHERE Sessions < (
    SELECT AVG(SessionCount)
    FROM (
        SELECT COUNT(*) AS SessionCount
        FROM BrightTV_Viewership
        GROUP BY DATE(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', TO_TIMESTAMP(RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS rsa_date,
    ) AS AvgSessions
)
ORDER BY Sessions;


-- Most popular channels on low-consumption days
SELECT Channel2, COUNT(*) AS Sessions
FROM BrightTV_Viewership
WHERE DATE(CONVERT_TZ(RecordDate2, '+00:00', '+02:00')) IN (
    SELECT SA_Date
    FROM (
        SELECT DATE(CONVERT_TZ(RecordDate2, '+00:00', '+02:00')) AS SA_Date,
               COUNT(*) AS Sessions
        FROM BrightTV_Viewership
        GROUP BY SA_Date
        HAVING COUNT(*) < (
            SELECT AVG(SessionCount)
            FROM (
                SELECT COUNT(*) AS SessionCount
                FROM BrightTV_Viewership
                GROUP BY DATE(CONVERT_TZ(RecordDate2, '+00:00', '+02:00'))
            ) AS AvgSessions
        )
    ) AS LowDays
)
GROUP BY Channel2
ORDER BY Sessions DESC;

-- Active users per month
SELECT 
    Channel2,
    SUM(
        SPLIT_PART(Duration2, ':', 1)::INT * 3600 +
        SPLIT_PART(Duration2, ':', 2)::INT * 60 +
        SPLIT_PART(Duration2, ':', 3)::INT
    ) AS total_duration_seconds
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA
GROUP BY Channel2
ORDER BY total_duration_seconds DESC;


-- Channels with highest engagement
SELECT Channel2,
       COUNT(*) AS Sessions,
       AVG(
        SPLIT_PART(Duration2, ':', 1)::INT * 3600 +
        SPLIT_PART(Duration2, ':', 2)::INT * 60 +
        SPLIT_PART(Duration2, ':', 3)::INT
    )  AS AvgDurationSeconds
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA
GROUP BY Channel2
ORDER BY Sessions DESC,
AvgDurationSeconds DESC;


SELECT 
    Channel2,
    -- Total duration in seconds
    SUM(
        SPLIT_PART(Duration2, ':', 1)::INT * 3600 +
        SPLIT_PART(Duration2, ':', 2)::INT * 60 +
        SPLIT_PART(Duration2, ':', 3)::INT
    ) AS total_duration_seconds,

    -- Total duration formatted as HH:MI:SS
    TO_VARCHAR(
        DATEADD(
            second, 
            SUM(
                SPLIT_PART(Duration2, ':', 1)::INT * 3600 +
                SPLIT_PART(Duration2, ':', 2)::INT * 60 +
                SPLIT_PART(Duration2, ':', 3)::INT
            ), 
            '00:00:00'::TIME
        ), 
        'HH24:MI:SS'
    ) AS total_duration_time
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA
GROUP BY Channel2
ORDER BY total_duration_seconds DESC;

    SUM(Duration2) AS total_viewing_time
FROM BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA
GROUP BY Channel2 
ORDER BY total_viewing_time DESC;

------------------Final code--------------------
SELECT CHANNEL2,
       GENDER,
       RACE,
       PROVINCE,
----Classification of age groups
CASE
    WHEN Age BETWEEN 0 AND 17 THEN 'Under 18'
    WHEN Age BETWEEN 18 AND 25 THEN '18-25'
    WHEN Age BETWEEN 26 AND 35 THEN '26-35'
    WHEN Age BETWEEN 36 AND 45 THEN '36-45'
    WHEN Age BETWEEN 46 AND 60 THEN '46-60'
    ELSE '60+'
    END AS AgeGroup,
    COUNT(*) AS Sessions,

    RecordDate2,

    -- Extraction of date and time separately 
    DATE(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', TO_TIMESTAMP(RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS rsa_date,
    TIME(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', TO_TIMESTAMP(RecordDate2, 'YYYY/MM/DD HH24:MI'))) AS rsa_time,
    Duration2,
    
FROM BRIGHTTV.BRIGHTTV_USERPROFILES.USERPROFILESDATA
JOIN BRIGHTTV.BRIGHTTV_VIEWERSHIP.VIEWERSHIPDATA USING(UserID)
GROUP BY ALL;
