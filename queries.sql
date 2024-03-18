-- Query (a)
SELECT 
    ssn_patient 'SSN', name 'Name'
FROM
    patient a
WHERE
    DATEDIFF(SYSDATE(), birthday) / 365 >= 30
        AND UPPER(gender) = 'MALE'
        AND EXISTS( SELECT 
            1
        FROM
            prescription b
        WHERE
            a.ssn_patient = b.ssn_patient
                AND YEAR(datetime) = 2021);

-- Query (b)
SELECT 
    ssn_patient AS 'SSN'
FROM
    patient a
WHERE
    UPPER(gender) = 'FEMALE'
        AND EXISTS( SELECT 
            1
        FROM
            prescription b,
            drug c
        WHERE
            a.ssn_patient = b.ssn_patient
                AND b.iddrug = c.iddrug
                AND YEAR(datetime) = 2021
        GROUP BY ssn_patient
        HAVING SUM(b.quantity * c.price) > 1000);
        
-- Query (c)
SELECT 
    a.idarea AS 'Area ID',
    a.name AS 'Area Name',
    IFNULL(SUM(c.quantity * d.price), 0) AS 'Total Amount of Drugs'
FROM
    area a
        LEFT JOIN
    doctor b ON (a.idarea = b.idarea)
        LEFT JOIN
    prescription c ON (b.iddoctor = c.iddoctor)
        LEFT JOIN
    drug d ON (c.iddrug = d.iddrug)
GROUP BY a.idarea;

-- Query (d)
SELECT 
    iddrug AS 'Drug ID',
    SUM(IF(Month = 1, Total, 0)) AS 'Jan 2021',
    SUM(IF(Month = 2, Total, 0)) AS 'Feb 2021',
    SUM(IF(Month = 3, Total, 0)) AS 'Mar 2021',
    SUM(IF(Month = 4, Total, 0)) AS 'Apr 2021',
    SUM(IF(Month = 5, Total, 0)) AS 'May 2021',
    SUM(IF(Month = 6, Total, 0)) AS 'Jun 2021',
    SUM(IF(Month = 7, Total, 0)) AS 'Jul 2021',
    SUM(IF(Month = 8, Total, 0)) AS 'Aug 2021',
    SUM(IF(Month = 9, Total, 0)) AS 'Sep 2021',
    SUM(IF(Month = 10, Total, 0)) AS 'Oct 2021',
    SUM(IF(Month = 11, Total, 0)) AS 'Nov 2021',
    SUM(IF(Month = 12, Total, 0)) AS 'Dec 2021'
FROM
    (SELECT 
        a.iddrug AS 'Drug',
            MONTH(datetime) AS 'Month',
            IFNULL(SUM(a.quantity * b.price), 0) AS 'Total'
    FROM
        prescription a, drug b
    WHERE
        YEAR(datetime) = 2021
            AND a.iddrug = b.iddrug
    GROUP BY a.iddrug , MONTH(datetime)) a
        RIGHT JOIN
    drug b ON (a.Drug = b.iddrug)
GROUP BY iddrug;

-- Query (e)
SELECT 
    a.iddoctor AS 'Doctor ID',
    a.name AS 'Doctor Name',
    IFNULL(SUM(b.quantity * c.price), 0) AS 'Total Amount of Prescriptions'
FROM
    doctor a
        LEFT JOIN
    prescription b ON (a.iddoctor = b.iddoctor)
        LEFT JOIN
    drug c ON (b.iddrug = c.iddrug)
WHERE
    a.iddoctor IN (SELECT 
            iddoctor
        FROM
            doctor a,
            area b
        WHERE
            a.idarea = b.idarea
                AND mean_income BETWEEN 20000 AND 30000)
GROUP BY a.iddoctor;

-- Query (f)
SELECT 
    specialization AS 'Specialization',
    COUNT(idprescription) AS 'Total Number of Prescriptions'
FROM
    doctor a
        LEFT JOIN
    (SELECT 
        *
    FROM
        prescription
    WHERE
        YEAR(datetime) = 2021) b ON (a.iddoctor = b.iddoctor)
GROUP BY specialization;

-- Query (g)
WITH prescr2020 AS (
SELECT 
    a.iddrug, IFNULL(SUM(c.quantity * a.price), 0) AS total
FROM
    drug a
        LEFT JOIN
    (SELECT 
        *
    FROM
        prescription
    WHERE
        YEAR(datetime) = 2020) c ON (a.iddrug = c.iddrug)
GROUP BY a.iddrug
),
prescr2021 AS (
SELECT 
    a.iddrug, IFNULL(SUM(b.quantity * a.price), 0) AS total
FROM
    drug a
        LEFT JOIN
    (SELECT 
        *
    FROM
        prescription
    WHERE
        YEAR(datetime) = 2021) b ON (a.iddrug = b.iddrug)
GROUP BY a.iddrug
)
SELECT 
    a.iddrug AS 'Drug ID',
    CASE
        WHEN 100 * (b.total - a.total) / a.total IS NOT NULL THEN ROUND(100 * (b.total - a.total) / a.total, 1)
        WHEN a.total = 0 AND b.total = 0 THEN 0
        ELSE CONCAT('Undefined (from 0 to ', b.total, ')')
    END AS 'Percentage Change'
FROM
    prescr2020 a,
    prescr2021 b
WHERE
    a.iddrug = b.iddrug;

-- Query (h)
WITH male AS (
SELECT 
    a.iddrug, IFNULL(SUM(b.quantity * a.price), 0) AS total
FROM
    drug a
        LEFT JOIN
    prescription b ON (a.iddrug = b.iddrug)
        LEFT JOIN
    patient c ON (b.ssn_patient = c.ssn_patient)
WHERE
    UPPER(gender) = 'MALE'
        AND YEAR(datetime) = 2021
GROUP BY a.iddrug
),
female AS (
SELECT 
    a.iddrug, IFNULL(SUM(b.quantity * a.price), 0) AS total
FROM
    drug a
        LEFT JOIN
    prescription b ON (a.iddrug = b.iddrug)
        LEFT JOIN
    patient c ON (b.ssn_patient = c.ssn_patient)
WHERE
    UPPER(gender) = 'FEMALE'
        AND YEAR(datetime) = 2021
GROUP BY a.iddrug
)
SELECT 
    a.iddrug AS 'Drug ID',
    IFNULL(b.total, 0) AS Male,
    IFNULL(c.total, 0) AS Female
FROM
    drug a
        LEFT JOIN
    male b ON (a.iddrug = b.iddrug)
        LEFT JOIN
    female c ON (a.iddrug = c.iddrug)
GROUP BY a.iddrug;