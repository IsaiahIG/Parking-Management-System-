-- 1. Show all currently active permits
SELECT *
FROM CurrentActivePermits
ORDER BY expiration_date;

-- 2. Show current lot availability
SELECT *
FROM CurrentLotAvailability
ORDER BY lot_name;

-- 3. List users with their vehicles
SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    v.vehicle_id,
    v.license_plate,
    v.make,
    v.model
FROM Users u
JOIN Vehicles v ON u.user_id = v.user_id
ORDER BY u.user_id;

-- 4. Count permits by permit type
SELECT
    pt.permit_name,
    COUNT(p.permit_id) AS permit_count
FROM PermitTypes pt
LEFT JOIN Permits p ON pt.permit_type_id = p.permit_type_id
GROUP BY pt.permit_name
ORDER BY permit_count DESC, pt.permit_name;

-- 5. Show unpaid tickets with driver and vehicle info
SELECT
    t.ticket_id,
    t.issue_time,
    t.violation_type,
    t.fine_amount,
    u.first_name,
    u.last_name,
    v.license_plate
FROM Tickets t
JOIN Users u ON t.user_id = u.user_id
JOIN Vehicles v ON t.vehicle_id = v.vehicle_id
WHERE t.status = 'unpaid'
ORDER BY t.issue_time DESC;

-- 6. Count tickets by violation type
SELECT
    violation_type,
    COUNT(*) AS ticket_count
FROM Tickets
GROUP BY violation_type
ORDER BY ticket_count DESC, violation_type;

-- 7. Show reservation history with user and spot info
SELECT
    r.reservation_id,
    r.start_time,
    r.end_time,
    r.status,
    u.first_name,
    u.last_name,
    s.spot_number,
    l.lot_name
FROM Reservations r
JOIN Users u ON r.user_id = u.user_id
JOIN Spots s ON r.spot_id = s.spot_id
JOIN Lots l ON s.lot_id = l.lot_id
ORDER BY r.start_time;

-- 8. Users who have no tickets
SELECT
    u.user_id,
    u.first_name,
    u.last_name
FROM Users u
WHERE NOT EXISTS (
    SELECT 1
    FROM Tickets t
    WHERE t.user_id = u.user_id
)
ORDER BY u.user_id;

-- 9. Expensive query: latest sensor event for each sensor
SELECT
    se.sensor_id,
    se.event_id,
    se.event_time,
    se.event_type,
    se.vehicle_id
FROM SensorEvents se
JOIN (
    SELECT sensor_id, MAX(event_time) AS latest_time
    FROM SensorEvents
    GROUP BY sensor_id
) latest
ON se.sensor_id = latest.sensor_id
AND se.event_time = latest.latest_time
ORDER BY se.sensor_id;

-- 10. Expensive query: occupied spots where vehicle has no currently valid active permit
SELECT
    s.spot_id,
    s.spot_number,
    l.lot_name,
    se.vehicle_id,
    v.license_plate
FROM Spots s
JOIN Lots l ON s.lot_id = l.lot_id
JOIN Sensors sn ON s.spot_id = sn.spot_id
JOIN SensorEvents se ON sn.sensor_id = se.sensor_id
JOIN Vehicles v ON se.vehicle_id = v.vehicle_id
WHERE s.occupancy_status = 'occupied'
  AND se.event_time = (
      SELECT MAX(se2.event_time)
      FROM SensorEvents se2
      WHERE se2.sensor_id = se.sensor_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM Permits p
      WHERE p.vehicle_id = se.vehicle_id
        AND p.status = 'active'
        AND CURRENT_DATE BETWEEN p.issue_date AND p.expiration_date
  )
ORDER BY l.lot_name, s.spot_number;