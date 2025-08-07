USE mydb;
CREATE TABLE User (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
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
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);

CREATE TABLE WebsiteSupport (
    UserID INT PRIMARY KEY,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE
);

CREATE TABLE UserWallet (
    WalletID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    Balance DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_wallet_user FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE,
    UNIQUE (UserID)
);



CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY AUTO_INCREMENT,
    TripType ENUM('one-way','Round-trip'),
    VehicleType ENUM('Plane', 'Train', 'Bus') NOT NULL,
    Origin VARCHAR(100) NOT NULL,
    Destination VARCHAR(100) NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Capacity INT NOT NULL CHECK(Capacity>=0),
    CarrierID INT,
    TravelClass ENUM('Economy', 'Business', 'VIP') NOT NULL,
	CHECK (Price >= 0)
);

CREATE TABLE Reservation (
    ReservationID INT PRIMARY KEY AUTO_INCREMENT,
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
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    ReservationID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount >= 0),
    PaymentMethod ENUM('Bank Card', 'Wallet', 'Cryptocurrency') NOT NULL,
    PaymentStatus ENUM('Successful', 'Failed', 'Pending') NOT NULL DEFAULT 'Pending',
    PaymentTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
);



CREATE TABLE Reports (
    ReportID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    TicketID INT,
    ReservationID INT,
    ReportCategory ENUM('Payment Issue', 'Travel Delay', 'Unexpected Cancellation') NOT NULL,
    ReportText TEXT NOT NULL,
    Answer TEXT NOT NULL,
    ProcessingStatus ENUM('Reviewed', 'Pending') DEFAULT 'Pending',
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
);

CREATE TABLE Vehicle (
    VehicleID INT PRIMARY KEY,
    TicketId INT NOT NULL,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
);

CREATE TABLE Train (
    VehicleID INT PRIMARY KEY AUTO_INCREMENT,
    TicketID INT NOT NULL,
    StarRating ENUM('3', '4', '5') NOT NULL,
    Facilities JSON,
    CompartmentOption BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID)
);

CREATE TABLE Flight (
    VehicleID INT PRIMARY KEY,
    TicketID INT NOT NULL,
    AirlineName VARCHAR(100) NOT NULL,
    Stops INT NOT NULL,
    FlightNumber VARCHAR(20) NOT NULL,
    FromAirport VARCHAR(100) NOT NULL,
    DestinationAirport VARCHAR(100) NOT NULL,
    Facilities JSON,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID)
);

CREATE TABLE Bus (
    VehicleID INT PRIMARY KEY,
    TicketID INT NOT NULL,
    BusCompany VARCHAR(100) NOT NULL,
    SeatsPerRow ENUM('1+2', '2+2') NOT NULL,
    Facilities JSON,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID)
);

INSERT INTO User (UserID, FirstName, LastName, Email, Phone, UserType, City, PasswordHash) VALUES
(1, 'Alice', 'Walker', 'alice1@example.com', '1111111111', 'Passenger', 'New York', 'hash1'),
(2, 'Bob', 'Smith', 'bob2@example.com', '2222222222', 'Passenger', 'Chicago', 'hash2'),
(3, 'Charlie', 'Brown', 'charlie3@example.com', '3333333333', 'Passenger', 'Boston', 'hash3'),
(4, 'David', 'Johnson', 'david4@example.com', '4444444444', 'Passenger', 'Miami', 'hash4'),
(5, 'Eva', 'Green', 'eva5@example.com', '5555555555', 'Passenger', 'Seattle', 'hash5'),
(6, 'Fay', 'Miller', 'fay6@example.com', '6666666666', 'Passenger', 'Denver', 'hash6'),
(7, 'Grace', 'Lee', 'grace7@example.com', '7777777777', 'Passenger', 'Austin', 'hash7'),
(8, 'Hank', 'Moore', 'hank8@example.com', '8888888888', 'Passenger', 'Portland', 'hash8'),
(9, 'Ivy', 'Davis', 'ivy9@example.com', '9999999999', 'Passenger', 'Atlanta', 'hash9'),
(10, 'Jake', 'White', 'jake10@example.com', '1010101010', 'Support', 'San Francisco', 'hash10');

INSERT INTO Passenger (UserID) VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (9);

INSERT INTO WebsiteSupport (UserID) VALUES (10);

INSERT INTO Ticket (TicketID, TripType, VehicleType, Origin, Destination, DepartureTime, ArrivalTime, Price, Capacity, CarrierID, TravelClass) VALUES
(1001, 'one-way', 'Plane', 'NYC', 'LA', '2025-06-01 08:00:00', '2025-06-01 11:00:00', 250.00, 180, NULL, 'Economy'),
(1002, 'Round-trip', 'Train', 'Chicago', 'Detroit', '2025-06-02 09:00:00', '2025-06-02 12:00:00', 90.00, 100, NULL, 'Business'),
(1003, 'one-way', 'Bus', 'Seattle', 'Portland', '2025-06-03 10:00:00', '2025-06-03 13:00:00', 40.00, 50, NULL, 'VIP'),
(1004, 'one-way', 'Plane', 'LA', 'Miami', '2025-06-04 07:30:00', '2025-06-04 11:30:00', 300.00, 170, NULL, 'Economy'),
(1005, 'Round-trip', 'Train', 'NYC', 'Boston', '2025-06-05 06:00:00', '2025-06-05 09:00:00', 85.00, 90, NULL, 'Business'),
(1006, 'one-way', 'Bus', 'Denver', 'Austin', '2025-06-06 12:00:00', '2025-06-06 20:00:00', 60.00, 45, NULL, 'VIP'),
(1007, 'one-way', 'Plane', 'Chicago', 'Atlanta', '2025-06-07 10:00:00', '2025-06-07 13:00:00', 220.00, 160, NULL, 'Economy'),
(1008, 'Round-trip', 'Train', 'Boston', 'NYC', '2025-06-08 08:30:00', '2025-06-08 11:30:00', 88.00, 110, NULL, 'Business'),
(1009, 'one-way', 'Bus', 'Austin', 'Miami', '2025-06-09 09:00:00', '2025-06-09 19:00:00', 55.00, 60, NULL, 'VIP'),
(1010, 'one-way', 'Plane', 'Seattle', 'Chicago', '2025-06-10 06:00:00', '2025-06-10 10:00:00', 280.00, 175, NULL, 'Economy');

INSERT INTO Reservation (ReservationID, UserID, TicketID, ReservationStatus, ExpirationTime) VALUES
(2001, 1, 1001, 'Reserved', '2025-05-30 08:00:00'),
(2002, 2, 1002, 'Paid', '2025-06-01 09:00:00'),
(2003, 3, 1003, 'Reserved', '2025-06-01 10:00:00'),
(2004, 4, 1004, 'Paid', '2025-06-02 07:00:00'),
(2005, 5, 1005, 'Canceled', '2025-06-02 06:00:00'),
(2006, 6, 1006, 'Paid', '2025-06-03 11:00:00'),
(2007, 7, 1007, 'Reserved', '2025-06-04 09:00:00'),
(2008, 8, 1008, 'Paid', '2025-06-05 08:00:00'),
(2009, 9, 1009, 'Canceled', '2025-06-06 08:00:00'),
(2010, 1, 1010, 'Paid', '2025-06-07 06:00:00');

INSERT INTO Payment (PaymentID, UserID, ReservationID, Amount, PaymentMethod, PaymentStatus) VALUES
(3001, 2, 2002, 90.00, 'Bank Card', 'Successful'),
(3002, 4, 2004, 300.00, 'Wallet', 'Successful'),
(3003, 6, 2006, 60.00, 'Cryptocurrency', 'Successful'),
(3004, 8, 2008, 88.00, 'Bank Card', 'Successful'),
(3005, 1, 2010, 280.00, 'Bank Card', 'Successful'),
(3006, 3, 2003, 40.00, 'Wallet', 'Pending'),
(3007, 7, 2007, 220.00, 'Cryptocurrency', 'Pending'),
(3008, 5, 2005, 85.00, 'Wallet', 'Failed'),
(3009, 9, 2009, 55.00, 'Cryptocurrency', 'Failed'),
(3010, 1, 2001, 250.00, 'Bank Card', 'Pending');

INSERT INTO Reports (ReportID, UserID, TicketID, ReservationID, ReportCategory, ReportText) VALUES
(4001, 1, 1001, 2001, 'Payment Issue', 'Payment status not updated'),
(4002, 2, 1002, 2002, 'Travel Delay', 'Train was late by 2 hours'),
(4003, 3, 1003, 2003, 'Unexpected Cancellation', 'Trip got canceled without notice'),
(4004, 4, 1004, 2004, 'Payment Issue', 'Charged extra'),
(4005, 5, 1005, 2005, 'Travel Delay', 'Train delay not notified'),
(4006, 6, 1006, 2006, 'Unexpected Cancellation', 'Trip canceled suddenly'),
(4007, 7, 1007, 2007, 'Payment Issue', 'Failed payment retry not working'),
(4008, 8, 1008, 2008, 'Travel Delay', 'Delayed by 3 hours'),
(4009, 9, 1009, 2009, 'Payment Issue', 'Card declined wrongly'),
(4010, 1, 1010, 2010, 'Unexpected Cancellation', 'Flight canceled just before departure');

INSERT INTO Vehicle (VehicleID, TicketId) VALUES
(5001, 1001),
(5002, 1002),
(5003, 1003),
(5004, 1004),
(5005, 1005),
(5006, 1006),
(5007, 1007),
(5008, 1008),
(5009, 1009),
(5010, 1010);

INSERT INTO Flight (VehicleID, TicketID, AirlineName, FlightClass, Stops, FlightNumber, FromAirport, DestinationAirport, Facilities) VALUES
(5001, 1001, 'Delta Airlines', 'Economy', 0, 'DL1001', 'JFK', 'LAX', '{"WiFi": true, "In-Flight Entertainment": true}'),
(5004, 1004, 'American Airlines', 'Economy', 1, 'AA1004', 'LAX', 'MIA', '{"Snacks": true, "WiFi": false}'),
(5007, 1007, 'United Airlines', 'Economy', 0, 'UA1007', 'ORD', 'ATL', '{"Power Outlet": true, "WiFi": true}'),
(5010, 1010, 'Alaska Airlines', 'Economy', 2, 'AS1010', 'SEA', 'ORD', '{"WiFi": true, "Meal": false}');

INSERT INTO Train (VehicleID, TicketID, StarRating, Facilities, CompartmentOption) VALUES
(5002, 1002, '4', '{"Restroom": true, "WiFi": true}', TRUE),
(5005, 1005, '3', '{"WiFi": false, "Dining": true}', FALSE),
(5008, 1008, '5', '{"WiFi": true, "Lounge Access": true}', TRUE);

INSERT INTO Bus (VehicleID, TicketID, BusCompany, BusType, SeatsPerRow, Facilities) VALUES
(5003, 1003, 'Greyhound', 'VIP', '2+2', '{"Charging Ports": true, "AC": true}'),
(5006, 1006, 'Megabus', 'VIP', '1+2', '{"WiFi": true, "Recliner Seats": true}'),
(5009, 1009, 'BoltBus', 'VIP', '2+2', '{"Snacks": false, "WiFi": true}');




CREATE INDEX idx_user_usertype ON User(UserType);
CREATE INDEX idx_user_city ON User(City);
CREATE INDEX idx_user_accountstatus ON User(AccountStatus);

CREATE INDEX idx_ticket_vehicletype ON Ticket(VehicleType);
CREATE INDEX idx_ticket_origin_destination ON Ticket(Origin, Destination);
CREATE INDEX idx_ticket_departuretime ON Ticket(DepartureTime);
CREATE INDEX idx_ticket_arrivaltime ON Ticket(ArrivalTime);
CREATE INDEX idx_ticket_travelclass ON Ticket(TravelClass);

CREATE INDEX idx_reservation_userid ON Reservation(UserID);
CREATE INDEX idx_reservation_ticketid ON Reservation(TicketID);
CREATE INDEX idx_reservation_status ON Reservation(ReservationStatus);
CREATE INDEX idx_reservation_expirationtime ON Reservation(ExpirationTime);

CREATE INDEX idx_payment_userid ON Payment(UserID);
CREATE INDEX idx_payment_reservationid ON Payment(ReservationID);
CREATE INDEX idx_payment_method ON Payment(PaymentMethod);
CREATE INDEX idx_payment_status ON Payment(PaymentStatus);

CREATE INDEX idx_report_userid ON Reports(UserID);
CREATE INDEX idx_report_ticketid ON Reports(TicketID);
CREATE INDEX idx_report_reservationid ON Reports(ReservationID);
CREATE INDEX idx_report_category ON Reports(ReportCategory);
CREATE INDEX idx_report_status ON Reports(ProcessingStatus);

CREATE INDEX idx_vehicle_ticketid ON Vehicle(TicketID);

CREATE INDEX idx_train_ticketid ON Train(TicketID);
CREATE INDEX idx_train_starrating ON Train(StarRating);
CREATE INDEX idx_train_compartmentoption ON Train(CompartmentOption);

CREATE INDEX idx_flight_ticketid ON Flight(TicketID);
CREATE INDEX idx_flight_airline ON Flight(AirlineName);
CREATE INDEX idx_flight_flightclass ON Flight(FlightClass);
CREATE INDEX idx_flight_stops ON Flight(Stops);
CREATE INDEX idx_flight_from_to_airport ON Flight(FromAirport, DestinationAirport);

CREATE INDEX idx_bus_ticketid ON Bus(TicketID);
CREATE INDEX idx_bus_company ON Bus(BusCompany);
CREATE INDEX idx_bus_type ON Bus(BusType);
CREATE INDEX idx_bus_seatsperrow ON Bus(SeatsPerRow);







