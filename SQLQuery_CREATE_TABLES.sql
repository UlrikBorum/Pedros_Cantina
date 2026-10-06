-- 1. Employee Management Table    
CREATE TABLE [dbo].[Employee] (
    [EmployeeID] INT            IDENTITY (1, 1) NOT NULL,
    [FirstName]  NVARCHAR (50)  NOT NULL,
    [LastName]   NVARCHAR (50)  NOT NULL,
    [Phone]      NVARCHAR (20)  NOT NULL,
    [Email]      NVARCHAR (100) NULL,
    [IsActive]   BIT            DEFAULT ((1)) NOT NULL,
    [IsLeader]   BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([EmployeeID] ASC) 
);

-- 3. Shift Types Lookup Table (Defines 9-14 and 14-19)
CREATE TABLE [dbo].[ShiftType] (
    [ShiftTypeID]  INT           IDENTITY (1, 1) NOT NULL,
    [TimeSlotName] NVARCHAR (20) NOT NULL, -- e.g., "9-14" or "14-19"
    [StartTime]    TIME (7)      NOT NULL,
    [EndTime]      TIME (7)      NOT NULL,
    PRIMARY KEY CLUSTERED ([ShiftTypeID] ASC),
    UNIQUE NONCLUSTERED ([TimeSlotName] ASC)
);

-- 4. Schedule Month Container (For tracking schedule planning states)
CREATE TABLE [dbo].[ScheduleMonth] (
    [ScheduleMonthID] INT           IDENTITY (1, 1) NOT NULL,
    [TargetYear]      INT           NOT NULL,
    [TargetMonth]     INT           NOT NULL,
    [Status]          NVARCHAR (20) DEFAULT ('Draft') NOT NULL,
    PRIMARY KEY CLUSTERED ([ScheduleMonthID] ASC),
    CONSTRAINT [UQ_YearMonth] UNIQUE NONCLUSTERED ([TargetYear] ASC, [TargetMonth] ASC),
    CONSTRAINT [CHK_Month] CHECK ([TargetMonth]>=(1) AND [TargetMonth]<=(12)),
    CONSTRAINT [CHK_Year] CHECK ([TargetYear]>=(2026))
);

-- 5. Daily Shifts Table (Bridges months to specific calendar days and time slots)
CREATE TABLE [dbo].[DailyShift] (
    [DailyShiftID]    INT  IDENTITY (1, 1) NOT NULL,
    [ScheduleMonthID] INT  NOT NULL,
    [ShiftDate]       DATE NOT NULL,
    [ShiftTypeID]     INT  NOT NULL,
    PRIMARY KEY CLUSTERED ([DailyShiftID] ASC),
    CONSTRAINT [UQ_DailyShift_Slot] UNIQUE NONCLUSTERED ([ShiftDate] ASC, [ShiftTypeID] ASC),
    CONSTRAINT [FK_DailyShift_ScheduleMonth] FOREIGN KEY ([ScheduleMonthID]) REFERENCES [dbo].[ScheduleMonth] ([ScheduleMonthID]),
    CONSTRAINT [FK_DailyShift_ShiftType] FOREIGN KEY ([ShiftTypeID]) REFERENCES [dbo].[ShiftType] ([ShiftTypeID])
);

-- 6. Shift Assignments Table (The actual bridge mapping workers to shifts and capacities)
CREATE TABLE [dbo].[ShiftAssignment] (
    [ShiftAssignmentID] INT IDENTITY (1, 1) NOT NULL,
    [DailyShiftID]      INT NOT NULL,
    [EmployeeID]        INT NOT NULL,
    PRIMARY KEY CLUSTERED ([ShiftAssignmentID] ASC),
    CONSTRAINT [UQ_Employee_Per_Shift] UNIQUE NONCLUSTERED ([DailyShiftID] ASC, [EmployeeID] ASC),
    CONSTRAINT [FK_ShiftAssignment_DailyShift] FOREIGN KEY ([DailyShiftID]) REFERENCES [dbo].[DailyShift] ([DailyShiftID]) ON DELETE CASCADE,
    CONSTRAINT [FK_ShiftAssignment_Employee] FOREIGN KEY ([EmployeeID]) REFERENCES [dbo].[Employee] ([EmployeeID])
);
GO