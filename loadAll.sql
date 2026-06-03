-- 1. Users
INSERT INTO Users (first_name, last_name, email, phone, user_type) VALUES
('Alice', 'Johnson', 'alice.johnson@umbc.edu', '410-555-1001', 'student'),
('Brian', 'Smith', 'brian.smith@umbc.edu', '410-555-1002', 'student'),
('Carla', 'Davis', 'carla.davis@umbc.edu', '410-555-1003', 'faculty'),
('David', 'Miller', 'david.miller@umbc.edu', '410-555-1004', 'staff'),
('Eva', 'Brown', 'eva.brown@umbc.edu', '410-555-1005', 'visitor'),
('Frank', 'Wilson', 'frank.wilson@umbc.edu', '410-555-1006', 'admin'),
('Grace', 'Moore', 'grace.moore@umbc.edu', '410-555-1007', 'student'),
('Henry', 'Taylor', 'henry.taylor@umbc.edu', '410-555-1008', 'faculty'),
('Isabel', 'Anderson', 'isabel.anderson@umbc.edu', '410-555-1009', 'staff'),
('Jack', 'Thomas', 'jack.thomas@umbc.edu', '410-555-1010', 'visitor');

-- 2. Roles
INSERT INTO Roles (role_name) VALUES
('Student'),
('Faculty'),
('Staff'),
('Visitor'),
('Admin'),
('Commuter'),
('Resident'),
('Enforcement'),
('TransportationManager'),
('Maintenance');

-- 3. Lots
INSERT INTO Lots (lot_name, location, lot_type) VALUES
('Lot A', 'Academic Row', 'student'),
('Lot B', 'Library Side', 'student'),
('Lot C', 'Admin Circle', 'faculty_staff'),
('Lot D', 'Event Center', 'visitor'),
('Lot E', 'Commons Garage', 'mixed'),
('Lot F', 'Engineering Drive', 'faculty_staff'),
('Lot G', 'South Entrance', 'visitor'),
('Lot H', 'Residential Area', 'student'),
('Lot I', 'Facilities Yard', 'restricted'),
('Lot J', 'Performing Arts', 'mixed');

-- 4. PermitTypes
INSERT INTO PermitTypes (permit_name, eligible_role, duration, fee) VALUES
('Student Semester Permit', 'student', 'semester', 120.00),
('Student Annual Permit', 'student', 'annual', 250.00),
('Faculty Annual Permit', 'faculty', 'annual', 300.00),
('Staff Annual Permit', 'staff', 'annual', 275.00),
('Visitor Daily Permit', 'visitor', 'daily', 10.00),
('Admin Annual Permit', 'admin', 'annual', 325.00),
('Student Daily Permit', 'student', 'daily', 8.00),
('Faculty Semester Permit', 'faculty', 'semester', 160.00),
('Staff Semester Permit', 'staff', 'semester', 150.00),
('Visitor Event Permit', 'visitor', 'daily', 15.00);

-- 5. Vehicles
INSERT INTO Vehicles (license_plate, make, model, color, user_id) VALUES
('UMB001', 'Toyota', 'Camry', 'Black', 1),
('UMB002', 'Honda', 'Civic', 'Blue', 2),
('UMB003', 'Ford', 'Escape', 'White', 3),
('UMB004', 'Nissan', 'Altima', 'Gray', 4),
('UMB005', 'Hyundai', 'Elantra', 'Silver', 5),
('UMB006', 'Chevrolet', 'Malibu', 'Red', 6),
('UMB007', 'Tesla', 'Model 3', 'White', 7),
('UMB008', 'Jeep', 'Cherokee', 'Black', 8),
('UMB009', 'Subaru', 'Forester', 'Green', 9),
('UMB010', 'Kia', 'Sportage', 'Blue', 10);

-- 6. UserRoles
INSERT INTO UserRoles (user_id, role_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(5, 4),
(6, 5),
(7, 6),
(8, 2),
(9, 10),
(10, 4);

-- 7. Spots
INSERT INTO Spots (spot_number, spot_type, occupancy_status, lot_id) VALUES
('A1', 'general', 'available', 1),
('B1', 'general', 'occupied', 2),
('C1', 'faculty', 'reserved', 3),
('D1', 'visitor', 'available', 4),
('E1', 'ev', 'occupied', 5),
('F1', 'faculty', 'available', 6),
('G1', 'visitor', 'maintenance', 7),
('H1', 'general', 'reserved', 8),
('I1', 'reserved', 'occupied', 9),
('J1', 'handicap', 'available', 10);

-- 8. Sensors
INSERT INTO Sensors (sensor_code, status, spot_id) VALUES
('SNS-A1', 'active', 1),
('SNS-B1', 'active', 2),
('SNS-C1', 'active', 3),
('SNS-D1', 'inactive', 4),
('SNS-E1', 'active', 5),
('SNS-F1', 'maintenance', 6),
('SNS-G1', 'faulty', 7),
('SNS-H1', 'active', 8),
('SNS-I1', 'active', 9),
('SNS-J1', 'active', 10);

-- 9. Permits
INSERT INTO Permits (issue_date, expiration_date, status, user_id, vehicle_id, permit_type_id) VALUES
('2026-01-10', '2026-05-20', 'active', 1, 1, 1),
('2025-08-25', '2026-08-24', 'active', 2, 2, 2),
('2025-08-15', '2026-08-14', 'active', 3, 3, 3),
('2025-08-15', '2026-08-14', 'active', 4, 4, 4),
('2026-04-01', '2026-04-02', 'expired', 5, 5, 5),
('2025-09-01', '2026-08-31', 'active', 6, 6, 6),
('2026-03-01', '2026-03-02', 'expired', 7, 7, 7),
('2026-01-15', '2026-05-30', 'active', 8, 8, 8),
('2026-01-20', '2026-05-30', 'pending', 9, 9, 9),
('2026-04-10', '2026-04-11', 'revoked', 10, 10, 10);

-- 10. SensorEvents
INSERT INTO SensorEvents (event_time, event_type, sensor_id, vehicle_id) VALUES
('2026-04-20 08:00:00', 'entry', 1, 1),
('2026-04-20 08:05:00', 'occupied', 2, 2),
('2026-04-20 08:10:00', 'entry', 3, 3),
('2026-04-20 08:20:00', 'vacant', 4, NULL),
('2026-04-20 08:30:00', 'occupied', 5, 5),
('2026-04-20 08:40:00', 'error', 6, NULL),
('2026-04-20 08:50:00', 'error', 7, NULL),
('2026-04-20 09:00:00', 'entry', 8, 8),
('2026-04-20 09:15:00', 'occupied', 9, 9),
('2026-04-20 09:30:00', 'exit', 10, 10);

-- 11. Reservations
INSERT INTO Reservations (start_time, end_time, status, amount, user_id, vehicle_id, spot_id) VALUES
('2026-04-21 08:00:00', '2026-04-21 10:00:00', 'active', 12.00, 1, 1, 1),
('2026-04-21 09:00:00', '2026-04-21 11:00:00', 'completed', 12.00, 2, 2, 2),
('2026-04-21 10:00:00', '2026-04-21 12:00:00', 'completed', 15.00, 3, 3, 3),
('2026-04-21 11:00:00', '2026-04-21 13:00:00', 'cancelled', 0.00, 4, 4, 4),
('2026-04-21 12:00:00', '2026-04-21 14:00:00', 'expired', 8.00, 5, 5, 5),
('2026-04-21 13:00:00', '2026-04-21 15:00:00', 'active', 10.00, 6, 6, 6),
('2026-04-21 14:00:00', '2026-04-21 16:00:00', 'completed', 9.00, 7, 7, 7),
('2026-04-21 15:00:00', '2026-04-21 17:00:00', 'cancelled', 0.00, 8, 8, 8),
('2026-04-21 16:00:00', '2026-04-21 18:00:00', 'active', 14.00, 9, 9, 9),
('2026-04-21 17:00:00', '2026-04-21 19:00:00', 'completed', 11.00, 10, 10, 10);

-- 12. Tickets
INSERT INTO Tickets (issue_time, violation_type, fine_amount, status, vehicle_id, user_id, spot_id) VALUES
('2026-04-18 08:15:00', 'No Permit Displayed', 50.00, 'unpaid', 1, 1, 1),
('2026-04-18 09:20:00', 'Overtime Parking', 35.00, 'paid', 2, 2, 2),
('2026-04-18 10:10:00', 'Unauthorized Lot', 60.00, 'appealed', 3, 3, 3),
('2026-04-18 11:45:00', 'Handicap Violation', 150.00, 'unpaid', 4, 4, 10),
('2026-04-18 12:05:00', 'Expired Permit', 40.00, 'paid', 5, 5, 5),
('2026-04-18 01:15:00', 'No Payment', 25.00, 'dismissed', 6, 6, 6),
('2026-04-18 02:30:00', 'Reserved Spot Violation', 75.00, 'unpaid', 7, 7, 9),
('2026-04-18 03:40:00', 'Blocking Traffic', 80.00, 'paid', 8, 8, 8),
('2026-04-18 04:25:00', 'Improper Parking', 30.00, 'appealed', 9, 9, 9),
('2026-04-18 05:10:00', 'Visitor Time Exceeded', 20.00, 'unpaid', 10, 10, 4);

-- 13. Payments
INSERT INTO Payments (payment_date, amount, payment_type, payment_status, reservation_id, ticket_id, user_id) VALUES
('2026-04-21 11:05:00', 12.00, 'card', 'completed', 2, NULL, 2),
('2026-04-21 12:10:00', 15.00, 'mobile', 'completed', 3, NULL, 3),
('2026-04-21 01:30:00', 8.00, 'online', 'failed', 5, NULL, 5),
('2026-04-21 04:05:00', 9.00, 'cash', 'completed', 7, NULL, 7),
('2026-04-21 07:15:00', 11.00, 'card', 'completed', 10, NULL, 10),
('2026-04-18 10:00:00', 35.00, 'online', 'completed', NULL, 2, 2),
('2026-04-18 12:45:00', 40.00, 'card', 'completed', NULL, 5, 5),
('2026-04-18 02:00:00', 25.00, 'mobile', 'refunded', NULL, 6, 6),
('2026-04-18 04:10:00', 80.00, 'cash', 'completed', NULL, 8, 8),
('2026-04-18 06:00:00', 20.00, 'online', 'pending', NULL, 10, 10);