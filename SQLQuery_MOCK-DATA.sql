


-- Insert Shift Types
INSERT INTO ShiftType (TimeSlotName, StartTime, EndTime) VALUES 
('9-14', '09:00:00', '14:00:00'),
('14-19', '14:00:00', '19:00:00');


/* =========================================================
   1. MOCK EMPLOYEES
   ======================================================== */

INSERT INTO Employee (FirstName, LastName, Phone, Email, IsActive, IsLeader)
VALUES
('Pedro',   'Martinez', '555-0101', 'pedro@example.com',   1, 1),
('Jacoby',  'Williams', '555-0102', 'jacoby@example.com',  1, 1),
('Emma',    'Johnson',  '555-0103', 'emma@example.com',    1, 0),
('Liam',    'Brown',    '555-0104', 'liam@example.com',    1, 0),
('Olivia',  'Davis',    '555-0105', 'olivia@example.com',  1, 0),
('Noah',    'Miller',   '555-0106', 'noah@example.com',    1, 0),
('Ava',     'Wilson',   '555-0107', 'ava@example.com',     1, 0),
('Ethan',   'Moore',    '555-0108', 'ethan@example.com',   1, 0),
('Sophia',  'Taylor',   '555-0109', 'sophia@example.com',  1, 0),
('Lucas',   'Anderson', '555-0110', 'lucas@example.com',   1, 0);
GO


/* =========================================================
   2. CREATE NOVEMBER 2026 SCHEDULE MONTH
   ========================================================= */

DECLARE @ScheduleMonthID INT;

INSERT INTO ScheduleMonth (TargetYear, TargetMonth, Status)
VALUES (2026, 11, 'Draft');

SET @ScheduleMonthID = SCOPE_IDENTITY();


/* =========================================================
   3. CREATE ALL DAILY SHIFTS FOR NOVEMBER 2026
   ========================================================= */

DECLARE @StartDate DATE = '2026-11-01';
DECLARE @EndDate   DATE = '2026-11-30';

INSERT INTO DailyShift
    (ScheduleMonthID, ShiftDate, ShiftTypeID)
SELECT
    @ScheduleMonthID,
    D.ShiftDate,
    ST.ShiftTypeID
FROM
(
    SELECT DATEADD(DAY, Number, @StartDate) AS ShiftDate
    FROM
    (
        SELECT TOP (30)
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS Number
        FROM sys.all_objects
    ) N
) D
CROSS JOIN ShiftType ST
WHERE D.ShiftDate <= @EndDate;
GO




/* ---------------------------------------------------------
   Leader rotation

   Shift 1 -> Pedro
   Shift 2 -> Jacoby
   Shift 3 -> Pedro
   Shift 4 -> Jacoby
   ...
   --------------------------------------------------------- */

;WITH ShiftList AS
(
    SELECT
        DS.DailyShiftID,
        DS.ShiftDate,
        DS.ShiftTypeID,
        ROW_NUMBER() OVER
        (
            ORDER BY DS.ShiftDate, DS.ShiftTypeID
        ) AS ShiftNumber
    FROM DailyShift DS
    INNER JOIN ScheduleMonth SM
        ON DS.ScheduleMonthID = SM.ScheduleMonthID
    WHERE
        SM.TargetYear = 2026
        AND SM.TargetMonth = 11
),
Leaders AS
(
    SELECT
        E.EmployeeID,
        ROW_NUMBER() OVER
        (
            ORDER BY E.EmployeeID
        ) AS LeaderNumber
    FROM Employee E
    WHERE E.FirstName IN ('Pedro', 'Jacoby')
      AND E.IsActive = 1
)
INSERT INTO ShiftAssignment
(
    DailyShiftID,
    EmployeeID

)
SELECT
    S.DailyShiftID,
    L.EmployeeID
FROM ShiftList S
INNER JOIN Leaders L
    ON L.LeaderNumber =
       CASE
           WHEN S.ShiftNumber % 2 = 1 THEN 1
           ELSE 2
       END;


/* =========================================================
   5. WORKER ASSIGNMENTS

   Eight workers:
   Emma, Liam, Olivia, Noah,
   Ava, Ethan, Sophia, Lucas

   Three workers are assigned to every shift.
   The starting position rotates based on the shift number.
   ========================================================= */

;WITH ShiftList AS
(
    SELECT
        DS.DailyShiftID,
        ROW_NUMBER() OVER
        (
            ORDER BY DS.ShiftDate, DS.ShiftTypeID
        ) AS ShiftNumber
    FROM DailyShift DS
    INNER JOIN ScheduleMonth SM
        ON DS.ScheduleMonthID = SM.ScheduleMonthID
    WHERE
        SM.TargetYear = 2026
        AND SM.TargetMonth = 11
),
Workers AS
(
    SELECT
        E.EmployeeID,
        ROW_NUMBER() OVER
        (
            ORDER BY E.EmployeeID
        ) AS WorkerNumber
    FROM Employee E
    WHERE E.FirstName NOT IN ('Pedro', 'Jacoby')
      AND E.IsActive = 1
),
WorkerCount AS
(
    SELECT COUNT(*) AS TotalWorkers
    FROM Workers
),
WorkerAssignments AS
(
    SELECT
        S.DailyShiftID,
        S.ShiftNumber,
        W.EmployeeID,
        W.WorkerNumber,
        WC.TotalWorkers
    FROM ShiftList S
    CROSS JOIN Workers W
    CROSS JOIN WorkerCount WC
    WHERE
        (
            W.WorkerNumber =
                ((S.ShiftNumber - 1) % WC.TotalWorkers) + 1

            OR

            W.WorkerNumber =
                ((S.ShiftNumber) % WC.TotalWorkers) + 1

            OR

            W.WorkerNumber =
                ((S.ShiftNumber + 1) % WC.TotalWorkers) + 1
        )
)
INSERT INTO ShiftAssignment
(
    DailyShiftID,
    EmployeeID
    
)
SELECT
    DailyShiftID,
    EmployeeID
    
FROM WorkerAssignments;
GO
