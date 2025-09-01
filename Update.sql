INSERT INTO Ticket (TripType, VehicleType, Origin, Destination, DepartureTime, ArrivalTime, Price, Capacity, CarrierID, TravelClass) VALUES
('one-way', 'Train', 'New York', 'Boston', '2025-06-29 14:43:27', '2025-06-29 22:43:27', 926.25, 274, 5, 'Economy'),
('Round-trip', 'Train', 'Miami', 'Boston', '2025-06-30 14:43:27', '2025-06-30 16:43:27', 229.01, 93, 2, 'Economy'),
('Round-trip', 'Train', 'Houston', 'Boston', '2025-07-06 14:43:27', '2025-07-06 20:43:27', 239.3, 286, 4, 'Business'),
('Round-trip', 'Plane', 'Miami', 'Boston', '2025-06-13 14:43:27', '2025-06-13 23:43:27', 179.88, 171, 9, 'Business'),
('one-way', 'Train', 'Miami', 'Seattle', '2025-07-03 14:43:27', '2025-07-03 22:43:27', 517.85, 84, 4, 'VIP'),
('one-way', 'Bus', 'Los Angeles', 'San Francisco', '2025-06-19 14:43:27', '2025-06-19 17:43:27', 95.60, 148, 8, 'Economy'),
('one-way', 'Bus', 'Miami', 'San Francisco', '2025-06-15 14:43:27', '2025-06-15 19:43:27', 121.76, 276, 1, 'Business'),
('one-way', 'Plane', 'Houston', 'Seattle', '2025-07-02 14:43:27', '2025-07-02 18:43:27', 733.90, 187, 10, 'VIP'),
('one-way', 'Train', 'New York', 'Denver', '2025-06-18 14:43:27', '2025-06-18 19:43:27', 185.52, 59, 2, 'Business'),
('Round-trip', 'Bus', 'Houston', 'Seattle', '2025-06-21 14:43:27', '2025-06-21 19:43:27', 189.22, 289, 6, 'Economy'),
('one-way', 'Plane', 'Chicago', 'San Francisco', '2025-06-25 14:43:27', '2025-06-25 21:43:27', 861.96, 83, 2, 'Business'),
('one-way', 'Train', 'Miami', 'San Francisco', '2025-07-04 14:43:27', '2025-07-04 22:43:27', 593.3, 234, 1, 'VIP'),
('Round-trip', 'Plane', 'New York', 'Boston', '2025-07-03 14:43:27', '2025-07-03 19:43:27', 407.49, 201, 10, 'Economy'),
('one-way', 'Bus', 'Los Angeles', 'New York', '2025-06-26 14:43:27', '2025-06-26 22:43:27', 150.82, 203, 5, 'VIP'),
('Round-trip', 'Train', 'Houston', 'Miami', '2025-07-01 14:43:27', '2025-07-01 21:43:27', 690.5, 105, 7, 'Business');

INSERT INTO Vehicle (TicketID) VALUES
(1026), (1027), (1028), (1029), (1030),
(1031), (1032), (1033), (1034), (1035),
(1036), (1037), (1038), (1039), (1040);

INSERT INTO Train (VehicleID, TicketID, StarRating, Facilities, CompartmentOption) VALUES
(5011, 1026, '4', '["TV", "Charger"]', 0),
(5012, 1027, '5', '["None"]', 1),
(5013, 1028, '3', '["None"]', 1),
(5015, 1030, '4', '["Recliner Seats"]', 0),
(5019, 1034, '4', '["None"]', 0),
(5025, 1040, '5', '["AC", "Toilet"]', 0);

INSERT INTO Flight (VehicleID, TicketID, AirlineName, Stops, FlightNumber, FromAirport, DestinationAirport, Facilities) VALUES
(5014, 1029, 'United', 0, 'FL2074', 'New York Intl', 'San Francisco Intl', '["None"]'),
(5018, 1033, 'American Airlines', 1, 'FL8426', 'Miami Intl', 'Seattle Intl', '["Recliner Seats"]'),
(5021, 1036, 'Southwest', 1, 'FL8257', 'Houston Intl', 'Seattle Intl', '["Recliner Seats"]'),
(5023, 1038, 'United', 0, 'FL2445', 'Chicago Intl', 'San Francisco Intl', '["Recliner Seats"]');



INSERT INTO Bus (VehicleID, TicketID, BusCompany, SeatsPerRow, Facilities) VALUES
(5016, 1031, 'FlixBus', '2+2', '["None"]'),
(5017, 1032, 'FlixBus', '2+2', '["AC", "Toilet"]'),
(5020, 1035, 'Greyhound', '1+2', '["None"]'),
(5022, 1037, 'Megabus', '1+2', '["Recliner Seats"]'),
(5024, 1039, 'Megabus', '1+2', '["Recliner Seats"]');


INSERT INTO UserWallet (UserID, Balance)
SELECT UserID, 0.00
FROM User
WHERE UserID NOT IN (SELECT UserID FROM UserWallet);


INSERT INTO Ticket 
(TripType, VehicleType, Origin, Destination, DepartureTime, ArrivalTime, Price, Capacity, CarrierID, TravelClass)
VALUES
-- ✈️ Flights (short-term & future)
('one-way', 'Plane', 'Berlin', 'Paris', '2025-08-18 07:30:00', '2025-08-18 09:00:00', 120.50, 180, 1, 'Economy'),
('Round-trip', 'Plane', 'Frankfurt', 'New York', '2025-08-20 10:00:00', '2025-08-20 18:00:00', 650.00, 220, 2, 'Business'),
('one-way', 'Plane', 'Munich', 'London', '2025-08-17 23:45:00', '2025-08-18 01:10:00', 95.00, 160, 1, 'Economy'),
('one-way', 'Plane', 'Hamburg', 'Tokyo', '2025-09-05 14:00:00', '2025-09-06 07:30:00', 899.99, 200, 3, 'Economy'),
('Round-trip', 'Plane', 'Berlin', 'Dubai', '2025-12-01 22:00:00', '2025-12-02 06:30:00', 750.00, 250, 2, 'VIP'),

-- 🚆 Trains (regional & long distance)
('one-way', 'Train', 'Berlin Hbf', 'Munich Hbf', '2025-08-18 06:15:00', '2025-08-18 11:30:00', 60.00, 400, 4, 'Economy'),
('Round-trip', 'Train', 'Cologne Hbf', 'Amsterdam Centraal', '2025-08-19 09:00:00', '2025-08-19 12:15:00', 80.00, 350, 5, 'Business'),
('one-way', 'Train', 'Leipzig', 'Prague', '2025-08-22 13:00:00', '2025-08-22 16:30:00', 55.50, 300, 6, 'Economy'),
('one-way', 'Train', 'Berlin Hbf', 'Warsaw', '2025-09-10 08:00:00', '2025-09-10 13:30:00', 70.00, 280, 4, 'Economy'),
('Round-trip', 'Train', 'Munich Hbf', 'Vienna Hbf', '2025-10-05 15:30:00', '2025-10-05 18:00:00', 95.00, 320, 5, 'VIP'),

-- 🚌 Buses (short/medium routes)
('one-way', 'Bus', 'Berlin ZOB', 'Hamburg ZOB', '2025-08-18 05:45:00', '2025-08-18 08:45:00', 25.00, 50, 7, 'Economy'),
('Round-trip', 'Bus', 'Frankfurt', 'Zurich', '2025-08-21 07:00:00', '2025-08-21 12:00:00', 40.00, 60, 8, 'Economy'),
('one-way', 'Bus', 'Munich', 'Salzburg', '2025-08-17 22:00:00', '2025-08-17 23:45:00', 20.00, 45, 9, 'Economy'),
('one-way', 'Bus', 'Berlin', 'Warsaw', '2025-09-15 06:00:00', '2025-09-15 14:00:00', 35.00, 55, 7, 'Business'),
('Round-trip', 'Bus', 'Stuttgart', 'Prague', '2025-11-20 09:30:00', '2025-11-20 14:30:00', 50.00, 52, 8, 'VIP');

INSERT INTO Vehicle (TicketID) VALUES
(1041), (1042), (1043), (1044), (1045),
(1046), (1047), (1048), (1049), (1050),
(1051), (1052), (1053), (1054), (1055);

INSERT INTO Flight (VehicleID, TicketID, AirlineName, Stops, FlightNumber, FromAirport, DestinationAirport, Facilities) VALUES
(5026, 1041, 'United', 0, 'FL2074', 'New York Intl', 'San Francisco Intl', '["None"]'),
(5027, 1042, 'American Airlines', 1, 'FL8426', 'Miami Intl', 'Seattle Intl', '["Recliner Seats"]'),
(5028, 1043, 'Southwest', 1, 'FL8257', 'Houston Intl', 'Seattle Intl', '["Recliner Seats"]'),
(5029, 1044, 'United', 0, 'FL2445', 'Chicago Intl', 'San Francisco Intl', '["Recliner Seats"]'),
(5030, 1045, 'United', 0, 'FL2445', 'Chicago Intl', 'San Francisco Intl', '["Recliner Seats"]');

INSERT INTO Train (VehicleID, TicketID, StarRating, Facilities, CompartmentOption) VALUES
(5031, 1046, '4', '["TV", "Charger"]', 0),
(5032, 1047, '5', '["None"]', 1),
(5033, 1048, '3', '["None"]', 1),
(5034, 1049, '4', '["Recliner Seats"]', 0),
(5035, 1050, '4', '["None"]', 0);
-- (5036, 1051, '5', '["AC", "Toilet"]', 0);


INSERT INTO Bus (VehicleID, TicketID, BusCompany, SeatsPerRow, Facilities) VALUES
(5036, 1055, 'Megabus', '1+2', '["Recliner Seats"]'),
(5037, 1051, 'FlixBus', '2+2', '["None"]'),
(5038, 1052, 'FlixBus', '2+2', '["AC", "Toilet"]'),
(5039, 1053, 'Greyhound', '1+2', '["None"]'),
(5040, 1054, 'Megabus', '1+2', '["Recliner Seats"]');

INSERT INTO Ticket 
(TripType, VehicleType, Origin, Destination, DepartureTime, ArrivalTime, Price, Capacity, CarrierID, TravelClass)
VALUES
-- ✈️ Flights (short-term & future)
('one-way', 'Plane', 'Berlin', 'Paris', '2025-08-18 07:30:00', '2027-08-18 09:00:00', 120.50, 180, 1, 'Economy');


INSERT INTO Vehicle (TicketID) VALUES
(1056), (1057);
INSERT INTO Flight (VehicleID, TicketID, AirlineName, Stops, FlightNumber, FromAirport, DestinationAirport, Facilities) VALUES
(5041, 1056, 'United', 0, 'FL2074', 'New York Intl', 'San Francisco Intl', '["None"]'),
(5042, 1057, 'United', 0, 'FL2445', 'Chicago Intl', 'San Francisco Intl', '["Recliner Seats"]');


INSERT INTO Ticket 
(TripType, VehicleType, Origin, Destination, DepartureTime, ArrivalTime, Price, Capacity, CarrierID, TravelClass)
VALUES
-- ✈️ Flights (short-term & future)
('one-way', 'Plane', 'Berlin', 'Paris', '2026-08-18 07:30:00', '2027-08-18 09:00:00', 120.50, 180, 1, 'Economy');


INSERT INTO Vehicle (TicketID) VALUES
(1056), (1057);
INSERT INTO Flight (VehicleID, TicketID, AirlineName, Stops, FlightNumber, FromAirport, DestinationAirport, Facilities) VALUES
(5041, 1056, 'United', 0, 'FL2074', 'New York Intl', 'San Francisco Intl', '["None"]'),
(5042, 1057, 'United', 0, 'FL2445', 'Chicago Intl', 'San Francisco Intl', '["Recliner Seats"]');
