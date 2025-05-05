-- 1
DELIMITER //
CREATE PROCEDURE GetUserTicketsByContact(IN contact VARCHAR(100))
BEGIN
  SELECT t.*
  FROM Reservation r
  JOIN User u ON r.UserID = u.UserID
  JOIN Ticket t ON r.TicketID = t.TicketID
  WHERE u.Email = contact OR u.Phone = contact
  ORDER BY r.ReservationTime;
END //
DELIMITER ;

-- 2
DELIMITER //
CREATE PROCEDURE GetUsersWithCanceledReservations(IN contact VARCHAR(100))
BEGIN
  SELECT DISTINCT u.FirstName, u.LastName
  FROM Reservation r
  JOIN User u ON r.UserID = u.UserID
  WHERE r.ReservationStatus = 'Canceled'
    AND EXISTS (
        SELECT 1 FROM User u2
        WHERE u2.Email = contact OR u2.Phone = contact
          AND u2.City = u.City
    );
END //
DELIMITER ;

-- 3
DELIMITER //
CREATE PROCEDURE GetTicketsByCity(IN inputCity VARCHAR(100))
BEGIN
  SELECT t.*
  FROM Reservation r
  JOIN User u ON r.UserID = u.UserID
  JOIN Ticket t ON r.TicketID = t.TicketID
  WHERE u.City = inputCity;
END //
DELIMITER ;

-- 4
DELIMITER //
CREATE PROCEDURE SearchTicketsByPhrase(IN phrase VARCHAR(100))
BEGIN
  SELECT t.*
  FROM Reservation r
  JOIN Ticket t ON r.TicketID = t.TicketID
  WHERE t.TicketClass LIKE CONCAT('%', phrase, '%')
     OR t.Origin LIKE CONCAT('%', phrase, '%')
     OR t.Destination LIKE CONCAT('%', phrase, '%')
     OR EXISTS (
        SELECT 1
        FROM Passenger p
        WHERE p.TicketID = t.TicketID AND p.Name LIKE CONCAT('%', phrase, '%')
     );
END //
DELIMITER ;

-- 5
DELIMITER //
CREATE PROCEDURE GetUsersFromSameCity(IN contact VARCHAR(100))
BEGIN
  DECLARE userCity VARCHAR(100);
  
  SELECT City INTO userCity
  FROM User
  WHERE Email = contact OR Phone = contact
  LIMIT 1;
  
  SELECT * FROM User
  WHERE City = userCity AND (Email <> contact AND Phone <> contact);
END //
DELIMITER ;

-- 6
DELIMITER //
CREATE PROCEDURE GetTopUsersSinceDate(IN sinceDate DATE, IN limitN INT)
BEGIN
  SELECT u.FirstName, u.LastName, COUNT(*) AS TicketCount
  FROM Reservation r
  JOIN User u ON r.UserID = u.UserID
  WHERE r.ReservationTime >= sinceDate
  GROUP BY u.UserID
  ORDER BY TicketCount DESC
  LIMIT limitN;
END //
DELIMITER ;

-- 7
DELIMITER //
CREATE PROCEDURE GetTicketsAndCancellationsByVehicle(IN vType VARCHAR(50))
BEGIN
  -- Tickets
  SELECT t.*
  FROM Reservation r
  JOIN Ticket t ON r.TicketID = t.TicketID
  WHERE t.VehicleType = vType;

  -- Related cancellations
  SELECT r.*
  FROM Reservation r
  JOIN Ticket t ON r.TicketID = t.TicketID
  WHERE t.VehicleType = vType AND r.ReservationStatus = 'Canceled'
  ORDER BY r.ReservationTime;
END //
DELIMITER ;

-- 8
DELIMITER //
CREATE PROCEDURE GetTopUsersByReportTopic(IN topic VARCHAR(100))
BEGIN
  SELECT u.FirstName, u.LastName, COUNT(*) AS ReportCount
  FROM Reports rp
  JOIN User u ON rp.UserID = u.UserID
  WHERE rp.ReportCategory = topic
  GROUP BY u.UserID
  ORDER BY ReportCount DESC;
END //
DELIMITER ;
