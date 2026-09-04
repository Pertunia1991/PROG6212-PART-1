/* ============================================================
   RACEDAY EVENT MANAGEMENT SYSTEM
   PROG6212 - PROGRAMMING 2B
   PART 1: SYSTEM PLANNING AND DATABASE
   ============================================================ */


-- ============================================================
-- 1. CREATE DATABASE
-- ============================================================

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO


-- ============================================================
-- 2. USERS
-- ============================================================

CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) NOT NULL,

    FirstName NVARCHAR(50) NOT NULL,

    LastName NVARCHAR(50) NOT NULL,

    Email NVARCHAR(100) NOT NULL,

    PasswordHash NVARCHAR(255) NOT NULL,

    PhoneNumber NVARCHAR(20) NULL,

    Role NVARCHAR(20) NOT NULL,

    ProfilePictureURL NVARCHAR(500) NULL,

    CreatedDate DATETIME NOT NULL
        CONSTRAINT DF_Users_CreatedDate
        DEFAULT GETDATE(),

    CONSTRAINT PK_Users
        PRIMARY KEY (UserID),

    CONSTRAINT UQ_Users_Email
        UNIQUE (Email),

    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organiser', 'Participant'))
);
GO


-- ============================================================
-- 3. EVENT TYPES
-- ============================================================

CREATE TABLE EventTypes
(
    EventTypeID INT IDENTITY(1,1) NOT NULL,

    TypeName NVARCHAR(20) NOT NULL,

    CONSTRAINT PK_EventTypes
        PRIMARY KEY (EventTypeID),

    CONSTRAINT UQ_EventTypes_TypeName
        UNIQUE (TypeName)
);
GO


-- ============================================================
-- 4. EVENTS
-- ============================================================

CREATE TABLE Events
(
    EventID INT IDENTITY(1,1) NOT NULL,

    OrganiserID INT NOT NULL,

    EventTypeID INT NOT NULL,

    EventName NVARCHAR(100) NOT NULL,

    Description NVARCHAR(500) NULL,

    EventDate DATETIME NOT NULL,

    Location NVARCHAR(200) NOT NULL,

    Distance DECIMAL(6,2) NOT NULL,

    BannerImageURL NVARCHAR(500) NULL,

    CreatedDate DATETIME NOT NULL
        CONSTRAINT DF_Events_CreatedDate
        DEFAULT GETDATE(),

    CONSTRAINT PK_Events
        PRIMARY KEY (EventID),

    CONSTRAINT FK_Events_Users
        FOREIGN KEY (OrganiserID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Events_EventTypes
        FOREIGN KEY (EventTypeID)
        REFERENCES EventTypes(EventTypeID),

    CONSTRAINT CK_Events_Distance
        CHECK (Distance > 0)
);
GO


-- ============================================================
-- 5. CATEGORIES
-- ============================================================

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1,1) NOT NULL,

    EventID INT NOT NULL,

    CategoryName NVARCHAR(100) NOT NULL,

    MinimumAge INT NULL,

    MaximumAge INT NULL,

    Distance DECIMAL(6,2) NOT NULL,

    CONSTRAINT PK_Categories
        PRIMARY KEY (CategoryID),

    CONSTRAINT UQ_Categories_Event_Category
        UNIQUE (EventID, CategoryID),

    CONSTRAINT FK_Categories_Events
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT CK_Categories_MinimumAge
        CHECK (MinimumAge IS NULL OR MinimumAge >= 0),

    CONSTRAINT CK_Categories_MaximumAge
        CHECK (MaximumAge IS NULL OR MaximumAge >= 0),

    CONSTRAINT CK_Categories_AgeRange
        CHECK
        (
            MaximumAge IS NULL
            OR MinimumAge IS NULL
            OR MaximumAge >= MinimumAge
        ),

    CONSTRAINT CK_Categories_Distance
        CHECK (Distance > 0)
);
GO


-- ============================================================
-- 6. ENROLMENTS
-- ============================================================

CREATE TABLE Enrolments
(
    EnrolmentID INT IDENTITY(1,1) NOT NULL,

    ParticipantID INT NOT NULL,

    EventID INT NOT NULL,

    CategoryID INT NOT NULL,

    EnrolmentDate DATETIME NOT NULL
        CONSTRAINT DF_Enrolments_EnrolmentDate
        DEFAULT GETDATE(),

    Status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Enrolments_Status
        DEFAULT 'Confirmed',

    CONSTRAINT PK_Enrolments
        PRIMARY KEY (EnrolmentID),

    CONSTRAINT FK_Enrolments_Participant
        FOREIGN KEY (ParticipantID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Enrolments_Event
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT FK_Enrolments_Category
        FOREIGN KEY (EventID, CategoryID)
        REFERENCES Categories(EventID, CategoryID),

    CONSTRAINT CK_Enrolments_Status
        CHECK
        (
            Status IN ('Confirmed', 'Pending', 'Cancelled')
        )
);
GO


-- ============================================================
-- 7. RESULTS
-- ============================================================

CREATE TABLE Results
(
    ResultID INT IDENTITY(1,1) NOT NULL,

    EnrolmentID INT NOT NULL,

    FinishTime TIME NOT NULL,

    FinishPosition INT NOT NULL,

    ResultDate DATETIME NOT NULL
        CONSTRAINT DF_Results_ResultDate
        DEFAULT GETDATE(),

    CONSTRAINT PK_Results
        PRIMARY KEY (ResultID),

    CONSTRAINT UQ_Results_Enrolment
        UNIQUE (EnrolmentID),

    CONSTRAINT FK_Results_Enrolments
        FOREIGN KEY (EnrolmentID)
        REFERENCES Enrolments(EnrolmentID),

    CONSTRAINT CK_Results_FinishPosition
        CHECK (FinishPosition > 0)
);
GO


-- ============================================================
-- 8. SEED EVENT TYPES
-- ============================================================

INSERT INTO EventTypes
(
    TypeName
)
VALUES
('Run'),
('Walk'),
('Cycle');
GO


-- ============================================================
-- 9. SEED USERS
-- 2 ORGANISERS
-- 2 PARTICIPANTS
-- ============================================================

INSERT INTO Users
(
    FirstName,
    LastName,
    Email,
    PasswordHash,
    PhoneNumber,
    Role
)
VALUES
(
    'Thabo',
    'Mokoena',
    'thabo.mokoena@example.com',
    'HASHED_PASSWORD_1',
    '0711111111',
    'Organiser'
),
(
    'Lerato',
    'Dlamini',
    'lerato.dlamini@example.com',
    'HASHED_PASSWORD_2',
    '0722222222',
    'Organiser'
),
(
    'Sipho',
    'Nkosi',
    'sipho.nkosi@example.com',
    'HASHED_PASSWORD_3',
    '0733333333',
    'Participant'
),
(
    'Naledi',
    'Molefe',
    'naledi.molefe@example.com',
    'HASHED_PASSWORD_4',
    '0744444444',
    'Participant'
);
GO


-- ============================================================
-- 10. SEED EVENTS
-- 3 EVENTS
-- ============================================================

INSERT INTO Events
(
    OrganiserID,
    EventTypeID,
    EventName,
    Description,
    EventDate,
    Location,
    Distance
)
VALUES
(
    1,
    1,
    'Johannesburg City Run',
    'A 10km city running event.',
    '2026-10-10 08:00:00',
    'Johannesburg',
    10.00
),
(
    1,
    2,
    'Soweto Community Walk',
    'A community-focused walking event.',
    '2026-11-07 07:30:00',
    'Soweto',
    5.00
),
(
    2,
    3,
    'Pretoria Cycle Challenge',
    'A cycling event for recreational and competitive cyclists.',
    '2026-12-05 06:30:00',
    'Pretoria',
    21.00
);
GO


-- ============================================================
-- 11. SEED CATEGORIES
-- CATEGORIES ARE LINKED TO SPECIFIC EVENTS
-- ============================================================

INSERT INTO Categories
(
    EventID,
    CategoryName,
    MinimumAge,
    MaximumAge,
    Distance
)
VALUES
(
    1,
    'Under 20',
    14,
    19,
    10.00
),
(
    1,
    'Senior',
    20,
    NULL,
    10.00
),
(
    2,
    'Under 20',
    14,
    19,
    5.00
),
(
    2,
    'Senior',
    20,
    NULL,
    5.00
),
(
    3,
    'Under 20',
    16,
    19,
    21.00
),
(
    3,
    'Senior',
    20,
    NULL,
    21.00
);
GO


-- ============================================================
-- 12. SEED ENROLMENTS
-- CATEGORY MUST BELONG TO THE SELECTED EVENT
-- ============================================================

INSERT INTO Enrolments
(
    ParticipantID,
    EventID,
    CategoryID,
    Status
)
VALUES
(
    3,
    1,
    2,
    'Confirmed'
),
(
    4,
    1,
    2,
    'Confirmed'
),
(
    3,
    2,
    4,
    'Confirmed'
),
(
    4,
    3,
    6,
    'Pending'
);
GO


-- ============================================================
-- 13. SEED RESULTS
-- ============================================================

INSERT INTO Results
(
    EnrolmentID,
    FinishTime,
    FinishPosition
)
VALUES
(
    1,
    '00:52:34',
    15
),
(
    2,
    '00:58:21',
    27
);
GO


-- ============================================================
-- 14. VERIFY DATABASE CONTENT
-- ============================================================

SELECT * FROM Users;

SELECT * FROM EventTypes;

SELECT * FROM Events;

SELECT * FROM Categories;

SELECT * FROM Enrolments;

SELECT * FROM Results;
GO