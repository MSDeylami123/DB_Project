USE mydb;
CREATE TABLE User (
    UserID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20) UNIQUE,
    UserType ENUM('Passenger', 'Support') NOT NULL,
    City VARCHAR(50),
    PasswordHash VARCHAR(255) NOT NULL,
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    AccountStatus ENUM('Active', 'Inactive') DEFAULT 'Active',
    CHECK (Email IS NOT NULL OR Phone IS NOT NULL)
);

CREATE TABLE Passenger (
    UserID INT PRIMARY KEY,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

CREATE TABLE WebsiteSupport (
    UserID INT PRIMARY KEY,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

CREATE TABLE Reservation (
    ReservationID INT PRIMARY KEY,
    UserID INT NOT NULL,
    TicketID INT NOT NULL,
    ReservationStatus ENUM('Reserved', 'Paid', 'Canceled') NOT NULL,
    ReservationTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ExpirationTime TIMESTAMP NOT NULL,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    CHECK (ExpirationTime > ReservationTime)
);

CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY,
    VehicleType ENUM('Plane', 'Train', 'Bus') NOT NULL,
    Origin VARCHAR(100) NOT NULL,
    Destination VARCHAR(100) NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Capacity INT NOT NULL,
    CarrierID INT,
    TravelClass ENUM('Economy', 'Business', 'VIP') NOT NULL,
	CHECK (Price >= 0)
);

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    UserID INT NOT NULL,
    ReservationID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    PaymentMethod ENUM('Bank Card', 'Wallet', 'Cryptocurrency') NOT NULL,
    PaymentStatus ENUM('Successful', 'Failed', 'Pending') NOT NULL,
    PaymentTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
);

CREATE TABLE Reports (
    ReportID INT PRIMARY KEY,
    UserID INT NOT NULL,
    TicketID INT,
    ReservationID INT,
    ReportCategory ENUM('Payment Issue', 'Travel Delay', 'Unexpected Cancellation') NOT NULL,
    ReportText TEXT NOT NULL,
    ProcessingStatus ENUM('Reviewed', 'Pending') DEFAULT 'Pending',
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
);

SELECT * FROM user;
SELECT * FROM passenger;
SELECT * FROM WebsiteSupport;
SELECT * FROM Reservation;
SELECT * FROM Ticket;
SELECT * FROM Payment;
SELECT * FROM Reports;
