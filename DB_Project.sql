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
SELECT * FROM user;
SELECT * FROM passenger;
SELECT * FROM WebsiteSupport;
