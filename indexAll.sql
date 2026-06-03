CREATE INDEX idx_permits_vehicle_status_dates
ON Permits (vehicle_id, status, issue_date, expiration_date);

CREATE INDEX idx_sensorevents_sensor_time
ON SensorEvents (sensor_id, event_time DESC);

CREATE INDEX idx_spots_lot_occupancy
ON Spots (lot_id, occupancy_status);

CREATE INDEX idx_tickets_status_issue_time
ON Tickets (status, issue_time);

CREATE INDEX idx_reservations_spot_time
ON Reservations (spot_id, start_time, end_time);