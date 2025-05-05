SELECT u.FirstName, u.LastName
FROM User u
LEFT JOIN Reservation r ON u.UserID = r.UserID
WHERE r.ReservationID IS NULL;


SELECT DISTINCT u.FirstName, u.LastName
FROM User u
JOIN Reservation r ON u.UserID = r.UserID;

SELECT 
    u.UserID,
    u.FirstName,
    u.LastName,
    DATE_FORMAT(p.PaymentTime, '%Y-%m') AS PaymentMonth,
    SUM(p.Amount) AS TotalPayments
FROM Payment p
JOIN User u ON u.UserID = p.UserID
WHERE p.PaymentStatus = 'Successful'
GROUP BY u.UserID, PaymentMonth
ORDER BY u.UserID, PaymentMonth;

SELECT u.UserID, u.FirstName, u.LastName, u.City
FROM Reservation r
JOIN User u ON r.UserID = u.UserID
JOIN Ticket t ON r.TicketID = t.TicketID
GROUP BY u.UserID, u.City
HAVING COUNT(DISTINCT t.Origin) = COUNT(*)
   AND COUNT(*) = 1;
   

SELECT u.*
FROM Reservation r
JOIN User u ON r.UserID = u.UserID
ORDER BY r.ReservationTime DESC
LIMIT 1;


SELECT DISTINCT COALESCE(u.Email, u.Phone) AS Contact
FROM Payment p
JOIN User u ON p.UserID = u.UserID
GROUP BY u.UserID, u.Email, u.Phone
HAVING SUM(p.Amount) > (SELECT AVG(Amount) FROM Payment);

SELECT t.VehicleType, COUNT(r.ReservationID) AS TicketsSold
FROM Reservation r
JOIN Ticket t ON r.TicketID = t.TicketID
WHERE r.ReservationStatus = 'Paid'
GROUP BY t.VehicleType;

SELECT u.FirstName, u.LastName, COUNT(*) AS TicketsBought
FROM Reservation r
JOIN User u ON r.UserID = u.UserID
WHERE r.ReservationTime >= NOW() - INTERVAL 7 DAY
GROUP BY u.UserID
ORDER BY TicketsBought DESC
LIMIT 3;

SELECT u.City, COUNT(*) AS TicketsSold
FROM Reservation r
JOIN User u ON r.UserID = u.UserID
WHERE u.City LIKE '%Tehran%'
GROUP BY u.City;


-- Oldest user’s city
SELECT City
FROM User
ORDER BY RegistrationDate
LIMIT 1;

-- Sponsors (assuming support users are sponsors)
SELECT FirstName, LastName
FROM User
WHERE UserType = 'Support';


SELECT u.FirstName, u.LastName
FROM Reservation r
JOIN User u ON r.UserID = u.UserID
GROUP BY u.UserID
HAVING COUNT(DISTINCT r.TicketID) >= 2;



SELECT u.FirstName, u.LastName
FROM Reservation r
JOIN Ticket t ON r.TicketID = t.TicketID
JOIN User u ON r.UserID = u.UserID
WHERE t.VehicleType = 'Train'
GROUP BY u.UserID
HAVING COUNT(*) <= 2;


SELECT u.Email, u.Phone
FROM Reservation r
JOIN Ticket t ON r.TicketID = t.TicketID
JOIN User u ON r.UserID = u.UserID
GROUP BY u.UserID, u.Email, u.Phone
HAVING COUNT(DISTINCT t.VehicleType) = 3;

SELECT t.*
FROM Reservation r
JOIN Ticket t ON r.TicketID = t.TicketID
WHERE DATE(r.ReservationTime) = CURRENT_DATE
ORDER BY r.ReservationTime;

SELECT t.TicketID, COUNT(*) AS SoldCount
FROM Reservation r
JOIN Ticket t ON r.TicketID = t.TicketID
WHERE r.ReservationStatus = 'Paid'
GROUP BY t.TicketID
ORDER BY SoldCount DESC
LIMIT 1 OFFSET 1;

SELECT u.FirstName, u.LastName,
       COUNT(*) AS CancelCount,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Reservation WHERE ReservationStatus = 'Canceled'), 2) AS CancellationPercentage
FROM Reservation r
JOIN User u ON r.UserID = u.UserID
WHERE r.ReservationStatus = 'Canceled'
  AND u.UserType = 'Support'
GROUP BY u.UserID
ORDER BY CancelCount DESC
LIMIT 1;


UPDATE User
SET LastName = 'Reddington'
WHERE UserID = (
    SELECT r.UserID
    FROM Reservation r
    WHERE r.ReservationStatus = 'Canceled'
    GROUP BY r.UserID
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

DELETE FROM Reservation
WHERE ReservationStatus = 'Canceled'
  AND UserID = (
    SELECT UserID FROM User WHERE LastName = 'Reddington'
);

DELETE FROM Reservation
WHERE ReservationStatus = 'Canceled';

UPDATE Ticket
SET Price = Price * 0.9
WHERE TicketID IN (
    SELECT f.TicketID
    FROM Flight f
    JOIN Reservation r ON f.TicketID = r.TicketID
    WHERE f.AirlineName = 'Mahan Air'
      AND DATE(r.ReservationTime) = CURRENT_DATE - INTERVAL 1 DAY
);


SELECT TicketID, ReportCategory, COUNT(*) AS ReportCount
FROM Reports
GROUP BY TicketID, ReportCategory
HAVING TicketID = (
    SELECT TicketID
    FROM Reports
    GROUP BY TicketID
    ORDER BY COUNT(*) DESC
    LIMIT 1
);















