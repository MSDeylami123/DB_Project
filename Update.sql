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



