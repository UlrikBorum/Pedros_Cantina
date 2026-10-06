
-- View a Monthly Schedule
CREATE VIEW [MonthlySchedule] AS
SELECT
    ds.ShiftDate,
    st.TimeSlotName AS [TimeSlot],
	st.StartTime,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    IIF(IsLeader = 1, 'Leader', 'Worker') AS Role,
    sm.TargetYear,
    sm.TargetMonth
FROM DailyShift ds
JOIN ShiftType st ON ds.ShiftTypeID = st.ShiftTypeID
JOIN ScheduleMonth sm ON ds.ScheduleMonthID = sm.ScheduleMonthID
JOIN ShiftAssignment sa ON ds.DailyShiftID = sa.DailyShiftID
JOIN Employee e ON sa.EmployeeID = e.EmployeeID;


-- See the monthly schedule for November 2026
SELECT ShiftDate, EmployeeName, TimeSlot, Role FROM [MonthlySchedule]
WHERE TargetYear = 2026 AND TargetMonth =11
ORDER BY ShiftDate ASC, StartTime ASC;


-- View Individual Employee Workloads for a Month
CREATE VIEW [EmployeeWorkloadSummary] AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    e.IsLeader,
    sm.TargetYear,
    sm.TargetMonth,
    COUNT(sa.ShiftAssignmentID) AS TotalShiftsInMonth,
    COUNT(sa.ShiftAssignmentID) * 5 AS TotalHoursInMonth
FROM Employee e
JOIN ShiftAssignment sa ON e.EmployeeID = sa.EmployeeID
JOIN DailyShift ds ON sa.DailyShiftID = ds.DailyShiftID
JOIN ScheduleMonth sm ON ds.ScheduleMonthID = sm.ScheduleMonthID
GROUP BY e.EmployeeID, e.FirstName, e.LastName, e.IsLeader, sm.TargetYear, sm.TargetMonth;
GO

-- See the workload summary for November 2026
SELECT EmployeeName, TotalShiftsInMonth, TotalHoursInMonth FROM EmployeeWorkloadSummary
WHERE TargetYear = 2026 AND TargetMonth = 11



-- View available employees for a specific shift
CREATE VIEW [AvailableEmployeesForShift] AS 
SELECT 
    sa.DailyShiftID, 
    e.FirstName + ' ' + e.LastName AS EmployeeName, 
    e.Phone, 
    e.IsLeader, 
    e.Email 
FROM Employee e
LEFT JOIN ShiftAssignment sa 
    ON e.EmployeeID = sa.EmployeeID
WHERE e.IsActive = 1;
GO

-- Check the available employees for a specific shift (DailyShiftID = 1)
SELECT EmployeeName, Phone, IIF(IsLeader = 1, 'Leader', 'Worker') AS Role, Email 
FROM [AvailableEmployeesForShift]
WHERE DailyShiftID = 1; 



-- Summarize employee workloads over the course of the year
CREATE VIEW [EmployeeHoursWorked] AS
SELECT 
    e.FirstName + ' ' + e.LastName AS EmployeeName, 
    sm.TargetMonth AS [Month], 
	sm.TargetYear AS [Year],
    COUNT(sa.ShiftAssignmentID) AS ShiftsWorked, 
    COUNT(sa.ShiftAssignmentID) * 5 AS HoursWorked 
FROM Employee e 
JOIN ShiftAssignment sa ON e.EmployeeID = sa.EmployeeID 
JOIN DailyShift ds ON sa.DailyShiftID = ds.DailyShiftID 
JOIN ScheduleMonth sm ON ds.ScheduleMonthID = sm.ScheduleMonthID 
GROUP BY e.EmployeeID, e.FirstName, e.LastName, sm.TargetMonth, sm.TargetYear;
GO

-- See the summary of employee workloads for 2026
SELECT * FROM EmployeeHoursWorked
WHERE [Year] = 2026



-- A. Create a new monthly schedule container
INSERT INTO ScheduleMonth (TargetYear, TargetMonth, Status)
VALUES (2026, 12, 'Draft');

-- B. Generate an individual daily shift slot inside that month container
-- (Assume ScheduleMonthID 2 matches our new Nov 2026 container, and ShiftTypeID 1 is '9-14')
INSERT INTO DailyShift (ScheduleMonthID, ShiftDate, ShiftTypeID)
VALUES (2, '2026-12-01', 1);

-- C. Assign an employee to that newly created slot (EmployeeID 2, RoleID 2)
INSERT INTO ShiftAssignment (DailyShiftID, EmployeeID)
VALUES (SCOPE_IDENTITY(), 2);

-- D. Adjust an existing schedule: Swap or update an employee assignment
-- (Changes who is filling a specific assignment slot)
UPDATE ShiftAssignment
SET EmployeeID = 3 -- New employee covering the assignment
WHERE ShiftAssignmentID = 45; -- Target assignment ID

-- E. Adjust an existing schedule: Remove an assignment completely
DELETE FROM ShiftAssignment
WHERE ShiftAssignmentID = 45;





-- clear every table for a fresh start (Including reseeding the identity columns)
DELETE FROM ShiftAssignment;
DELETE FROM DailyShift;
DELETE FROM ScheduleMonth;
DELETE FROM Employee;
DELETE FROM ShiftType;
DBCC CHECKIDENT ('ShiftAssignment', RESEED, 0);
DBCC CHECKIDENT ('DailyShift', RESEED, 0);
DBCC CHECKIDENT ('ScheduleMonth', RESEED, 0);
DBCC CHECKIDENT ('Employee', RESEED, 0);
DBCC CHECKIDENT ('ShiftType', RESEED, 0);
-- SQLQuery_MOCK-DATA.sql contains data for 2026-11, so we can re-run that script 
-- to repopulate the tables with the same data for testing purposes.


-- Create a new employee
INSERT INTO Employee (FirstName, LastName, Phone, Email, IsLeader, IsActive)
Values (@FirstName, @LastName, @Phone, @Email, @IsLeader, @IsActive);



-- Extra:
-- Publish a monthly schedule only if all shifts meet staffing requirements (3 workers and 1 leader per shift)
DECLARE @TargetYear INT = 2026;
DECLARE @TargetMonth INT = 11;

UPDATE ScheduleMonth
SET Status = 'Published'
WHERE TargetYear = @TargetYear 
  AND TargetMonth = @TargetMonth
  AND Status = 'Draft'
  AND NOT EXISTS (
      -- Find any shift in this month that fails the staffing requirements
      SELECT 1
      FROM DailyShift ds
      LEFT JOIN ShiftAssignment sa ON ds.DailyShiftID = sa.DailyShiftID
      LEFT JOIN Employee e ON sa.EmployeeID = e.EmployeeID
      WHERE ds.ScheduleMonthID = ScheduleMonth.ScheduleMonthID
      GROUP BY ds.DailyShiftID
      HAVING 
          COUNT(CASE WHEN e.IsLeader = 0 THEN 1 END) < 3
          OR 
          COUNT(CASE WHEN e.IsLeader = 1 THEN 1 END) < 1
  );

  -- see the status of the month after attempting to publish

  SELECT * FROM ScheduleMonth 
  WHERE TargetYear = 2026 AND TargetMonth = 11;