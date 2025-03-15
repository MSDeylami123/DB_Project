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


CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY,
    TripType ENUM('one-way','Round-trip'),
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

CREATE TABLE Train (
    TrainID INT PRIMARY KEY,
    TicketID INT NOT NULL,
    StarRating ENUM('3', '4', '5') NOT NULL,
    Facilities JSON,
    CompartmentOption BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
);

CREATE TABLE Flight (
    FlightID INT PRIMARY KEY AUTO_INCREMENT,
    TicketID INT NOT NULL,
    AirlineName VARCHAR(100) NOT NULL,
    FlightClass ENUM('Economy', 'Business', 'First Class') NOT NULL,
    Stops INT NOT NULL,
    FlightNumber VARCHAR(20) NOT NULL,
    FromAirport VARCHAR(100) NOT NULL,
    DestinationAirport VARCHAR(100) NOT NULL,
    Facilities JSON,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
);

CREATE TABLE Bus (
    BusID INT PRIMARY KEY,
    TicketID INT NOT NULL,
    BusCompany VARCHAR(100) NOT NULL,
    BusType ENUM('VIP', 'Regular', 'Sleeper') NOT NULL,
    SeatsPerRow ENUM('1+2', '2+2') NOT NULL,
    Facilities JSON,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
);

SELECT * FROM user;
SELECT * FROM passenger;
SELECT * FROM WebsiteSupport;
SELECT * FROM Reservation;
SELECT * FROM Ticket;
SELECT * FROM Payment;
SELECT * FROM Reports;
SELECT * FROM Train;
SELECT * FROM Flight;
SELECT * FROM Bus;
