--CREATE DATABASE RaceDay;
GO

USE RaceDay;
GO

DROP TABLE IF EXISTS Results;
DROP TABLE IF EXISTS Enrolments;
DROP TABLE IF EXISTS EventCategories;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Users;
GO

CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL DEFAULT 'Participant',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organiser', 'Participant'))
);
GO

CREATE TABLE Events
(
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    EventName VARCHAR(100) NOT NULL,
    EventDescription VARCHAR(500),
    EventDate DATE NOT NULL,
    Location VARCHAR(150) NOT NULL,
    DistanceKM DECIMAL(6,2) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Upcoming',

    CONSTRAINT FK_Events_Users
        FOREIGN KEY (OrganiserID)
        REFERENCES Users(UserID),

    CONSTRAINT CK_Events_Distance
        CHECK (DistanceKM > 0),

    CONSTRAINT CK_Events_Status
        CHECK (Status IN ('Upcoming', 'Active', 'Completed', 'Cancelled'))
);
GO

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255)
);
GO

CREATE TABLE EventCategories
(
    EventCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,

    CONSTRAINT FK_EventCategories_Events
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT FK_EventCategories_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT UQ_EventCategories
        UNIQUE (EventID, CategoryID)
);
GO

CREATE TABLE Enrolments
(
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status VARCHAR(20) NOT NULL DEFAULT 'Registered',

    CONSTRAINT FK_Enrolments_Participant
        FOREIGN KEY (ParticipantID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Enrolments_Event
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT FK_Enrolments_Category
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT UQ_Enrolments
        UNIQUE (ParticipantID, EventID, CategoryID),

    CONSTRAINT CK_Enrolments_Status
        CHECK (Status IN ('Registered', 'Completed', 'Cancelled'))
);
GO

CREATE TABLE Results
(
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,
    FinishTime TIME NULL,
    Position INT NULL,
    ResultStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',

    CONSTRAINT FK_Results_Enrolments
        FOREIGN KEY (EnrolmentID)
        REFERENCES Enrolments(EnrolmentID),

    CONSTRAINT CK_Results_Position
        CHECK (Position IS NULL OR Position > 0),

    CONSTRAINT CK_Results_Status
        CHECK (ResultStatus IN ('Pending', 'Finished', 'Did Not Finish'))
);
GO

INSERT INTO Users
    (FirstName, LastName, Email, PasswordHash, Role)
VALUES
    ('Thabo', 'Mokoena', 'thabo@raceday.co.za', 'Password123!', 'Organiser'),
    ('Naledi', 'Molefe', 'naledi@raceday.co.za', 'Password456!', 'Organiser'),
    ('Cathrine', 'Letsoalo', 'cathrine@gmail.com', 'Password789!', 'Participant'),
    ('Sipho', 'Dlamini', 'sipho@gmail.com', 'Password321!', 'Participant'),
    ('Lerato', 'Nkosi', 'lerato@gmail.com', 'Password654!', 'Participant');
GO

INSERT INTO Categories
    (CategoryName, Description)
VALUES
    ('5 KM Run', 'A 5 kilometre road running category'),
    ('10 KM Run', 'A 10 kilometre road running category'),
    ('21 KM Half Marathon', 'A 21 kilometre half marathon category'),
    ('5 KM Walk', 'A 5 kilometre walking category'),
    ('20 KM Cycle', 'A 20 kilometre cycling category');
GO

INSERT INTO Events
    (OrganiserID, EventName, EventDescription, EventDate, Location, DistanceKM, Status)
VALUES
    (1, 'Johannesburg Road Race', 'A community road running event in Johannesburg', '2026-10-10', 'Johannesburg', 10.00, 'Upcoming'),
    (1, 'Soweto Community Run', 'A community running and walking event', '2026-11-07', 'Soweto', 5.00, 'Upcoming'),
    (2, 'Pretoria Charity Race', 'A charity running and cycling event', '2026-12-05', 'Pretoria', 21.00, 'Upcoming');
GO

INSERT INTO EventCategories
    (EventID, CategoryID)
VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (2, 1),
    (2, 4),
    (3, 2),
    (3, 3),
    (3, 5);
GO

INSERT INTO Enrolments
    (ParticipantID, EventID, CategoryID, Status)
VALUES
    (3, 1, 1, 'Registered'),
    (3, 1, 2, 'Registered'),
    (4, 1, 2, 'Registered'),
    (4, 2, 1, 'Registered'),
    (5, 2, 4, 'Registered'),
    (5, 3, 3, 'Registered');
GO

INSERT INTO Results
    (EnrolmentID, FinishTime, Position, ResultStatus)
VALUES
    (1, '00:28:35', 12, 'Finished'),
    (2, '00:55:42', 8, 'Finished'),
    (3, '00:52:18', 5, 'Finished'),
    (4, '00:26:44', 7, 'Finished'),
    (5, '00:48:21', 15, 'Finished'),
    (6, NULL, NULL, 'Pending');
GO

SELECT * FROM Users;
GO

SELECT * FROM Events;
GO

SELECT * FROM Categories;
GO

SELECT * FROM EventCategories;
GO

SELECT * FROM Enrolments;
GO

SELECT * FROM Results;
GO

SELECT
    E.EventID,
    E.EventName,
    E.EventDate,
    E.Location,
    U.FirstName + ' ' + U.LastName AS Organiser
FROM Events E
INNER JOIN Users U
    ON E.OrganiserID = U.UserID;
GO

SELECT
    E.EventName,
    C.CategoryName
FROM EventCategories EC
INNER JOIN Events E
    ON EC.EventID = E.EventID
INNER JOIN Categories C
    ON EC.CategoryID = C.CategoryID
ORDER BY E.EventName;
GO

SELECT
    U.FirstName + ' ' + U.LastName AS Participant,
    E.EventName,
    C.CategoryName,
    EN.EnrolmentDate,
    EN.Status
FROM Enrolments EN
INNER JOIN Users U
    ON EN.ParticipantID = U.UserID
INNER JOIN Events E
    ON EN.EventID = E.EventID
INNER JOIN Categories C
    ON EN.CategoryID = C.CategoryID
ORDER BY E.EventName, Participant;
GO

SELECT
    U.FirstName + ' ' + U.LastName AS Participant,
    E.EventName,
    C.CategoryName,
    R.FinishTime,
    R.Position,
    R.ResultStatus
FROM Results R
INNER JOIN Enrolments EN
    ON R.EnrolmentID = EN.EnrolmentID
INNER JOIN Users U
    ON EN.ParticipantID = U.UserID
INNER JOIN Events E
    ON EN.EventID = E.EventID
INNER JOIN Categories C
    ON EN.CategoryID = C.CategoryID
ORDER BY R.Position;
GO