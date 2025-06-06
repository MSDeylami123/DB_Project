-- 1
SELECT u.FirstName, u.LastName
FROM User u
LEFT JOIN Reservation r ON u.UserID = r.UserID
WHERE r.ReservationID IS NULL;

-- 2
SELECT DISTINCT u.FirstName, u.LastName
FROM User u
JOIN Reservation r ON u.UserID = r.UserID;

-- 3
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

-- 4
SELECT u.UserID, u.FirstName, u.LastName, u.City
FROM Reservation r
JOIN User u ON r.UserID = u.UserID
JOIN Ticket t ON r.TicketID = t.TicketID
GROUP BY u.UserID, u.City
HAVING COUNT(DISTINCT t.Origin) = COUNT(*)
   AND COUNT(*) = 1;
   
-- 5
SELECT u.*
FROM Payment p
JOIN Reservation r ON p.ReservationID = r.ReservationID
JOIN User u on r.UserID = u.UserID
ORDER BY r.ReservationTime DESC
LIMIT 1;

-- 6
SELECT DISTINCT COALESCE(u.Email, u.Phone) AS Contact
FROM Payment p
JOIN User u ON p.UserID = u.UserID
GROUP BY u.UserID, u.Email, u.Phone
HAVING SUM(p.Amount) > (SELECT AVG(Amount) FROM Payment);

-- 7
SELECT t.VehicleType, COUNT(r.ReservationID) AS TicketsSold
FROM Reservation r
JOIN Ticket t ON r.TicketID = t.TicketID
WHERE r.ReservationStatus = 'Paid'
GROUP BY t.VehicleType;

-- 8
SELECT u.FirstName, u.LastName, COUNT(*) AS TicketsBought
FROM Reservation r
JOIN User u ON r.UserID = u.UserID
WHERE r.ReservationTime >= NOW() - INTERVAL 7 DAY 
GROUP BY u.UserID
ORDER BY TicketsBought DESC
LIMIT 3;



-- 9
SELECT u.City, COUNT(*) AS TicketsSold
FROM Payment p
JOIN User u ON p.UserID = u.UserID
WHERE u.City = 'Portland' AND p.PaymentStatus = 'Successful'
GROUP BY u.City;


-- 10
SELECT t.Origin
FROM User u
JOIN Payment p ON u.UserID = p.UserID
JOIN Reservation r ON p.ReservationID = r.ReservationID
JOIN Ticket t ON r.TicketID = t.TicketID
WHERE p.PaymentStatus = 'Successful' 
	AND u.RegistrationDate = (
		SELECT MIN(RegistrationDate)
		FROM User
);

-- 11
SELECT FirstName, LastName
FROM User
WHERE UserType = 'Support';


-- 12
SELECT u.FirstName, u.LastName
FROM Reservation r
JOIN User u ON r.UserID = u.UserID
WHERE R.ReservationStatus = 'Paid'
GROUP BY u.UserID
HAVING COUNT(*) >= 2;

-- 13
SELECT u.FirstName, u.LastName
FROM Reservation r
JOIN Ticket t ON r.TicketID = t.TicketID
JOIN User u ON r.UserID = u.UserID
WHERE t.VehicleType = 'Train'
GROUP BY u.UserID
HAVING COUNT(*) <= 2;

-- 14
SELECT u.Email, u.Phone
FROM Reservation r
JOIN Ticket t ON r.TicketID = t.TicketID
JOIN User u ON r.UserID = u.UserID
GROUP BY u.UserID, u.Email, u.Phone
HAVING COUNT(DISTINCT t.VehicleType) = 3;

-- 15
SELECT T.*, P.PaymentTime
FROM Payment P
JOIN Reservation R ON P.ReservationID = R.ReservationID
JOIN Ticket T ON R.TicketID = T.TicketID
WHERE DATE(P.PaymentTime) = CURDATE()
ORDER BY P.PaymentTime;


-- 16
SELECT t.TicketID, COUNT(*) AS SoldCount
FROM Reservation r
JOIN Ticket t ON r.TicketID = t.TicketID
WHERE r.ReservationStatus = 'Paid'
GROUP BY t.TicketID
ORDER BY SoldCount DESC
LIMIT 1 OFFSET 1;

-- 17
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

-- 18
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

-- 19
DELETE FROM Reservation
WHERE ReservationStatus = 'Canceled'
  AND UserID = (
    SELECT UserID FROM User WHERE LastName = 'Reddington'
);

-- 20
DELETE FROM Reservation
WHERE ReservationStatus = 'Canceled';

-- 21
UPDATE Ticket
SET Price = Price * 0.9
WHERE TicketID IN (
    SELECT f.TicketID
    FROM Flight f
    JOIN Reservation r ON f.TicketID = r.TicketID
    WHERE f.AirlineName = 'Mahan Air'
      AND DATE(r.ReservationTime) = CURRENT_DATE - INTERVAL 1 DAY
);

-- 22
SELECT TicketID, ReportCategory, COUNT(*) AS ReportCount
FROM Reports
GROUP BY TicketID,ReportCategory
HAVING TicketID = (
    SELECT TicketID
    FROM Reports
    GROUP BY TicketID
    ORDER BY COUNT(*) DESC
    LIMIT 1
);















